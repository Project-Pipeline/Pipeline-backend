//
//  ZipcodePivot.swift
//  
//
//  Created by Jing Wei Li on 2/13/21.
//

import Foundation
import Vapor
import Fluent

/// Pivot between `Opportunity` and `Zipcode`
final class ZipcodePivot: Model, Content {
    @ID
    var id: UUID?
    @Parent(key: "opportunityId")
    var opportunity: Opportunity
    @Parent(key: "zipcodeId")
    var zipcode: Zipcode
    
    init() { }
    
    init(
        id: UUID? = nil,
        opportunity: Opportunity,
        zipcode: Zipcode
    ) throws {
        self.id = id
        self.$zipcode.id = try zipcode.requireID()
        self.$opportunity.id = try opportunity.requireID()
    }
}

extension ZipcodePivot: Migratable {
    static var schema: String {
        "zipcode-pivot"
    }
    
    static var idRequired: Bool {
        true
    }
    
    static var fields: [FieldForMigratable] {
        [
            .init("opportunityId", .uuid, true, .references("Opportunity", "id", onDelete: .cascade)),
            .init("zipcodeId", .string, true, .references("Zipcode", "id", onDelete: .cascade))
        ]
    }
}
