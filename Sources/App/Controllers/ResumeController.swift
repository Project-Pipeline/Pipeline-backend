//
//  ResumeController.swift
//  
//
//  Created by Jing Wei Li on 4/2/21.
//

import Foundation
import Vapor
import Fluent

struct ResumeController: RouteCollection {
    enum Operation {
        case create
        case update
    }
    
    func boot(routes: RoutesBuilder) throws {
        let resumeGrouped = routes.grouped("api", "resume")
        resumeGrouped.post { try self.resumeAction(req: $0, operation: .create) }
        resumeGrouped.delete(use: deleteResume)
        
        let resumeUpdate = routes.grouped("api", "resume", "update")
        resumeUpdate.post { try self.resumeAction(req: $0, operation: .update) }
    }
    
    func resumeAction(req: Request, operation: Operation) throws -> EventLoopFuture<HTTPStatus> {
        let resume = try req.content.decode(Resume.self)
        return try req
            .authorize()
            .flatMap { _ -> EventLoopFuture<Void> in
                switch operation {
                case .create:
                    return resume.save(on: req.db)
                case .update:
                    return resume.update(on: req.db)
                }
            }
            .transform(to: .created)
    }
    
    func deleteResume(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let resumeId = try req.queryParam(named: "id", type: UUID.self)
        return try req
            .authorizeAndGetUser()
            .flatMap { user in
                Resume.find(resumeId, on: req.db)
                    .unwrap(or: Abort(.badRequest))
                    .flatMap { resume in
                        // verify that the resume's parent user matches the user sending the request
                        resume.$user.get(on: req.db).flatMapThrowing { parent -> String in
                            guard parent.id == user.id else {
                                throw Abort(.unauthorized)
                            }
                            return ""
                        }
                        .flatMap { _ in
                            resume.delete(on: req.db)
                        }
                    }
                    .transform(to: .noContent)
            }
    }
}
