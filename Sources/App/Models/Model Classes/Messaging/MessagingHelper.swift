//
//  MessagingHelper.swift
//  
//
//  Created by Jing Wei Li on 1/9/21.
//

import Foundation
import Vapor

enum MessagingHelper {
    /// Add a message id to a single user
    /// - Parameters:
    ///   - id: id of the message
    ///   - userID: id of the user
    private static func addMessageWithID(
        _ id: UUID,
        toUserID userID: UUID,
        on req: Request) -> EventLoopFuture<Void>
    {
        User.find(userID, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { foundUser in
                foundUser.messages.append(id)
                return foundUser.save(on: req.db)
            }
    }
    
    /// add the message id to all participating users
    static func addMessageID(
        _ messageID: UUID,
        toUsers userIDs: [UUID],
        on req: Request) -> EventLoopFuture<Void>
    {
        let requests = userIDs.map {
            MessagingHelper.addMessageWithID(messageID, toUserID: $0, on: req)
        }
        return req.eventLoop.flatten(requests)
    }

}
