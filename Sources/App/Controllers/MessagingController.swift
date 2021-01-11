//
//  MessagingController.swift
//  
//
//  Created by Jing Wei Li on 1/10/21.
//

import Foundation
import Vapor
import Fluent

struct MessagingController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        
        routes.post("api", "messaging", "start") { req -> EventLoopFuture<ServerResponse> in
            let convo = try req.content.decode(Conversation.self)
            guard let messageID = convo.id else {
                throw Abort(.badRequest)
            }
            return try req
                .authorize()
                .flatMap { _ in
                    // first, add the message id to all participating users
                    MessagingHelper.addMessageID(messageID, toUsers: convo.participants, on: req)
                }
                .flatMap { _ in
                    // second, save the conversation in its standalone database
                    convo.save(on: req.db)
                }
                .transform(to: ServerResponse.defaultSuccess)
        }
        
        routes.post("api", "messaging", "conversation-details") { req -> EventLoopFuture<[Conversation]> in
            let messageIDs = try req.content
                .decode(StringArray.self).values
                .compactMap { UUID(uuidString: $0) }
            return try req
                .authorize()
                .flatMap { str -> EventLoopFuture<[Conversation]> in
                    Conversation
                        .query(on: req.db)
                        .group(.or) { filter in
                            messageIDs.forEach { msg in
                                filter.filter(\.$id == msg)
                            }
                        }
                        .all()
                }
            
        }
    }
}
