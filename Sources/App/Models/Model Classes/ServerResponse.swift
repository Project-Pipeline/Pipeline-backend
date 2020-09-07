//
//  ServerResponse.swift
//  App
//
//  Created by Jing Wei Li on 9/6/20.
//

import Foundation
import Vapor

struct ServerResponse: Content {
    let success: Bool
    let message: String
    
    static let defaultSuccess: ServerResponse = {
        return ServerResponse(success: true, message: "success")
    }()
    
    static func errorFrom(_ error: Error) -> ServerResponse {
        return ServerResponse(success: false, message: error.localizedDescription)
    }
}
