//
//  Response+StringForm.swift
//  App
//
//  Created by Jing Wei Li on 8/16/20.
//

import Foundation
import Vapor

extension Response {
    /// This only works on a response that has a json body
    func jsonString() -> String? {
        if let last = "\(self)".components(separatedBy: "{").last {
            return "{\(last)"
        }
        return nil
    }
}
