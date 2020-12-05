//
//  EnvironmentConfig.swift
//  App
//
//  Created by Jing Wei Li on 9/12/20.
//

import Foundation
import Vapor

class EnvironmentConfig: Codable {
    static let `default`: EnvironmentConfig = .load()
    
    let googleClientID: String
    let googleClientSecret: String
    let googleCallbackURL: String
    let mongoURL: String
    
    // feature flags
    let unrestrictedCORS: Bool
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        googleClientID = try container.decode(String.self, forKey: .googleClientID)
        googleClientSecret = try container.decode(String.self, forKey: .googleClientSecret)
        googleCallbackURL = try container.decode(String.self, forKey: .googleCallbackURL)
        let mongoURLEncoded = try container.decode(String.self, forKey: .mongoURL)
        guard let data = Data(base64Encoded: mongoURLEncoded),
            let mongoURL = String(data: data, encoding: .utf8) else {
            throw PipelineError(message: "Incorrect mongo url format")
        }
        self.mongoURL = mongoURL
        self.unrestrictedCORS = try container.decode(Bool.self, forKey: .unrestrictedCORS)
    }
    
    private static func load() -> EnvironmentConfig {
        do {
            let file = try readFileNamed("config.json", isPublic: false)
            return try JSONDecoder().decode(EnvironmentConfig.self, from: file)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
}

extension EnvironmentConfig {
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
