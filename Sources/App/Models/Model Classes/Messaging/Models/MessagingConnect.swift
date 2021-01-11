//
//  MessagingConnect.swift
//  
//
//  Created by Jing Wei Li on 1/10/21.
//

import Foundation
import Vapor

struct MessagingConnect: Content {
    /// ID of the conversation
    let conversationID: UUID
    let originatingUserID: UUID
}
