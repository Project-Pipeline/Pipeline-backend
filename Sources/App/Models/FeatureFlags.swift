//
//  FeatureFlags.swift
//  App
//
//  Created by Jing Wei Li on 7/26/20.
//

import Foundation
import Vapor

enum FeatureFlags {
    static let unrestrictedCORS = true
}


extension FeatureFlags {
    static func configureMiddlewareFrom(config: inout MiddlewareConfig) {
        if unrestrictedCORS {
            config.use(CORSMiddleware(configuration: CORSMiddleware.Configuration(
                allowedOrigin: .all,
                allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
                allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
            )))
        }
    }
}

