//
//  EnvironmentConfig.swift
//  App
//
//  Created by Jing Wei Li on 9/12/20.
//

import Foundation

class EnvironmentConfig: Codable {
    static var shared: EnvironmentConfig!
    
    let googleClientID: String
    let googleClientSecret: String
    let googleCallbackURL: String
    let mongoURL: String
    
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
    }
    
    static func load() throws -> EnvironmentConfig {
        let file = try readFileNamed("config.json", isPublic: false)
        return try JSONDecoder().decode(EnvironmentConfig.self, from: file)
    }
}
