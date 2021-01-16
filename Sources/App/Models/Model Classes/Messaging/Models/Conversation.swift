//
//  Conversation.swift
//  
//
//  Created by Jing Wei Li on 1/9/21.
//

import Foundation
import Vapor
import Fluent

/// A single message
struct ConversationEntry: Content {
    let timeStamp: Int
    let text: String?
    let imageURL: URL?
    let fileURL: URL?
    let senderUserID: UUID
    let conversationBelongedTo: UUID
}

struct ConversationParticipantInfo: Content {
    let firstName: String
    let lastName: String
    let profileImageURL: URL
    /// id of each individual user, identical to the id in the users db
    let userID: UUID
}

/// Base class of a conversation. Intended to be decoded from a json
final class Conversation: Content, Model {
    @ID
    var id: UUID?
    @Field(key: "entries")
    var entries: [ConversationEntry]
    @Field(key: "participantInfo")
    var participantsInfo: [ConversationParticipantInfo]
    @Field(key: "created")
    var created: Int
    @Field(key: "modified")
    var modified: Int
}

extension Conversation: Migratable {
    static var idRequired: Bool {
        true
    }
    
    static var schema: String {
        "conversation"
    }
    
    static var fields: [FieldForMigratable] {
        [
            .init("participants", .string),
            .init("entries", .array(of: .dictionary)),
            .init("participantInfo", .array(of: .dictionary)),
            .init("created", .int),
            .init("modified", .int)
        ]
    }
}
