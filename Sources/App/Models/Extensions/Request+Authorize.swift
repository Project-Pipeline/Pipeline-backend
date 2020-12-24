//
//  Request+Authorize.swift
//  App
//
//  Created by Jing Wei Li on 9/13/20.
//

import Foundation
import Vapor
import JWT
import Fluent

extension Request {
    /// Returns the user's email asynchronously
    func authorize() throws -> EventLoopFuture<String> {
        guard let idToken = headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized)
        }
        return try client
            .get("https://oauth2.googleapis.com/tokeninfo?id_token=\(idToken)")
            .decodeResponse(typed: IdTokenPayload.self) { self.eventLoop.future($0) }
            .flatMapThrowing { token in
                guard let clientID = Environment.get("GOOGLE_CLIENT_ID"),
                      token.aud == clientID,
                      let email = token.emxail else {
                    throw Abort(.unauthorized)
                }
                return email
            }
    }
    
    func authorizeAndGetUser() throws -> EventLoopFuture<User> {
        return try authorize()
            .flatMap { email -> EventLoopFuture<User?> in
                User
                    .query(on: self.db)
                    .filter(\.$email == email)
                    .first()
            }
            .unwrap(or: PipelineError(message: "No user match given email was found"))
    }
}


