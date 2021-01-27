//
//  User.swift
//  App
//
//  Created by Jing Wei Li on 8/1/20.
//

import Foundation
import Vapor
import Fluent

struct UserEmail: Codable {
    let email: String
}

struct UserExistence: Content {
    let email: String
    let exists: Bool
}

final class User: Codable, Content, Model {
    @ID
    var id: UUID?
    @Field(key: "email")
    var email: String
    @Field(key: "givenName")
    var givenName: String
    @Field(key: "familyName")
    var familyName: String
    @Field(key: "picture")
    var picture: String
    @Field(key: "entityBelongedTo")
    var entityBelongedTo: String
    @Field(key: "entityName")
    var entityName: String
    @Field(key: "industryType")
    var industryType: String
    @Field(key: "industry")
    var industry: String
    @Field(key: "messages")
    var messages: [UUID]
}

// MARK: - Migration

extension User: Migratable {
    static var schema: String {
        "User"
    }
    
    static var idRequired: Bool {
        true
    }
    
    static var fields: [FieldForMigratable] {
        [
            .init("email", .string),
            .init("givenName", .string),
            .init("familyName", .string),
            .init("picture", .string),
            .init("entityBelongedTo", .string),
            .init("entityName", .string),
            .init("industryType", .string),
            .init("industry", .string),
            .init("messages", .array(of: .uuid))
        ]
    }
}

enum UserSearchMethod: String {
    case email = "email"
    case name = "name"
}
