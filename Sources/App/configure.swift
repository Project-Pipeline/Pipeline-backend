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
    
    let environmentConfig: EnvironmentConfigType = appContainer.resolve(EnvironmentConfigType.self)
    environmentConfig.configureMiddlewareFrom(app: app)
    
    // Configure MongoDB
    //app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
    try app.databases.use(.mongo(connectionString: environmentConfig.mongoURL), as: .mongo)
    
    // Configure migrations
    let migratables: [Migratable.Type] = [
        User.self,
        Conversation.self,
    ]
    
    migratables.forEach { migratable in
        app.migrations.add(migratable.createMigration())
    }
    
    // MISC
    app.logger.logLevel = .error
    
    PWDWrapper.setPWD(with: app)
    
    app.routes.defaultMaxBodySize = "50mb"
    
    try routes(app)
    
    /*
    app.get("api", "update-users") { req -> EventLoopFuture<ServerResponse> in
        User.query(on: req.db)
            .all()
            .flatMap { users -> EventLoopFuture<[Void]> in
                let fututres = users.map { user -> EventLoopFuture<Void> in
                    user.messages = []
                    return user.save(on: req.db)
                }
                return req.eventLoop.flatten(fututres)
            }
            .transform(to: ServerResponse.defaultSuccess)
    }
     */
    let messagingSystem = MessagingSystem(app: app)
    app.webSocket("api", "messaging") { req, ws in
        guard let token = try? req.queryParam(named: "token", type: String.self) else { return }
        try? req
            .authorize(with: token)
            .whenComplete { res in
                switch res {
                case .success(_):
                    messagingSystem.connect(ws: ws)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
    }
}
