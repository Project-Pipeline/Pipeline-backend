//
//  CategoryForPost.swift
//  
//
//  Created by Jing Wei Li on 2/27/21.
//

import Foundation
import Fluent
import Vapor

/// Unused  due to a bug w/ sibling relationship pagination
final class CategoryForPost: Model, Content {
    @ID(custom: "id")
    var id: String?
    @Field(key: "name")
    var name: String
    @Children(for: \.$category)
    var posts: [Post]
}

extension CategoryForPost: Migratable {
    static var schema: String {
        "CategoryForPost"
    }
    
    static var fields: [FieldForMigratable] {
        [
            .init("name", .string)
        ]
    }
}

// MARK: - Unused
/// Unused due to a bug w/ sibling relationship pagination
/*
final class CategoryForPost2: Model, Content {
    @ID(custom: "id")
    var id: String?
    @Field(key: "name")
    var name: String
    @Siblings(
        through: CategoryForPostPivot.self,
        from: \.$category,
        to: \.$post)
    var posts: [Post]
}

extension CategoryForPost2: Migratable {
    static var schema: String {
        "CategoryForPost2"
    }
    
    static var fields: [FieldForMigratable] {
        [
            .init("name", .string)
        ]
    }
}
 */

