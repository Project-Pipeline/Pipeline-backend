//
//  Model+Extensions.swift
//  
//
//  Created by Jing Wei Li on 2/14/21.
//

import Vapor
import Fluent

extension Model {
    /// Only save the model to the DB if it hasn't existed in it before
    func saveIfNew(on req: Request) -> EventLoopFuture<Void> {
        return Self
            .find(id, on: req.db)
            .flatMap { model in
                if model != nil {
                    return req.eventLoop.future(())
                }
                return self.save(on: req.db)
            }
    }
}
