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
    /// Returns the user's email asynchronously by making a call to google's tokenInfo endpoint
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
                      let email = token.email else {
                    throw Abort(.unauthorized)
                }
                return email
            }
            .flatMapErrorThrowing { error in
                PPL_LOG_ERROR(.invalidJWT, error)
                throw "malformed JWT"
            }
    }
    
    func authorize<T>(_ next: @escaping (String) -> EventLoopFuture<T>) throws -> EventLoopFuture<T> {
        try authorize().flatMap { next($0) }
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
    
    func authorizeAndGetUser<T>(_ next: @escaping (User) -> EventLoopFuture<T>) throws -> EventLoopFuture<T> {
        try authorizeAndGetUser().flatMap { next($0) }
    }
}


