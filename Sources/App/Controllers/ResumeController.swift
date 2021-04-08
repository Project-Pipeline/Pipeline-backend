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
    func boot(routes: RoutesBuilder) throws {
        let resumeGrouped = routes.grouped("api", "resume")
        resumeGrouped.post(use: createResume)
        resumeGrouped.delete(use: deleteResume)
        
        let resumeUpdate = routes.grouped("api", "resume", "update")
        resumeUpdate.post(use: updateResume)
        
        let updateResumeAsActive = routes.grouped("api", "resume", "active")
        updateResumeAsActive.get(use: markAsActive)
    }
    
    func updateResume(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let resume = try req.content.decode(Resume.self)
        return try req
            .authorize()
            .flatMap { _ -> EventLoopFuture<Resume> in
                Resume
                    .find(resume.id, on: req.db)
                    .unwrap(or: Abort(.notFound))
            }
            .flatMap { obtainedResume -> EventLoopFuture<Void> in
                obtainedResume.education = resume.education
                obtainedResume.activities = resume.activities
                obtainedResume.apClasses = resume.apClasses
                obtainedResume.publications = resume.publications
                obtainedResume.volunteering = resume.volunteering
                obtainedResume.experiences = resume.experiences
                obtainedResume.certs = resume.certs
                obtainedResume.awards = resume.awards
                obtainedResume.interests = resume.interests
                obtainedResume.testScores = resume.testScores
                obtainedResume.published = resume.published
                obtainedResume.isActive = resume.isActive
                obtainedResume.tag = resume.tag
                return obtainedResume.update(on: req.db)
            }
            .transform(to: .ok)
    }
    
    func createResume(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let resume = try req.content.decode(Resume.self)
        return try req
            .authorize()
            .flatMap { _ -> EventLoopFuture<Void> in
                resume.save(on: req.db)
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
    
    func markAsActive(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let resumeId = try req.queryParam(named: "id", type: UUID.self)
        return try req
            .authorizeAndGetUser()
            .flatMap { user -> EventLoopFuture<[Resume]> in
                user.$resumes.get(on: req.db)
            }
            .flatMap { resumes -> EventLoopFuture<[Void]> in
                let futures = resumes.map { resume -> EventLoopFuture<Void> in
                    resume.isActive = resume.id == resumeId
                    return resume.update(on: req.db)
                }
                return req.eventLoop.flatten(futures)
            }
            .transform(to: .noContent)
    }
}
