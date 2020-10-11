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
import MongoSwift

struct UsersController: RouteCollection {
    func boot(router: Router) throws {
        // MARK: - User creation & login
        
        router.post("api", "user", "create") { req -> Future<ServerResponse> in
            return try req.content
                .decode(User.self)
                .flatMap(to: User.self, { $0.create(on: req) })
                .transform(to: ServerResponse.defaultSuccess)
        }
        
        router.post("api", "user", "login") { req -> Future<JWTToken> in
            return try req.content
                .decode(UserEmail.self)
                .flatMap { user -> Future<JWTToken> in
                    return User
                        .query(on: req)
                        .filter(\.email == user.email)
                        .first()
                        .flatMap { matchedUser -> Future<JWTToken> in
                            guard let matchedUser = matchedUser else {
                                throw PipelineError(message: "No user matching email \(user.email)")
                            }
                            let key = try readStringFromFile(named: "jwtKey.key", isPublic: false)
                            let payload = AccessTokenPayload(userEmail: matchedUser.email)
                            let data = try JWT(payload: payload).sign(using: .hs256(key: key))
                            guard let string =  String(data: data, encoding: .utf8) else {
                                throw Abort(.internalServerError)
                            }
                            return req.future(JWTToken(token: string))
                        }
                }
        }
        
        router.post("api", "user", "exists") { req -> Future<UserExistence> in
            return try req.content
                .decode(UserEmail.self)
                .flatMap { user -> Future<UserExistence> in
                    return User.query(on: req)
                        .filter(\.email == user.email)
                        .first()
                        .flatMap { attempt -> Future<UserExistence> in
                            let exists = attempt != nil
                            return req.future(UserExistence(email: user.email, exists: exists))
                        }
                }
        }
        
        // MARK: - JWT-required endpoints
        
        router.get("api", "user", "info") { req -> Future<User> in
            return try req.authorizeAndGetUser()
        }
    }
}
