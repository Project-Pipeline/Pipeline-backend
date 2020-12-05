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
                .decodeResponse(typed: GoogleAccessToken.self) { accessToken -> EventLoopFuture<ClientResponse> in
                    req.client.get(
                        "https://www.googleapis.com/oauth2/v1/userinfo?access_token=\(accessToken.accessToken)",
                        headers: HTTPHeaders([("Authorization","Bearer \(accessToken.accessToken)")]))
                }
                .decodeResponse(typed: GoogleUser.self) { user in
                    guard let params = try? user.queryParameters() else {
                        return req.eventLoop.future(Response(status: .badRequest))
                    }
                    return req.eventLoop.future(req.redirect(to: "http://localhost:4200/logindetails\(params)"))
                }
        }
    }
        
}

