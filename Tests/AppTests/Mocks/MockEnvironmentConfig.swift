//
//  MockEnvironmentConfig.swift
//  
//
//  Created by Jing Wei Li on 1/3/21.
//

import Foundation
@testable import App
import Vapor

struct MockEnvironmentConfig: EnvironmentConfigType {
    var googleClientID: String = ""
    var googleClientSecret: String = ""
    var googleCallbackURL: String = ""
    var mongoURL: String = ""
    var cloudinaryAPISecret: String = "abcd"
    var unrestrictedCORS: Bool = false
    
    init() {}
    
    static func load() -> EnvironmentConfigType {
        MockEnvironmentConfig()
    }
    
    func configureMiddlewareFrom(app: Application) {
        
    }
}


