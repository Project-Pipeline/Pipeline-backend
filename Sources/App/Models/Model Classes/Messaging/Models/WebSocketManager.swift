//
//  WebSocketManager.swift
//  
//
//  Created by Jing Wei Li on 1/7/21.
//

import Foundation
import Vapor

class WebSocketManager {
    private var eventLoop: EventLoop
    private var storage: [UUID: ActiveConversation]
    private var jsonHelper: PipelineJSONHelperType
    
    var active: [WebSocket] {
        allWebSockets().filter { !$0.isClosed }
    }
    
    func isActive(id: UUID) -> Bool {
        storage[id] != nil
    }
    
    init(eventLoop: EventLoop,
         jsonHelper: PipelineJSONHelperType = appContainer.resolve(),
         conversations: [UUID: ActiveConversation] = [:])
    {
        self.eventLoop = eventLoop
        storage = conversations
        self.jsonHelper = jsonHelper
    }
    
    func add(_ id: UUID, convo: ActiveConversation) {
        storage[id] = convo
        convo.onAllClientsDisconnectCallback = { [weak self] convo in
            if let pair = self?.storage.first(where: { $0.value === convo }) {
                self?.storage.removeValue(forKey: pair.key)
            }
        }
    }
    
    func find(_ uuid: UUID) -> ActiveConversation? {
        storage[uuid]
    }
    
    func send(message: ConversationEntry, to id: UUID) throws {
        if let convo = find(id) {
            try convo.activeSockets.forEach { socket in
                let data = try jsonHelper.encoder.encode(message)
                guard let str = String(data: data, encoding: .utf8) else {
                    throw Abort(.internalServerError)
                }
                socket.send(str)
            }
        }
    }
    
    deinit {
        let futures = allWebSockets().map { $0.close() }
        try! eventLoop.flatten(futures).wait()
    }
    
    private func allWebSockets() -> [WebSocket] {
        storage.values
            .map { $0.activeSockets }
            .reduce([], +)
    }
}

extension ByteBuffer {
    func decode<T: Codable>(
        _ type: T.Type,
        jsonHelper: PipelineJSONHelperType = appContainer.resolve()) -> T?
    {
        try? jsonHelper.decoder.decode(T.self, from: self)
    }
    
    func decode<T: Codable>(
        _ type: T.Type,
        jsonHelper: PipelineJSONHelperType = appContainer.resolve()) throws -> T
    {
        try jsonHelper.decoder.decode(T.self, from: self)
    }
}

class ActiveConversation {
    var active: [(UUID, WebSocket)]
    
    var activeSockets: [WebSocket] {
        active.map { $0.1 }
    }
    
    var onAllClientsDisconnectCallback: ((ActiveConversation) -> Void)?
    
    init(initiator: WebSocket, originatingUserID: UUID) {
        active = [(originatingUserID, initiator)]
        handleSocketClose(ws: initiator)
    }
    
    func addClient(_ client: WebSocket, originatingUserID: UUID) {
        if !active.map({ $0.0 }).contains(originatingUserID) {
            active.append((originatingUserID, client))
        }
        handleSocketClose(ws: client)
    }
    
    private func handleSocketClose(ws: WebSocket) {
        ws.onClose.whenComplete { [weak self] res in
            guard let self = self else { return }
            switch res {
            case .success(_):
                self.active.removeAll(where: { $0.1 === ws })
                if self.active.isEmpty {
                    self.onAllClientsDisconnectCallback?(self)
                }
            case .failure(let error):
                PPL_LOG_ERROR(.websocketDisconnectError, error)
            }
        }
    }
}

