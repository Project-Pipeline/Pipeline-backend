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
    
    func decodeResponse<T: Decodable, U>(
        typed type: T.Type,
        on req: Request,
        then execute: @escaping (T) throws -> U) throws -> EventLoopFuture<U>
    {
        flatMapThrowing { res in
            try res.content.decode(T.self)
        }
        .flatMap { req.eventLoop.future($0) }
        .flatMapThrowing { t in
            return try execute(t)
        }
        
    }
}
