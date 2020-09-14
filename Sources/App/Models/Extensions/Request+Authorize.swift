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
    
    func authorizeAndGetUser() throws -> User {
        let email = try authorize()
        let client = try make(MongoClient.self)
        let users = client.collection(for: User.self)
        guard let user = try users.find().filter({ $0.email == email }).first else {
            throw PipelineError(message: "User \(email) does not exist")
        }
        return user
    }
}


