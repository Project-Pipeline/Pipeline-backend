//
//  Resume.swift
//  
//
//  Created by Jing Wei Li on 3/31/21.
//

import Foundation
import Fluent
import Vapor

final class Resume: Model, Content {
    @Parent(key: "userID")
    var user: User
    @ID
    var id: UUID?
    @Field(key: "education")
    var education: [ResumeResource.Education]
    @Field(key: "activities")
    var activities: [ResumeResource.Activity]
    @Field(key: "apClasses")
    var apClasses: [String]
    @Field(key: "publications")
    var publications: [ResumeResource.Publication]
    @Field(key: "volunteering")
    var volunteering: [ResumeResource.Volunteering]
    @Field(key: "experiences")
    var experiences: [ResumeResource.Experience]
    @Field(key: "certs")
    var certs: [ResumeResource.Certification]
    @Field(key: "awards")
    var awards: [ResumeResource.Award]
    @Field(key: "interests")
    var interests: [String]
    @Field(key: "testScores")
    var testScores: [ResumeResource.TestScore]
    @Timestamp(key: "modified", on: .update, format: .iso8601)
    var modified: Date?
    @Timestamp(key: "created", on: .create, format: .iso8601)
    var created: Date?
    /// If false, this resume in currently a draft
    @Field(key: "published")
    var published: Bool
}

enum ResumeResource {
    /// A company, a school or an organization
    /// - `id` would be equaivalent to that of a `User` in our system
    struct Entity: Content {
        let name: String
        let id: UUID?
    }
    
    struct Education: Content {
        let school: Entity
        let degree: String
        let focus: String
        let startDate: String
        let endDate: String?
        let current: Bool
    }
    
    struct Activity: Content {
        let type: String
        let name: String
        let position: String
        let startDate: String
        let endDate: String?
        let descriptions: [String]
        let current: Bool
    }
    
    struct Publication: Content {
        let type: String
        let title: String?
        let content: String
    }
    
    struct Volunteering: Content {
        let role: String
        let category: String
        let entity: Entity
        let location: String
        let startDate: String
        let endDate: String?
        let descriptions: [String]
        let current: Bool
        let hours: Int?
    }
    
    struct Experience: Content {
        let role: String
        let type: String
        let entity: Entity
        let location: String
        let startDate: String
        let endDate: String?
        let descriptions: [String]
        let current: Bool
    }
    
    struct Certification: Content {
        let name: String
        let issued: String
        let issuer: String
        let url: URL
    }
    
    struct Award: Content {
        let name: String
        let date: String
    }
    
    struct TestScore: Content {
        let type: String
        let score: String
    }
}

// MARK: - Migrations

extension Resume: Migratable {
    static var schema: String {
        "Resume"
    }
    
    static var fields: [FieldForMigratable] {
        [
            .init("userID", .uuid, true, .references("User", "id")),
            .init("education", .array(of: .dictionary)),
            .init("activities", .array(of: .dictionary)),
            .init("apClasses", .array(of: .string)),
            .init("publications", .array(of: .dictionary)),
            .init("volunteering", .array(of: .dictionary)),
            .init("experiences", .array(of: .dictionary)),
            .init("certs", .array(of: .dictionary)),
            .init("awards", .array(of: .dictionary)),
            .init("interests", .array(of: .string)),
            .init("testScores", .array(of: .dictionary)),
            .init("modified", .string),
            .init("created", .string),
            .init("published", .bool)
        ]
    }
}
