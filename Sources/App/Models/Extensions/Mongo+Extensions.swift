//
//  Mongo+Extensions.swift
//  App
//
//  Created by Jing Wei Li on 9/12/20.
//

import MongoSwift
import Foundation
import Vapor

extension MongoClient {
    func pipelineDB() -> MongoDatabase {
        return db("Project-pipeline")
    }
    
    func initUsers() {
        do {
            _ = try pipelineDB().createCollection("Users")
        } catch let error {
            print(error.localizedDescription)
            _ = pipelineDB().collection("Users")
        }
    }
}

extension MongoClient: Service {
    
}
