//
//  LikeForPost.swift
//  
//
//  Created by Jing Wei Li on 2/27/21.
//

import Foundation
import Vapor
import Fluent

final class LikeForPost: Model, Content {
    @Parent(key: "postID")
    var post: Post
    @ID
    var id: UUID?
}

extension LikeForPost: Migratable {
    static var schema: String {
        "LikeForPost"
    }
    
    static var fields: [FieldForMigratable] {
        [
            .init("postID", .uuid, true, .references("Post", "id"))
        ]
    }
}

