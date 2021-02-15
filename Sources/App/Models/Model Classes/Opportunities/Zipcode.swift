//
//  Zipcode.swift
//  
//
//  Created by Jing Wei Li on 2/13/21.
//

import Foundation
import Fluent
import Vapor

final class Zipcode: Model, Content {
    /// ID is the zip code
    @ID(custom: "id")
    var id: String?
    @Siblings(
        through: ZipcodePivot.self,
        from: \.$zipcode,
        to: \.$opportunity)
    var opportunities: [Opportunity]
}

extension Zipcode: Migratable {
    static var schema: String {
        "Zipcode"
    }
    
    static var idRequired: Bool { true }
    
    static var fields: [FieldForMigratable] { [] }
}
