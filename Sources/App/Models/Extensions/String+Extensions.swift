//
//  String+Extensions.swift
//  
//
//  Created by Jing Wei Li on 1/1/21.
//

import Foundation

extension String: Error {
    
}

extension String: LocalizedError {
    public var errorDescription: String? {
        self
    }
}

extension String {
    func base64Decoded() throws -> String {
        if let decodedData = Data(base64Encoded: self.trimmingCharacters(in: .newlines)),
            let decodedString = String(data: decodedData, encoding: .utf8) {
            return decodedString.trimmingCharacters(in: .newlines)
        } else {
            throw "Unable to decode base64 string"
        }
    }
    
    func toJSONTyped<T: Codable>(_ t: T.Type, jsonHelper: PipelineJSONHelperType = appContainer.resolve()) -> T? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        guard let result = try? jsonHelper.decoder.decode(T.self, from: data) else {
            return nil
        }
        return result
    }
}

