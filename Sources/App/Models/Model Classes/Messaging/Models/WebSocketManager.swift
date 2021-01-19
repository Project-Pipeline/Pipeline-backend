//
//  WebSocketManager.swift
//  
//
//  Created by Jing Wei Li on 1/7/21.
//

import Foundation
import Vapor
import Fluent

// MARK: - Web Socket Manager
class WebSocketManager {
    private var eventLoop: EventLoop
    /// identified by conversation's id
    private var storage: [UUID: ActiveConversation]
    /// identified by conversation's id
    private var ongoingMessages: [UUID: [ConversationEntry]]
    private var jsonHelper: PipelineJSONHelperType
    private var db: Database
    
    var active: [WebSocket] {
        allWebSockets().filter { !$0.isClosed }
    }
    
    func isActive(id: UUID) -> Bool {
        storage[id] != nil
    }
    
    init(eventLoop: EventLoop,
         database: Database,
         jsonHelper: PipelineJSONHelperType = appContainer.resolve(),
         conversations: [UUID: ActiveConversation] = [:])
    {
        self.eventLoop = eventLoop
        storage = conversations
        self.jsonHelper = jsonHelper
        ongoingMessages = [:]
        self.db = database
    }
    
    /// Conversation hasn't existed before
    func add(_ id: UUID, convo: ActiveConversation) {
        storage[id] = convo
        convo.onClientJoinCallback = { [weak self] ws, id in
            self?.handleClientJoin(id: id, ws: ws)
        }
        convo.onAllClientsDisconnectCallback = { [weak self] convo in
            if let pair = self?.storage.first(where: { $0.value === convo }) {
                let convesrationID = pair.key
                self?.storage.removeValue(forKey: convesrationID)
                self?.uploadMessages(for: convesrationID)
            }
        }
    }
    
    func find(_ uuid: UUID) -> ActiveConversation? {
        storage[uuid]
    }
    
    func send(message: ConversationEntry, to id: UUID) throws {
        if let convo = find(id) {
            try convo.activeSockets.forEach { [weak self] socket in
                try self?.send(message: message, to: socket)
            }
            // maintain ongoing conversations
            if let messages = ongoingMessages[id] {
                var new = messages
                new.append(message)
                ongoingMessages[id] = new
            } else {
                ongoingMessages[id] = [message]
            }
        }
    }
    
    deinit {
        let futures = allWebSockets().map { $0.close() }
        try! eventLoop.flatten(futures).wait()
    }
    
    private func send(message: ConversationEntry, to socket: WebSocket) throws {
        let data = try jsonHelper.encoder.encode(message)
        guard let str = String(data: data, encoding: .utf8) else {
            throw Abort(.internalServerError)
        }
        socket.send(str)
    }
    
    private func allWebSockets() -> [WebSocket] {
        storage.values
            .map { $0.activeSockets }
            .reduce([], +)
    }
    
    /// upload the ongoing msgs to db, then remove ongoing msgs from storage
    private func uploadMessages(for id: UUID) {
        guard let messages = ongoingMessages[id], !messages.isEmpty else {
            ongoingMessages.removeValue(forKey: id)
            return
        }
        eventLoop
            .flatten([
                Conversation.find(id, on: db)
                    .unwrap(or: Abort(.badRequest))
                    .flatMap { convo -> EventLoopFuture<Void> in
                        convo.entries.append(contentsOf: messages)
                        let latestTimestamp = messages.map { $0.timeStamp }.max() ?? 0
                        if latestTimestamp > convo.modified {
                            convo.modified = latestTimestamp
                        }
                        return convo.save(on: self.db)
                    }
            ])
            .whenComplete { [weak self] status in
                switch status {
                case .success(_):
                    self?.ongoingMessages.removeValue(forKey: id)
                case .failure(let error):
                    PPL_LOG_ERROR(.generic, error)
                }
            }
    }
    
    /// When one client joins, we should send the messages already
    /// in the buffer (could be sent by someone else) to the client
    private func handleClientJoin(id: UUID, ws: WebSocket) {
        guard let msgs = ongoingMessages[id], !msgs.isEmpty else {
            return
        }
        do {
            try msgs.forEach { [weak self] msg in
                try self?.send(message: msg, to: ws)
            }
        } catch let err {
            PPL_LOG_ERROR(.unableToSendMessage, err)
        }
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

// MARK: - Active Covnersation

class ActiveConversation {
    var active: [(UUID, WebSocket)]
    
    var activeSockets: [WebSocket] {
        active.map { $0.1 }
    }
    
    /// When all clients disconnect we should remove them from memory and upload the messages to db
    var onAllClientsDisconnectCallback: ((ActiveConversation) -> Void)?
    /// When one client joins, we should send the messages already in the buffer (could be sent by someone else) to the client
    var onClientJoinCallback: ((WebSocket, UUID) -> Void)?
    
    init(initiator: WebSocket, originatingUserID: UUID) {
        active = [(originatingUserID, initiator)]
        handleSocketClose(ws: initiator)
    }
    
    func addClient(_ client: WebSocket, connect: MessagingConnect) {
        if !active.map({ $0.0 }).contains(connect.originatingUserID) {
            active.append((connect.originatingUserID, client))
        }
        onClientJoinCallback?(client, connect.conversationID)
        handleSocketClose(ws: client)
    }
    
    /// When socket closes, remove them from memory
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

