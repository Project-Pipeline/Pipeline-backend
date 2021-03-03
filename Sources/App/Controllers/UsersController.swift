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
        
        // MARK: - Authorization-required endpoints
        
        routes.get("api", "user", "info") { req -> EventLoopFuture<User> in
            return try req.authorizeAndGetUser()
        }
        
        routes.get("api", "user", "search") { req -> EventLoopFuture<[User]> in
            let method = try req.queryParam(named: "method", type: String.self)
            let query = try req.queryParam(named: "query", type: String.self)
            
            return try req
                .authorize()
                .flatMap { _ in
                    guard let searchMethod = UserSearchMethod(rawValue: method) else {
                        return req.eventLoop.future([])
                    }
                    switch searchMethod {
                    case .email:
                        return User.query(on: req.db)
                            .filter(\.$email =~ query) // =~ is the contains operator
                            .all()
                    case .name:
                        return User.query(on: req.db)
                            .group(.or) {
                                $0.filter(\.$givenName =~ query).filter(\.$familyName =~ query)
                            }
                            .all()
                    }
                }
        }
        
        // MARK: - User Details
        let userDetailsGrouped = routes.grouped("api", "user", "details")
        
        userDetailsGrouped.get() { req -> EventLoopFuture<[UserDetails]> in
            try req
                .authorizeAndGetUser()
                .flatMap { $0.$userDetails.get(on: req.db) }
        }
        
        userDetailsGrouped.post() { req -> EventLoopFuture<ServerResponse> in
            let userDetails = try req.content.decode(UserDetails.self)
            return try req
                .authorize()
                .flatMap { _ in
                    userDetails.save(on: req.db)
                }
                .transform(to: ServerResponse.defaultSuccess)
        }
        
        // MARK: - Opportunities
        let opportunities = routes.grouped("api", "user", "opportunities")
        
        // Post method is in Opportunites Controller
        opportunities.get() { req -> EventLoopFuture<Page<Opportunity>> in
            try req
                .authorizeAndGetUser()
                .flatMap { $0.$opportunities.query(on: req.db).paginate(for: req) }
        }
        
        // MARK: - Posts
        let posts = routes.grouped("api", "user", "posts")
        
        posts.get() { req -> EventLoopFuture<Page<Post>> in
            let userID = try req.queryParam(named: "id", type: UUID.self)
            return User.find(userID, on: req.db)
                .unwrap(or: "No posts found for this user")
                .flatMap { $0.$posts.query(on: req.db).paginate(for: req) }
        }
    }
}
