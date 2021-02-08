//
//  UserDetails.swift
//  
//
//  Created by Jing Wei Li on 2/1/21.
//

import Foundation
import Vapor
import Fluent

final class UserDetails: Content, Model {
    @Parent(key: "userID")
    var user: User
    @ID
    var id: UUID?
    // MARK: - Common
    @Field(key: "links")
    var links: [DescriptionDetailPair]
    @Field(key: "phone-numbers")
    var phoneNumbers: [DescriptionDetailPair]
    @Field(key: "background-image")
    var backgroundImage: URL?
    @Field(key: "biography")
    var biography: String?
    @Field(key: "public-id")
    var publicID: String
    @Field(key: "additional-info")
    var additionalInfo: [DescriptionDetailPair]
    // MARK: - Entity Only
    @Field(key: "date-founded")
    var dateFounded: Date?
    @Field(key: "address")
    var address: Address?
    // MARK: - Individual Only
    @Field(key: "dob")
    var dob: Date?
    @Field(key: "gender")
    var gender: Int?
    @Field(key: "profession")
    var profession: String?
}

struct DescriptionDetailPair: Content {
    let description: String
    let detail: String
}

struct Address {
    let components: [String]
    let latitude: Double
    let longitude: Double
    let postalCode: String?
}

// MARK: - Migrations
extension UserDetails: Migratable {
    static var schema: String {
        "UserDetails"
    }
    
    static var idRequired: Bool {
        true
    }
    
    static var fields: [FieldForMigratable] {
        [
            .init("userID", .uuid, true, .references("User", "id")),
            .init("links", .array(of: .dictionary)),
            .init("public-id", .string),
            .init("phone-numbers", .array(of: .dictionary)),
            .init("background-image", .string),
            .init("additional-info", .array(of: .dictionary)),
            .init("date-founded", .date),
            .init("address", .dictionary),
            .init("dob", .date),
            .init("gender", .int64),
            .init("profession", .string)
        ]
    }
}

