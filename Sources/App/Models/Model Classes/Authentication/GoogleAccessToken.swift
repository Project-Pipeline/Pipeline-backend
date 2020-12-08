//
//  GoogleAccessToken.swift
//  App
//
//  Created by Jing Wei Li on 8/16/20.
//

import Foundation
import Vapor

struct GoogleAccessToken: Content {
    let accessToken: String
    let expiresIn: Int
    let scope: String
    let tokenType: String
    let idToken: String
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case scope = "scope"
        case tokenType = "token_type"
        case idToken = "id_token"
    }
}
