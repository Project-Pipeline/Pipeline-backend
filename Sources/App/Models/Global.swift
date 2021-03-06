//
//  Global.swift
//  App
//
//  Created by Jing Wei Li on 6/5/20.
//

import Foundation
import Vapor

func readFileNamed(_ name: String, isPublic: Bool) throws -> Data {
    return try Data(contentsOf: pwd()
            .appendingPathComponent(isPublic ? "Public/resources/" : "")
            .appendingPathComponent(name))
}

func readStringFromFile(named name: String, isPublic: Bool) throws -> String {
    let data = try readFileNamed(name, isPublic: isPublic)
    if let result = String(data: data, encoding: .utf8) {
        return result
    } else {
        throw PipelineError(message: "Malformed string")
    }
}

func deleteFileNamed(_ name: String, isPublic: Bool) throws {
    let url = pwd()
            .appendingPathComponent(isPublic ? "Public/resources/" : "")
            .appendingPathComponent(name)
    try FileManager.default.removeItem(at: url)
}

// MARK: - PWD

/// Wrapper for the vapor's current working directory
class PWDWrapper {
    fileprivate static var pwd: String = ""
    
    static func setPWD(with app: Application) {
        self.pwd = app.directory.workingDirectory
    }
}

/// Vapor's current working directory, available to have files written to it.
func pwd() -> URL {
    return URL(fileURLWithPath: PWDWrapper.pwd)
}
