//
//  String+Extensions.swift
//  
//
//  Created by Jing Wei Li on 1/1/21.
//

import Foundation

extension String: Error {
    
}

extension String: LocalizedError {
    public var errorDescription: String? {
        self
    }
}

