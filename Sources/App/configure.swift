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
    EnvironmentConfig.default.configureMiddlewareFrom(app: app)
    
    // Configure MongoDB
    //app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
    try app.databases.use(.mongo(connectionString: EnvironmentConfig.default.mongoURL), as: .mongo)
    
    // Configure migrations
    let migratables: [Migratable.Type] = [
        User.self
    ]
    
    migratables.forEach { migratable in
        app.migrations.add(migratable.createMigration())
    }
    
    // JWT
    let key = try readStringFromFile(named: "jwtKey.key", isPublic: false)
    app.jwt.signers.use(.hs256(key: key))
    
    // MISC
    app.logger.logLevel = .error
    
    PWDWrapper.setPWD(with: app)
    
    app.routes.defaultMaxBodySize = "50mb"
    
    try routes(app)
}
