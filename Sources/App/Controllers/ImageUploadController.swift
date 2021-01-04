//
//  ImageUploadController.swift
//  
//
//  Created by Jing Wei Li on 1/3/21.
//

import Foundation
import Vapor

struct ImageUploadController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        
        /// https://cloudinary.com/documentation/upload_images#generating_authentication_signatures
        routes.get("api", "images", "signature") { req -> EventLoopFuture<CloudinarySignature> in
            let publicId = try req.queryParam(named: "public_id", type: String.self)
            return try req.authorize { _ -> EventLoopFuture<(Int, String)> in
                return req.eventLoop.future(CloudinarySignatureGenerator.makeTimestampAndRawSignature(
                        publicId: publicId,
                        config: appContainer.resolve(EnvironmentConfigType.self)
                    )
                )
            }
            .flatMapThrowing {
                try CloudinarySignatureGenerator.makeEncryptedSignature(from: $0)
            }
        }
    }
}
