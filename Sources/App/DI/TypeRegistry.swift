//
//  TypeRegistry.swift
//  
//
//  Created by Jing Wei Li on 1/3/21.
//

import Foundation
import Vapor
import Swinject

/// Dependency Injection Entry Point
/// - Register a protocol and its implementation here
let appContainer: Container = {
    let container = Container()
    container.register(EnvironmentConfigType.self) { _ in EnvironmentConfig.load() }
    return container
}()

public extension Container {
    func resolve<S>(_ type: S.Type) -> S {
        guard let s = resolve(type.self) else {
            fatalError("No classes conforming to \(S.self) was injected")
        }
        return s
    }
}
