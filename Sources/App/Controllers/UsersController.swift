//
//  UsersController.swift
//  App
//
//  Created by Jing Wei Li on 9/6/20.
//

import Foundation
import Vapor

struct UsersController: RouteCollection {
    func boot(router: Router) throws {
        router.post("api", "user", "create") { req -> Future<ServerResponse> in
            print("creating user")
            return try req.content
                .decode(User.self)
                .flatMap(to: User.self) { $0.create(on: req) }
                .transform(to: ServerResponse.defaultSuccess)
        }
    }
}
