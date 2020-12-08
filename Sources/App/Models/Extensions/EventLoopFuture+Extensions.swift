//
//  File.swift
//  
//
//  Created by Jing Wei Li on 12/5/20.
//

import Vapor
import Fluent

extension EventLoopFuture where Value == ClientResponse {
    /// Decode a `Decodable` with the given type then call the execute block with the decoded content passed in
    func decodeResponse<T: Decodable, U>(
        typed type: T.Type,
        then execute: @escaping (T) -> EventLoopFuture<U>) throws -> EventLoopFuture<U>
    {
        flatMapThrowing { res in
            try res.content.decode(T.self)
        }
        .flatMap(execute)
    }
}
