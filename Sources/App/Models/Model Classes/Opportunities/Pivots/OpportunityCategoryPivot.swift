//
//  OpportunityCategoryPivot.swift
//  
//
//  Created by Jing Wei Li on 2/13/21.
//

import Foundation
import Fluent
import Vapor

/// Pivot between `Opportunity` and `OpportunityCategory`
final class OpportunityCategoryPivot: Model, Content {
    @ID
    var id: UUID?
    @Parent(key: "opportunityId")
    var opportunity: Opportunity
    @Parent(key: "opportunityCategoryId")
    var category: OpportunityCategory
    
    init() { }
    
    init(
        id: UUID? = nil,
        opportunity: Opportunity,
        category: OpportunityCategory
    ) throws {
        self.id = id
        self.$category.id = try category.requireID()
        self.$opportunity.id = try opportunity.requireID()
    }
}

extension OpportunityCategoryPivot: Migratable {
    static var schema: String {
        "OpportunityCategoryPivot"
    }
    
    static var fields: [FieldForMigratable] {
        [
            .init("opportunityId", .uuid, true, .references("Opportunity", "id", onDelete: .cascade)),
            .init("opportunityCategoryId", .string, true, .references("OpportunityCategory", "id", onDelete: .cascade))
        ]
    }
    
}
