//
//  SecondAuth.swift
//  App
//
//  Created by Jing Wei Li on 8/16/20.
//

import Vapor
import Imperial
import Authentication
import Foundation

struct SecondAuth: Codable, Content {
    let code: String
    let client_id: String
    let client_secret: String
    let redirect_uri: String
    let grant_type: String
    
    init?(code: String) {
        guard let clientId  = Environment.get("GOOGLE_CLIENT_ID"),
        let clientSecret = Environment.get("GOOGLE_CLIENT_SECRET"),
            let redirectUrl = Environment.get("GOOGLE_CALLBACK_URL")
        else {
            return nil
        }
        self.code = code
        self.client_id = clientId
        self.client_secret = clientSecret
        self.redirect_uri = redirectUrl
        self.grant_type = "authorization_code"
    }
}
