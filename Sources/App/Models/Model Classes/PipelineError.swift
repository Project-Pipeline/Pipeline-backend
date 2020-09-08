//
//  PipelineError.swift
//  App
//
//  Created by Jing Wei Li on 9/7/20.
//

import Foundation
import Vapor

struct PipelineError {
    let message: String
    
    init(message: String) {
        self.message = message
    }
}

extension PipelineError: Debuggable {
    var identifier: String {
        return message
    }
    
    var reason: String {
        return message
    }
}


