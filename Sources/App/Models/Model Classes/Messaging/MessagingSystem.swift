//
//  MessagingSystem.swift
//  
//
//  Created by Jing Wei Li on 1/7/21.
//

import Foundation
import Vapor

class MessagingSystem {
    let eventLoop: EventLoop
    let websocketManager: WebSocketManager
    
    init(app: Application) {
        eventLoop = app.eventLoopGroup.next()
        websocketManager = WebSocketManager(eventLoop: eventLoop)
    }
    
    func connect(ws: WebSocket) {
        ws.onText {  [weak self] ws, string in
            guard let self = self else { return }
            
            // MARK: - connecting for the second time and onward
            if let connect = string.toJSONTyped(MessagingConnect.self) {
                print("connecting")
                if let activeConversation = self.websocketManager.find(connect.conversationID) {
                    // conversation already exists
                    activeConversation.addClient(ws, originatingUserID: connect.originatingUserID)
                   
                } else {
                    // conversation DNE
                    let convo = ActiveConversation(initiator: ws, originatingUserID: connect.originatingUserID)
                    self.websocketManager.add(connect.conversationID, convo: convo)
                }
            }
            
            // MARK: - sending/receiving a message
            if let conversation = string.toJSONTyped(ConversationEntry.self) {
                try? self.websocketManager.send(message: conversation, to: conversation.conversationBelongedTo)
            }
        }
    }
}
