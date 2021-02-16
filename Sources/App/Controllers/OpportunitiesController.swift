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
        // api/opportunities/categories
        opportunities.get("categories", use: getCategories)
    }
    
    // MARK: - Create
    func createOpportunity(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let contents = try req.content.decode(OpportunitiesContentsWrapper.self)
        return try req.authorize()
            // Save into db
            .flatMap { _ in
                req.eventLoop.flatten([
                    contents.opportunity.save(on: req.db),
                    contents.zipcode.saveIfNew(on: req),
                    contents.category.saveIfNew(on: req)
                ])
            }
            // create sibling relationships for zipCode & Category
            .flatMap { _ in
                return req.eventLoop.flatten([
                    contents.opportunity.$zipCodes.attach(contents.zipcode, on: req.db),
                    contents.opportunity.$categories.attach(contents.category, on: req.db)
                ])
            }
            .transform(to: .created)
    }
    
    // MARK: - Get
    /// Gets opportunites
    /// - query parameters:
    ///   - no query params: all the opportunities
    ///   - a comma separated list of zip codes e.g. `zipcode=11357,11373`:  returns opportunites contained in those zip codes
    ///   - a comma separated list of categories e.g. `category=category1,category2`:  returns opportunites matching these categories
    func getOpportunities(req: Request) throws -> EventLoopFuture<[Opportunity]> {
        let zipcodes = (try? req.queryParam(named: "zipcode", type: String.self))?
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let categories = (try? req.queryParam(named: "category", type: String.self))?
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        // if both criterias exist, return the intersections between the two
        if let zipcodes = zipcodes, let categories = categories {
            return zip2(
                getOpportunites(locatedIn: zipcodes, req: req),
                getOpportunites(matching: categories, req: req)
            )
                .map { zipcodeOps, categoriesOps in
                    let set1 = Set(zipcodeOps)
                    let set2 = Set(categoriesOps)
                    return Array(set1.intersection(set2))
                }
        }
        // query by zip codes
        if let zipcodes = zipcodes {
            return getOpportunites(locatedIn: zipcodes, req: req)
        }
        // query by categories
        if let categories = categories {
            return getOpportunites(matching: categories, req: req)
        }
        // return all
        return Opportunity
            .query(on: req.db)
            .all()
    }
    
    /// Get Opportunities located in the given zip codes
    private func getOpportunites(
        locatedIn zipcodes: [String],
        req: Request
    ) -> EventLoopFuture<[Opportunity]> {
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
    
    /// Get Opportunities matching the given categories
    private func getOpportunites(
        matching categories: [String],
        req: Request
    ) -> EventLoopFuture<[Opportunity]> {
        let futures = categories.map { category in
            OpportunityCategory
                .find(category, on: req.db)
                .flatMap { cat -> EventLoopFuture<[Opportunity]> in
                    if let cat = cat {
                        return cat.$opportunities.get(on: req.db)
                    }
                    return req.eventLoop.future([])
                }
        }
        return req.eventLoop
            .flatten(futures)
            .map { $0.reduce([], +) }
    }
    
    
    // MARK: - Delete
    /// Delete an opportunity
    /// - query parameters:
    ///   - `opportunityId`: The id of the opportunity
    ///   - `zipcode`: The zipcode (which is the same as its id)
    func removeOpportunity(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let opportunityId = try req.queryParam(named: "opportunityId", type: UUID.self)
        let zipcode = try req.queryParam(named: "zipcode", type: String.self)
        let category = try req.queryParam(named: "categoryId", type: String.self)
        
        let getOpportunity = Opportunity.find(opportunityId, on: req.db).unwrap(or: Abort(.notFound))
        let getZipcode = Zipcode.find(zipcode, on: req.db).unwrap(or: Abort(.notFound))
        let getCategory = OpportunityCategory.find(category, on: req.db).unwrap(or: Abort(.notFound))
        
        // detach and then delete (the opportunity, not zip code)
        return try req
            .authorize()
            .flatMap { _ in zip3(getOpportunity, getZipcode, getCategory) }
            .flatMap { op, zipcode, cat in
                req.eventLoop.flatten([
                    op.$zipCodes.detach(zipcode, on: req.db),
                    op.$categories.detach(cat, on: req.db)
                ])
                .flatMap { _ in
                    op.delete(on: req.db)
                }
            }
            .transform(to: .noContent)
    }
    
    // MARK: - Other
    func getCategories(req: Request) throws -> EventLoopFuture<[OpportunityCategory]> {
        OpportunityCategory.query(on: req.db).all()
    }
}
