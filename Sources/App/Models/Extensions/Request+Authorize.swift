//
//  Request+Authorize.swift
//  App
//
//  Created by Jing Wei Li on 9/13/20.
//

import Foundation
import Vapor
import JWT
import MongoSwift

extension Request {
    func authorize() throws -> String {
        guard let bearer = self.http.headers.bearerAuthorization else {
            throw Abort(.unauthorized)
        }
        let key = try readStringFromFile(named: "jwtKey.key", isPublic: false)
        let signer = JWTSigner.hs256(key: key)
        let payload = try JWT<AccessTokenPayload>(from: bearer.token, verifiedUsing: signer)
        return payload.payload.userEmail
    }
    
    func authorizeAndGetUser() throws -> Future<User> {
        let email = try authorize()
        return User.query(on: self)
            .all()
            .flatMap { user -> Future<User> in
                guard let user = user.filter({ $0.email == email }).first else {
                    throw PipelineError(message: "")
                }
                return self.future(user)
            }
    }
}


