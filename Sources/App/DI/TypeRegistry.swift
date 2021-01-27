//
//  TypeRegistry.swift
//  
//
//  Created by Jing Wei Li on 1/3/21.
//

import Foundation
import Vapor
import Swinject

// MARK: - Dependency Injection Entry Point
/// - Register a protocol and its implementation here
let appContainer: Container = {
    let container = Container()
    container.register(EnvironmentConfigType.self) { _ in EnvironmentConfig.load() }
    container.register(PipelineJSONHelperType.self) { _ in PipelienJSONHelper() }
    return container
}()

// MARK: - Extensions

public extension Container {
    /// Resolve an instance of the type. If the type is not injected, the call will crash
    /// - Parameter type: The abstract type to resolve
    /// - Returns: The concrete type
    func resolve<S>(_ type: S.Type) -> S {
        guard let s = resolve(type.self) else {
            fatalError("No classes conforming to \(S.self) was injected")
        }
        return s
    }
    
    func resolve<S>() -> S {
        guard let s = resolve(S.self) else {
            fatalError("No classes conforming to \(S.self) was injected")
        }
        return s
    }
}
