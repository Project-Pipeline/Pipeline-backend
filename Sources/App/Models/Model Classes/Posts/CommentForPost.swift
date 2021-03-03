//
//  CommentForPost.swift
//  
//
//  Created by Jing Wei Li on 2/27/21.
//

import Foundation
import Vapor
import Fluent

final class CommentForPost: Model, Content {
    @Parent(key: "postID")
    var post: Post
    @ID
    var id: UUID?
}

extension CommentForPost: Migratable {
    static var schema: String {
        "CommentForPost"
    }
    
    static var fields: [FieldForMigratable] {
        [
            .init("postID", .uuid, true, .references("Post", "id"))
        ]
    }
}
