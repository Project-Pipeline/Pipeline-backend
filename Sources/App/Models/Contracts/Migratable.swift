//
//  Migratable.swift
//
//
//  Created by Jing Wei Li on 11/25/20.
//

import Foundation
import Vapor
import Fluent

/// Automatically create a migration when a model conforms to this protocol
protocol Migratable  {
    static var idRequired: Bool { get }
    static var schema: String { get }
    static var fields: [FieldForMigratable] { get }
    
    static func createMigration() -> Migration
}

struct FieldForMigratable {
    let name: FieldKey
    let type: DatabaseSchema.DataType
    let required: Bool
    let additionalConstraint: DatabaseSchema.FieldConstraint?
    
    /// - Parameters:
    ///   - name: name of the field in the database, usually a string
    ///   - type: type of the field
    ///   - required: false if the field is optional, otherwise true
    init(
        _ name: FieldKey,
        _ type: DatabaseSchema.DataType,
        _ required: Bool = true,
        _ additionalConstraint: DatabaseSchema.FieldConstraint? = nil)
    {
        self.name = name
        self.type = type
        self.required = required
        self.additionalConstraint = additionalConstraint
    }
}

struct MigratedObject: Migration {
    let migratable: Migratable.Type
    let name: String
    init(migratable: Migratable.Type) {
        self.migratable = migratable
        self.name = migratable.schema
    }
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        var schema: SchemaBuilder = database.schema(migratable.schema)
        
        if migratable.idRequired {
            schema = schema.id()
        }
        
        migratable.fields.forEach { field in
            if let additionalConstraint = field.additionalConstraint {
                schema = field.required
                    ? schema.field(field.name, field.type, .required, additionalConstraint)
                    : schema.field(field.name, field.type, additionalConstraint)
            } else {
                schema = field.required
                    ? schema.field(field.name, field.type, .required)
                    : schema.field(field.name, field.type)
            }
        }
        
        return schema.create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(migratable.schema).delete()
    }
}

extension Migratable {
    static func createMigration() -> Migration {
        MigratedObject(migratable: self)
    }
    
    static var idRequired: Bool { true }
}
