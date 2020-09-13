//
//  MongoModel.swift
//  App
//
//  Created by Jing Wei Li on 9/12/20.
//

import Foundation
import MongoSwift
import Vapor

protocol MongoModel {
    var collectionName: String { get }
    var databaseName: String { get }
    static var mockedInstance: Self { get }
}

extension MongoClient {
    func db<T: MongoModel>(for type: T.Type) -> MongoDatabase {
        return db(type.mockedInstance.databaseName)
    }
    
    func collection<T: MongoModel>(for type: T.Type) -> MongoCollection<T> {
        let model = T.mockedInstance
        return db(model.databaseName).collection(model.collectionName, withType: type)
    }
}
