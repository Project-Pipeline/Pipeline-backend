import Vapor

/// Register your application's routes here.
public func routes(_ app: Application) throws {
    try app.register(collection: AuthenticationController())
    try app.register(collection: UsersController())
}
