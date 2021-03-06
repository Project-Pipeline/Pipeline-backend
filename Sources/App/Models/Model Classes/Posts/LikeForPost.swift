//
//  LikeForPost.swift
//  
//
//  Created by Jing Wei Li on 2/27/21.
//

import Foundation
import Vapor
import Fluent

/// A like on a post
final class LikeForPost: Model, Content {
    @Parent(key: "postID")
    var post: Post
    @ID
    var id: UUID?
    @Timestamp(key: "modified", on: .create, format: .iso8601)
    var modified: Date?
    @Timestamp(key: "created", on: .create, format: .iso8601)
    var created: Date?
    @Field(key: "userId")
    var userID: UUID
    @Field(key: "nameOfUser")
    var nameOfUser: String
}

extension LikeForPost: Migratable {
    static var schema: String {
        "LikeForPost"
    }
    
    static var fields: [FieldForMigratable] {
        [
            .init("postID", .uuid, true, .references("Post", "id")),
            .init("modified", .string),
            .init("created", .string),
            .init("userId", .uuid),
            .init("nameOfUser", .string)
        ]
    }
}

