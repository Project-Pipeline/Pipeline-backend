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
        // api/posts
        let postsGrouped = routes.grouped("api", "posts")
        postsGrouped.post(use: createPost)
        postsGrouped.delete(use: deletePost)
        postsGrouped.get(use: getPosts)
        
        // api/posts/category
        let categoryGrouped = postsGrouped.grouped("category")
        categoryGrouped.get(use: getAllCategories)
        
        // api/posts/comment
        let commentsGrouped = postsGrouped.grouped("comment")
        commentsGrouped.post(use: addComment)
        commentsGrouped.get {
            try self.getChildrenForPost(req: $0, getChildren: { $0.$comments })
        }
        
        // api/posts/like
        let likesGrouped = postsGrouped.grouped("like")
        likesGrouped.post(use: addLike)
        likesGrouped.get {
            try self.getChildrenForPost(req: $0, getChildren: { $0.$likes })
        }
    }
    
    // MARK: - Create
    
    func createPost(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let postAndCategory = try req.content.decode(PostAndCategoryWrapper.self)
        return try req
            .authorize()
            .flatMap { _ in
                postAndCategory.category.saveIfNew(on: req)
            }
            .flatMap { _ in
                postAndCategory.post.save(on: req.db).transform(to: .created)
            }
    }
    
    // MARK: - Get
    /// Gets posts
    /// - query parameters:
    ///   - no query params: All posts, paginated
    ///   - a comma separated list of categories e.g. `category=school,student`:  returns posts belonging to these categories
    func getPosts(req: Request) throws -> EventLoopFuture<Page<Post>> {
        let categories = try? req.commaSeparatedQueryParam(named: "category")
        return try req.authorize().flatMap { _ in
            if let categories = categories {
                let futures = categories.map { categoryId in
                    return CategoryForPost
                        .find(categoryId, on: req.db)
                        .flatMap { cat -> EventLoopFuture<Page<Post>> in
                            if let cat = cat {
                                return cat.$posts.query(on: req.db).paginate(for: req)
                            }
                            return req.eventLoop.future(.empty)
                        }
                }
                return req.eventLoop
                    .flatten(futures)
                    .map { $0.reduce(.empty, +)}
            }
            return Post.query(on: req.db).paginate(for: req)
        }
    }
    
    func getAllCategories(req: Request) throws -> EventLoopFuture<[CategoryForPost]> {
        try req.authorize().flatMap { _ in
            CategoryForPost.query(on: req.db).all()
        }
    }
    
    
    // MARK: - Delete
    func deletePost(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let id = try req.queryParam(named: "id", type: UUID.self)
        return try req
            .authorize()
            .flatMap { _ in
                Post.find(id, on: req.db)
                    .unwrap(or: "Cannot find post")
                    .flatMap({ $0.delete(on: req.db) })
                    .transform(to: .noContent)
            }
    }
    
    // MARK: - Comments
    func addComment(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let comment = try req.content.decode(CommentForPost.self)
        return try req.authorize().flatMap { _ in
            comment.save(on: req.db).transform(to: .created)
        }
    }
    
    
    // MARK: - Likes
    func addLike(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let like = try req.content.decode(LikeForPost.self)
        return try req.authorize().flatMap { _ in
            like.save(on: req.db).transform(to: .created)
        }
    }
    
    // MARK: - Misc
    func getChildrenForPost<T: Model>(
        req: Request,
        getChildren: @escaping (Post) -> ChildrenProperty<Post, T>
    ) throws -> EventLoopFuture<Page<T>> {
        let postId = try req.queryParam(named: "postId", type: UUID.self)
        return try req.authorize().flatMap { _ in
            Post.find(postId, on: req.db)
                .flatMap { post in
                    if let post = post {
                        return getChildren(post).query(on: req.db).paginate(for: req)
                    }
                    return req.eventLoop.future(.empty)
                }
        }
    }
    
}
