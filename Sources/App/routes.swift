import Vapor

/// Register your application's routes here.
public func routes(_ app: Application) throws {
    // MARK: - Registering Controllers
    try app.register(collection: AuthenticationController())
    try app.register(collection: UsersController())
    try app.register(collection: ImageUploadController())
    try app.register(collection: MessagingController())
    
    // MARK: - Misc
    
    let messagingSystem = MessagingSystem(app: app)
    app.webSocket("api", "messaging") { req, ws in
        guard let token = try? req.queryParam(named: "token", type: String.self) else { return }
        try? req
            .authorize(with: token)
            .whenComplete { res in
                switch res {
                case .success(_):
                    messagingSystem.connect(ws: ws)
                    try? ws.acknowledgeConnectionEstablished()
                case .failure(let error):
                    PPL_LOG_ERROR(.generic, error)
                }
            }
    }
}
