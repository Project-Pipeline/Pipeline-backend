//
//  GoogleUser.swift
//  App
//
//  Created by Jing Wei Li on 8/6/20.
//

import Foundation
import Vapor
import Imperial
import Authentication

struct GoogleUser: Content, UrlQueryble {
    let email: String
    let name: String
    let givenName: String
    let familyName: String
    let picture: URL
    let id: String
    
    private enum CodingKeys: String, CodingKey {
        case email = "email"
        case name = "name"
        case familyName = "family_name"
        case givenName = "given_name"
        case picture = "picture"
        case id = "id"
        
    }
}
