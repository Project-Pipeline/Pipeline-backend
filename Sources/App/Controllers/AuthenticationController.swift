//
//  AuthenticatioController.swift
//  App
//
//  Created by Jing Wei Li on 8/6/20.
//

import Foundation
import Vapor
import ImperialGoogle
import Fluent

struct AuthenticationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // MARK: - OAuth: First Step
        let config: EnvironmentConfigType = appContainer.resolve()
        
        guard let googleCallbackURL = Environment.get("GOOGLE_CALLBACK_URL") else {
            fatalError("Google callback URL not set")
        }

        try routes.oAuth(
            from: Google.self,
            authenticate: "api/googlelogin",
            callback: googleCallbackURL,
            scope: ["profile", "email"],
            completion:
        { request, _ in
            // this closure is never called
            return request.eventLoop.future("")
        })
        
        // MARK: - OAuth: 2nd and 3rd step
        
        routes.get("api", "login") { req -> EventLoopFuture<Response> in
            guard let code = req.query[String.self, at: "code"],
                let secondAuth = SecondAuth(code: code) else {
                throw Abort(.internalServerError)
            }
            return try req
                .client
                .post("https://www.googleapis.com/oauth2/v4/token", headers: HTTPHeaders(), beforeSend: { req in
                    try req.content.encode(secondAuth, as: .json)
                })
                .decodeResponse(typed: GoogleAccessToken.self) { req.eventLoop.future($0) }
                .flatMapThrowing { token -> EventLoopFuture<[ClientResponse]> in
                    let tokenData = try JSONEncoder().encode(IdTokenWrapper(idToken: token.idToken))
                    return req.eventLoop.flatten([
                        req.client.get(
                            "https://www.googleapis.com/oauth2/v1/userinfo?access_token=\(token.accessToken)",
                            headers: HTTPHeaders([("Authorization","Bearer \(token.accessToken)")])),
                        req.eventLoop.future(ClientResponse(
                                status: .ok,
                                headers: HTTPHeaders([("Content-Type", "application/json")]),
                                body: ByteBuffer(data: tokenData)))
                    ])
                }
                .flatMap { $0 }
                .flatMapThrowing { responses -> (String, String) in
                    guard let first = responses.first, let last = responses.last else {
                        throw Abort(.internalServerError)
                    }
                    let userInfo = try (try first.content.decode(GoogleUser.self)).queryParameters()
                    let idToken = try last.content.decode(IdTokenWrapper.self)
                    return (userInfo, idToken.idToken)
                }
                .flatMap { result in
                    return req.eventLoop.future(req.redirect(to: "\(config.websiteUrl)/logindetails\(result.0)&idToken=\(result.1)"))
                }
        }
    }
        
}

