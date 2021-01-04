//
//  CloudinarySignature.swift
//  
//
//  Created by Jing Wei Li on 1/3/21.
//

import Foundation
import Vapor

struct CloudinarySignature: Content {
    let signature: String
    let timeStamp: Int
}
