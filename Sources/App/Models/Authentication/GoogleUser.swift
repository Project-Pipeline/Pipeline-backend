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

struct GoogleUser: Content {
    let email: String
    let name: String
    let given_name: String
    let family_name: String
    let picture: URL
    let id: String
}
