//
//  Post.swift
//  
//
//  Created by Jing Wei Li on 2/27/21.
//

import Foundation
import Fluent
import Vapor

final class Post: Model, Content {
    @Parent(key: "userID")
    var user: User
    @Parent(key: "categoryID")
    var category: CategoryForPost
    @ID
    var id: UUID?
    @Field(key: "title")
    var title: String?
    @Field(key: "body")
    var body: String
    @Timestamp(key: "modified", on: .create, format: .iso8601)
    var modified: Date?
    @Timestamp(key: "created", on: .create, format: .iso8601)
    var created: Date?
    @Field(key: "images")
    var images: [URL]
    @Field(key: "links")
    var links: [TitledLink]
    @Children(for: \.$post)
    var comments: [CommentForPost]
    @Children(for: \.$post)
    var likes: [LikeForPost]
    
}

extension Post: Migratable {
    static var schema: String {
        "Post"
    }
    
    static var fields: [FieldForMigratable] {
        [
            .init("userID", .uuid, true, .references("User", "id")),
            .init("categoryID", .string, true, .references("CategoryForPost", "id")),
            .init("title", .string),
            .init("body", .string, true),
            .init("modified", .string),
            .init("created", .string),
            .init("images", .array(of: .string)),
            .init("links", .array(of: .dictionary))
        ]
    }
}

struct TitledLink: Content {
    let title: String
    let link: URL
}

struct PostAndCategoryWrapper: Content {
    let post: Post
    let category: CategoryForPost
}
