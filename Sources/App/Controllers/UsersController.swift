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
        router.post("api", "user", "create") { req -> Future<ServerResponse> in
            return try req.content
                .decode(User.self)
                .flatMap(to: String.self) { user in
                    let client = try req.make(MongoClient.self)
                    let users = client.collection(for: User.self)
                    let result = try users.insertOne(user)
                    if let result = result {
                        print(result)
                    }
                    return req.future("")
                }
                .transform(to: ServerResponse.defaultSuccess)
        }
        
        router.post("api", "user", "login") { req -> Future<JWTToken> in
            return try req.content
                .decode(UserEmail.self)
                .flatMap { userEmail -> Future<JWTToken> in
                    let client = try req.make(MongoClient.self)
                    let users = client.collection(for: User.self)
                    guard let matchedUser = try users.find().filter({ $0.email == userEmail.email }).first else {
                        throw PipelineError(message: "No user matching email \(userEmail.email)")
                    }
                    
                    let key = try readStringFromFile(named: "jwtKey.key", isPublic: false)
                    let data = try JWT(payload: matchedUser).sign(using: .hs256(key: key))
                    guard let string =  String(data: data, encoding: .utf8) else {
                        throw Abort(.internalServerError)
                    }
                    return req.future(JWTToken(token: string))
                }
        }
        
        router.post("api", "user", "exists") { req -> Future<UserExistence> in
            return try req.content
                .decode(UserEmail.self)
                .flatMap { userEmail -> Future<UserExistence> in
                    let client = try req.make(MongoClient.self)
                    let users = client.collection(for: User.self)
                    let attempt = try users.find().filter({ $0.email == userEmail.email }).first
                    let exists = attempt != nil
                    return req.future(UserExistence(email: userEmail.email, exists: exists))
                }
        }
    }
}
