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
}
