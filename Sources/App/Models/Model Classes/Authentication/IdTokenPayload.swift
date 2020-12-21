//
//  IdTokenPayload.swift
//  
//
//  Created by Jing Wei Li on 12/20/20.
//

import Foundation
import Vapor

struct IdTokenPayload: Content {
    let iss: String
    let sub: String
    let azp: String
    let aud: String
    let iat: String
    let exp: String
    
    let email: String?
    let emailVerified: String?
    let name: String?
    let givenName: String?
    let familyName: String?
    let picture: URL?
    let locale: String?
    
    private enum CodingKeys: String, CodingKey {
        case iss = "iss"
        case sub = "sub"
        case azp = "azp"
        case aud = "aud"
        case iat = "iat"
        case exp = "exp"
        
        case email = "email"
        case emailVerified = "email_verified"
        case name = "name"
        case familyName = "family_name"
        case givenName = "given_name"
        case picture = "picture"
        case locale = "locale"
    }
}

struct IdTokenWrapper: Content {
    let idToken: String
}
