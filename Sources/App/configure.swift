import FluentSQLite
import Vapor
import MongoSwift

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
    // Register providers first
    try services.register(FluentSQLiteProvider())
    
    EnvironmentConfig.shared = try EnvironmentConfig.load()

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self)
    FeatureFlags.configureMiddlewareFrom(config: &middlewares)

    let client = try MongoClient(EnvironmentConfig.shared.mongoURL)
    let _ = client.pipelineDB()
    client.initUsers()
    services.register(client)
    services.register(middlewares)
}
