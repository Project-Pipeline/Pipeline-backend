//
//  AuthenticatioController.swift
//  App
//
//  Created by Jing Wei Li on 8/6/20.
//

import Foundation
import Vapor
import Imperial
import Authentication

struct AuthenticationController: RouteCollection {
    func boot(router: Router) throws {
        let decoder = JSONDecoder()
        
        // MARK: - OAuth: First Step
        
        guard let googleCallbackURL = Environment.get("GOOGLE_CALLBACK_URL") else {
            fatalError("Google callback URL not set")
        }

        try router.oAuth(
            from: Google.self,
            authenticate: "login",
            callback: googleCallbackURL,
            scope: ["profile", "email"],
            completion:
        { request, _ in
            // this closure is never called
            return request.future("")
        })
        
        // MARK: - OAuth: 2nd and 3rd step
        
        router.get("api/login") { req -> Future<String> in
            guard let code = req.query[String.self, at: "code"],
                let secondAuth = SecondAuth(code: code) else {
                throw Abort(.internalServerError)
            }
            return try req
                .client()
                .post("https://www.googleapis.com/oauth2/v4/token", headers: HTTPHeaders(), beforeSend: { req in
                    try req.content.encode(secondAuth)
                })
                .flatMap { response -> Future<Response> in
                    guard let json = response.stringForm()?.data(using: .utf8) else {
                        throw Abort(.internalServerError)
                    }
                    let accessToken = try decoder.decode(GoogleAccessToken.self, from: json)
                    return try req.client().get(
                        "https://www.googleapis.com/oauth2/v1/userinfo?access_token=\(accessToken.accessToken)",
                        headers: HTTPHeaders([("Authorization","Bearer \(accessToken.accessToken)")]))
                }
                .flatMap { response -> Future<String> in
                    guard let json = response.stringForm()?.data(using: .utf8) else {
                        throw Abort(.internalServerError)
                    }
                    let user = try decoder.decode(GoogleUser.self, from: json)
                    return req.future("\(user)")
                }
        }
    }
        
}

