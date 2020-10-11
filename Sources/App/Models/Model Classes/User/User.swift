//
//  User.swift
//  App
//
//  Created by Jing Wei Li on 8/1/20.
//

import Foundation
import Vapor
import FluentSQLite

struct UserEmail: Codable {
    let email: String
}

struct UserExistence: Content {
    let email: String
    let exists: Bool
}

struct User: Codable, Content {
    let email: String
    let givenName: String
    let familyName: String
    let picture: String
    let entityBelongedTo: String
    let entityName: String
    let industryType: String
    let industry: String
    var id: Int?
}

extension User: Model {
    typealias Database = SQLiteDatabase
    typealias ID = Int
    static var idKey: IDKey = \User.id
}

extension User: Migration, Parameter {
    
}

extension User: MongoModel {
    static var mockedInstance: User {
        return User(email: "", givenName: "", familyName: "", picture: "",
                    entityBelongedTo: "", entityName: "", industryType: "", industry: "", id: nil)
    }
    
    var collectionName: String {
        return "Users"
    }
    
    var databaseName: String {
        return "Project-pipeline"
    }
}
