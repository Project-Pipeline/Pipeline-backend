//
//  CloudinaryTests.swift
//  
//
//  Created by Jing Wei Li on 1/3/21.
//

import Foundation
import XCTest
@testable import App

final class CloudinaryTests: XCTestCase {
    func testSignatureGeneration() {
        //let secret
        let date: TimeInterval = 500000
        let result = CloudinarySignatureGenerator.makeTimestampAndRawSignature(publicId: "hello", config: MockEnvironmentConfig(), date: date)
        XCTAssertEqual(500000, result.0)
        XCTAssertEqual("public_id=hello&timestamp=500000abcd", result.1)
        
        do {
            let signature = try CloudinarySignatureGenerator.makeEncryptedSignature(from: result)
            XCTAssertEqual(500000, signature.timeStamp)
            XCTAssertEqual("98bad17fb29ba6bb799a33444bc39a6d675e9f03c4b416916b2248f6c83d3fa5", signature.signature)
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
    
}
