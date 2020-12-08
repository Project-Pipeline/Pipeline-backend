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
    /// Returns the user's email
    func authorize() throws -> String {
        let payload = try jwt.verify(as: AccessTokenPayload.self)
        return payload.userEmail
    }
    
    func authorizeAndGetUser() throws -> EventLoopFuture<User> {
        let email = try authorize()
        return User
            .query(on: db)
            .filter(\.$email == email)
            .first()
            .unwrap(or: PipelineError(message: "No user matching email \(email)"))
    }
}


