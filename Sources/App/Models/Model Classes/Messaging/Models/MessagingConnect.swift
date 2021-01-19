//
//  MessagingConnect.swift
//  
//
//  Created by Jing Wei Li on 1/10/21.
//

import Foundation
import Vapor

/// The data the client send to the server to start the messaging process
struct MessagingConnect: Content {
    /// ID of the conversation
    let conversationID: UUID
    let originatingUserID: UUID
}

/// The data the server send to the client to acknowledge that the connection has been established
struct MessagingConnectionEstablished: Content {
    let connectionEstablished: Bool
}

extension WebSocket {
    /// Send to the client an acknowledgement that the connection has been established
    /// - Why?: b/c the server takes time to verify the auth token from the connection, we need to send a separate acknowledgement to the client
    /// after the auth has succeeded
    func acknowledgeConnectionEstablished() throws {
        let jsonHelper: PipelineJSONHelperType = appContainer.resolve()
        let data = try jsonHelper.encoder.encode(MessagingConnectionEstablished(connectionEstablished: true))
        guard let str = String(data: data, encoding: .utf8) else {
            throw Abort(.internalServerError)
        }
        send(str)
    }
}
