//
//  Opportunity.swift
//  
//
//  Created by Jing Wei Li on 2/13/21.
//

import Foundation
import Fluent
import Vapor

final class Opportunity: Model, Content {
    @ID
    var id: UUID?
    @Field(key: "name")
    var name: String
    @Field(key: "company-name")
    var companyName: String
    @Field(key: "overview")
    var overview: String
    @Field(key: "qualifications")
    var qualifications: [String]
    @Field(key: "responsibilities")
    var responsibilities: [String]
    @Field(key: "compensation")
    var compensation: String
    @Field(key: "is-full-time")
    var isFullTime: Bool
    @Field(key: "address")
    var address: Address
    @Field(key: "category")
    var category: String
    /// Unix timestamp
    @Field(key: "created")
    var created: Int
    /// Unix timestamp
    @Field(key: "due")
    var due: Int
    @Field(key: "state")
    var state: Int
    @Siblings(
        through: ZipcodePivot.self,
        from: \.$opportunity,
        to: \.$zipcode)
    var zipCodes: [Zipcode]
    @Siblings(
        through: OpportunityCategoryPivot.self,
        from: \.$opportunity,
        to: \.$category)
    var categories: [OpportunityCategory]
    @Parent(key: "userID")
    var user: User
}

extension Opportunity: Migratable {
    static var schema: String {
        "Opportunity"
    }
    
    static var fields: [FieldForMigratable] {
        [
            .init("userID", .uuid, true, .references("User", "id")),
            .init("name", .string),
            .init("company", .string),
            .init("company-name", .string),
            .init("overview", .string),
            .init("qualifications", .array(of: .string)),
            .init("responsibilities", .array(of: .string)),
            .init("compensation", .string),
            .init("is-full-time", .bool),
            .init("address", .dictionary),
            .init("category", .string),
            .init("created", .int),
            .init("due", .int),
            .init("state", .int)
        ]
    }
}

final class OpportunitiesContentsWrapper: Content {
    let opportunity: Opportunity
    let zipcode: Zipcode
    let category: OpportunityCategory
}

extension Opportunity: Hashable {
    static func == (lhs: Opportunity, rhs: Opportunity) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
