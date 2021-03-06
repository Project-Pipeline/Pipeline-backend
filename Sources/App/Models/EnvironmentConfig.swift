//
//  EnvironmentConfig.swift
//  App
//
//  Created by Jing Wei Li on 9/12/20.
//

import Foundation
import Vapor

public protocol EnvironmentConfigType {
    var googleClientID: String { get }
    var googleClientSecret: String { get }
    var googleCallbackURL: String { get }
    var mongoURL: String { get }
    var cloudinaryAPISecret: String { get }
    var websiteUrl: String { get }
    // feature flags
    var unrestrictedCORS: Bool { get }
    
    static func load() -> EnvironmentConfigType
    func configureMiddlewareFrom(app: Application)
}

class EnvironmentConfig: Codable, EnvironmentConfigType {
    let googleClientID: String
    let googleClientSecret: String
    let googleCallbackURL: String
    let mongoURL: String
    let cloudinaryAPISecret: String
    let websiteUrl: String
    
    // feature flags
    let unrestrictedCORS: Bool
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        googleClientID = try container.decode(String.self, forKey: .googleClientID)
        googleClientSecret = try container.decode(String.self, forKey: .googleClientSecret)
        googleCallbackURL = try container.decode(String.self, forKey: .googleCallbackURL)
        self.mongoURL = try container.decode(String.self, forKey: .mongoURL).base64Decoded()
        self.unrestrictedCORS = try container.decode(Bool.self, forKey: .unrestrictedCORS)
        self.cloudinaryAPISecret = try container.decode(String.self, forKey: .cloudinaryAPISecret).base64Decoded()
        self.websiteUrl = try container.decode(String.self, forKey: .websiteUrl)
    }
    
    static func load() -> EnvironmentConfigType {
        do {
            let file = try readFileNamed("config.json", isPublic: false)
            return try JSONDecoder().decode(EnvironmentConfig.self, from: file)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    func configureMiddlewareFrom(app: Application) {
        if unrestrictedCORS {
            app.middleware.use(CORSMiddleware(configuration: CORSMiddleware.Configuration(
                allowedOrigin: .all,
                allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
                allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
            )))
        }
    }
}
