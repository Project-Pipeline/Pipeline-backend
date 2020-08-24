//
//  UrlQueryble.swift
//  App
//
//  Created by Jing Wei Li on 8/23/20.
//

import Foundation
import Vapor

protocol UrlQueryble where Self: Encodable {
    func queryParameters() throws -> String
}

extension UrlQueryble {
    func queryParameters() throws -> String {
        let json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(self))
        guard let props = json as? [String: Any] else {
            throw Abort(.internalServerError)
        }
        var result = ""
        for (key, val) in props {
            result += result == "" ? "?\(key)=\(val)" : "&\(key)=\(val)"
        }
        return result
    }
}
