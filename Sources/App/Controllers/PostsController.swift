//
//  PostsController .swift
//  
//
//  Created by Jing Wei Li on 2/27/21.
//

import Foundation
import Vapor
import Fluent

struct PostsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let postsGrouped = routes.grouped("api", "posts")
        postsGrouped.post(use: createPost)
        
        postsGrouped.post("category", use: createCategoryForPost)
    }
    
    func createCategoryForPost(req: Request) throws -> EventLoopFuture<CategoryForPost> {
        let category = try req.content.decode(CategoryForPost.self)
        return try req.authorize().flatMap { _ in
            category
                .saveIfNew(on: req)
                .map { _ in category }
        }
    }
    
    func createPost(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let post = try req.content.decode(Post.self)
        return try req.authorize().flatMap { _ in
            post.save(on: req.db).transform(to: .created)
        }
    }
}
