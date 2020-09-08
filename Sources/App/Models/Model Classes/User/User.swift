//
//  User.swift
//  App
//
//  Created by Jing Wei Li on 8/1/20.
//

import Foundation
import Vapor
import FluentSQLite
import JWT

struct UserEmail: Codable {
    let email: String
}

struct UserExistence: Content {
    let email: String
    let exists: Bool
}

struct User: Codable {
    let email: String
    let givenName: String
    let familyName: String
    let picture: URL
    let entityBelongedTo: String
    let entityName: String
    let industryType: String
    let industry: String
    var id: Int?
}

extension User: Model {
    typealias Database = SQLiteDatabase
    typealias ID = Int
    public static var idKey: IDKey = \User.id
}

extension User: Content, Migration, Parameter {
    
}

extension User: JWTPayload {
    func verify(using signer: JWTSigner) throws {
        
    }
}
