//
//  UsersController.swift
//  App
//
//  Created by Jing Wei Li on 9/6/20.
//

import Foundation
import Vapor
import Fluent
import JWT

struct UsersController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // MARK: - User creation & login
        
        routes.post("api", "user", "create") { req -> EventLoopFuture<ServerResponse> in
            let user = try req.content.decode(User.self)
            return user
                .save(on: req.db)
                .transform(to: ServerResponse.defaultSuccess)
        }
        
        routes.post("api", "user", "login") { req -> EventLoopFuture<JWTToken> in
            let email = try req.content.decode(UserEmail.self)
            return User
                .query(on: req.db)
                .filter(\.$email == email.email)
                .first()
                .unwrap(orError: PipelineError(message: "No user matching email \(email.email)"))
                .flatMapThrowing { user -> String in
                    let payload = AccessTokenPayload(userEmail: user.email)
                    return try req.jwt.sign(payload)
                }
                .flatMap { token -> EventLoopFuture<JWTToken> in
                    return req.eventLoop.future(JWTToken(token: token))
                }
        }
        
        routes.post("api", "user", "exists") { req -> EventLoopFuture<UserExistence> in
            let email = try req.content.decode(UserEmail.self)
            return User
                .query(on: req.db)
                .filter(\.$email == email.email)
                .first()
                .flatMap { attempt -> EventLoopFuture<UserExistence> in
                    req.eventLoop.future(UserExistence(email: email.email, exists: attempt != nil))
                }
        }
        
        // MARK: - JWT-required endpoints
        
        routes.get("api", "user", "info") { req -> EventLoopFuture<User> in
            return try req.authorizeAndGetUser()
        }
    }
}
