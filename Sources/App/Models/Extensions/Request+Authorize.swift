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
    /// Ensures the user has the permission to access the site.
    /// - Returns: Returns the user's email asynchronously by making a call to google's tokenInfo endpoint
    /// - If the request is not authorized, it will return a 401 unauthorized status code
    func authorize() throws -> EventLoopFuture<String> {
        guard let idToken = headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized)
        }
        return try authorizeWithToken(idToken, client: client, eventLoop: eventLoop)
    }
    
    func authorize(with token: String) throws -> EventLoopFuture<String> {
        try authorizeWithToken(token, client: client, eventLoop: eventLoop)
    }
    
    private func authorizeWithToken(_ token: String, client: Client, eventLoop: EventLoop) throws -> EventLoopFuture<String> {
        return try client
            .get("https://oauth2.googleapis.com/tokeninfo?id_token=\(token)")
            .decodeResponse(typed: IdTokenPayload.self) { eventLoop.future($0) }
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


