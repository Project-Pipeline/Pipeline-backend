//
//  WebSocketManager.swift
//  
//
//  Created by Jing Wei Li on 1/7/21.
//

import Foundation
import Vapor

class WebSocketManager {
    var eventLoop: EventLoop
    var storage: [UUID: ActiveConversation]
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
    }
    
    func remove(_ id: UUID) {
        storage[id] = nil
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
    var activeSockets: [WebSocket]
    var activeUsers: [UUID]
    
    init(initiator: WebSocket, originatingUserID: UUID) {
        activeSockets = [initiator]
        activeUsers = [originatingUserID]
    }
    
    func addClient(_ client: WebSocket, originatingUserID: UUID) {
        if !activeUsers.contains(originatingUserID) {
            activeSockets.append(client)
            activeUsers.append(originatingUserID)
        }
    }
}

