import Fluent
import FluentMongoDriver
import Vapor
import JWT

/// Called before your application initializes.
public func configure(_ app: Application) throws {
    // Register middleware
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(app.sessions.middleware)
    
    let environmentConfig: EnvironmentConfigType = appContainer.resolve()
    environmentConfig.configureMiddlewareFrom(app: app)
    
    // Configure MongoDB
    //app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
    try app.databases.use(.mongo(connectionString: environmentConfig.mongoURL), as: .mongo)
    
    // Configure migrations
    migrations.forEach { migratable in
        app.migrations.add(migratable.createMigration())
    }
    
    // MISC
    app.logger.logLevel = .error
    
    PWDWrapper.setPWD(with: app)
    
    app.routes.defaultMaxBodySize = "50mb"
    
    try routes(app)
}
