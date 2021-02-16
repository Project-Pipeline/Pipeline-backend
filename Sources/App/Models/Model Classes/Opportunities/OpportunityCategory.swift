//
//  OpportunityCategory.swift
//  
//
//  Created by Jing Wei Li on 2/13/21.
//

import Foundation
import Vapor
import Fluent

final class OpportunityCategory: Content, Model {
    /// - How the id is derived from `name`:
    ///   - Take the raw name e.g. "Agriculture, Food and Natural Resources",
    ///   - then remove all commas and spaces
    @ID(custom: "id")
    var id: String?
    @Field(key: "name")
    var name: String
    @Siblings(
        through: OpportunityCategoryPivot.self,
        from: \.$category,
        to: \.$opportunity)
    var opportunities: [Opportunity]
}

extension OpportunityCategory: Migratable {
    static var schema: String {
        "OpportunityCategory"
    }
    
    static var fields: [FieldForMigratable] {
        [
            .init("name", .string)
        ]
    }
}
