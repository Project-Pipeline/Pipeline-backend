//
//  CategoryForPostPivot.swift
//  
//
//  Created by Jing Wei Li on 2/27/21.
//

import Foundation
import Fluent
import Vapor

/// Unused  due to a bug w/ sibling relationship pagination
/*
final class CategoryForPostPivot: Model, Content {
    @ID
    var id: UUID?
    @Parent(key: "postId")
    var post: Post
    @Parent(key: "category4PostId")
    var category: CategoryForPost
    
    init() { }
    
    init(
        id: UUID? = nil,
        post: Post,
        category: CategoryForPost
    ) throws {
        self.id = id
        self.$post.id = try post.requireID()
        self.$category.id = try category.requireID()
    }
}

extension CategoryForPostPivot: Migratable {
    static var schema: String {
        "CategoryForPostPivot"
    }
    
    static var fields: [FieldForMigratable] {
        [
            .init("category4PostId", .string, true, .references("CategoryForPost", "id", onDelete: .cascade)),
            .init("postId", .uuid, true, .references("Post", "id", onDelete: .cascade))
        ]
    }
}
 */
