//
//  Request+Extensions.swift
//  
//
//  Created by Jing Wei Li on 1/3/21.
//

import Foundation
import Vapor

extension Request {
    func queryParam<T: Decodable>(named name: String, type: T.Type) throws -> T {
        guard let value = query[type.self, at: name] else {
            throw PipelineError(message: "Missing query param \(name)")
        }
        return value
    }
    
    /// A query parameter whose value is a comma separated list
    /// ```
    /// // For example,
    /// myrequest?category=school,company
    /// ```
    func commaSeparatedQueryParam(named name: String) throws -> [String] {
        (try queryParam(named: name, type: String.self))
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
}
