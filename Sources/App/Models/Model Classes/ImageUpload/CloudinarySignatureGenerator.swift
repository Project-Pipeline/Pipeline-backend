//
//  CloudinarySignatureGenerator.swift
//  
//
//  Created by Jing Wei Li on 1/3/21.
//

import Foundation
import Vapor

enum CloudinarySignatureGenerator {
    /// Call `makeEncryptedSignature()` with the result of this fn
    /// - Returns: first tuple arg: timestamp; second tuple arg: uncrypted signature
    static func makeTimestampAndRawSignature(
        publicId: String,
        config: EnvironmentConfigType,
        date: TimeInterval = Date().timeIntervalSince1970) -> (Int, String)
    {
        let timeStamp = Int(date)
        var str = "public_id=\(publicId)&timestamp=\(timeStamp)"
        str += config.cloudinaryAPISecret
        return (timeStamp, str)
    }
    
    /// Encrypts the input signature with SHA-256 algorithm
    static func makeEncryptedSignature(from sig: (Int, String)) throws -> CloudinarySignature {
        guard let sigData = sig.1.data(using: .utf8) else {
            throw Abort(.internalServerError)
        }
        let hashedResult = "\(SHA256.hash(data: sigData))".replacingOccurrences(of: "SHA256 digest: ", with: "")
        return CloudinarySignature(signature: hashedResult, timeStamp: sig.0)
    }
}
