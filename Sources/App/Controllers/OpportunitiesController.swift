//
//  OpportunitiesController.swift
//  
//
//  Created by Jing Wei Li on 2/13/21.
//

import Foundation
import Vapor
import Fluent

struct OpportunitiesController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        
        let opportunities = routes.grouped("api", "opportunities")
        opportunities.post(use: createOpportunity)
        opportunities.get(use: getOpportunities)
        opportunities.delete(use: removeOpportunity)
    }
    
    func createOpportunity(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let contents = try req.content.decode(OpportunitiesContentsWrapper.self)
        return try req.authorize()
            // Save into db
            .flatMap { _ in
                req.eventLoop.flatten([
                    contents.opportunity.save(on: req.db),
                    contents.zipcode.saveIfNew(on: req)
                ])
            }
            // create sibling relationships
            .flatMap { ids  in
                return contents.opportunity.$zipCodes
                    .attach(contents.zipcode, on: req.db)
            }
            .transform(to: .created)
    }
    
    /// Gets opportunites
    /// - query parameters:
    ///   - no query params: all the opportunities
    ///   - a comma separated list of zip codes e.g. `zipcode=11357,11373`:  returns opportunites contained in those zip codes
    func getOpportunities(req: Request) throws -> EventLoopFuture<[Opportunity]> {
        let zipcodes =
            (try? req.queryParam(named: "zipcode", type: String.self))?
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        // query by zip codes
        if let zipcodes = zipcodes {
            let futures = zipcodes.map { zipcode in
                return Zipcode
                    .find(zipcode, on: req.db)
                    .flatMap { code -> EventLoopFuture<[Opportunity]> in
                        if let code = code {
                            return code.$opportunities.get(on: req.db)
                        }
                        return req.eventLoop.future([])
                    }
            }
            return req.eventLoop
                .flatten(futures)
                .map { $0.reduce([], +) }
        }
        // return all
        return Opportunity
            .query(on: req.db)
            .all()
    }
    
    /// Delete an opportunity
    /// - query parameters:
    ///   - `opportunityId`: The id of the opportunity
    ///   - `zipcode`: The zipcode (which is the same as its id)
    func removeOpportunity(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let opportunityId = try req.queryParam(named: "opportunityId", type: UUID.self)
        let zipcode = try req.queryParam(named: "zipcode", type: String.self)
        
        let getOpportunity = Opportunity.find(opportunityId, on: req.db).unwrap(or: Abort(.notFound))
        let getZipcode = Zipcode.find(zipcode, on: req.db).unwrap(or: Abort(.notFound))
        
        // detach and then delete (the opportunity, not zip code)
        return try req
            .authorize()
            .flatMap { _ in
                getOpportunity.and(getZipcode)
            }
            .flatMap { op, zipcode in
                op.$zipCodes
                    .detach(zipcode, on: req.db)
                    .flatMap {
                        op.delete(on: req.db)
                    }
            }
            .transform(to: .noContent)
    }
}
