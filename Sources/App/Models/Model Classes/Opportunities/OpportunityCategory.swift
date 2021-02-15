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
    @ID
    var id: UUID?
    @Field(key: "name")
    var name: String
}

extension OpportunityCategory: Migratable {
    static var schema: String {
        "OpportunityCategory"
    }
    
    static var idRequired: Bool {
        true
    }
    
    static var fields: [FieldForMigratable] {
        [
            .init("name", .string)
        ]
    }
}
