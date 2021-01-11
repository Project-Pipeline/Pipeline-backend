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
    let id: UUID
    let timeStamp: Int
    let text: String?
    let imageURL: URL?
    let senderUserID: UUID
    let conversationBelongedTo: UUID
}

struct ConversationParticipantInfo: Content {
    let firstName: String
    let lastName: String
    let profileImageURL: URL
}

/// Base class of a conversation. Intended to be decoded from a json
final class Conversation: Content, Model {
    @ID
    var id: UUID?
    /// ids of all users involced in the conversation
    @Field(key: "participants")
    var participants: [UUID]
    @Field(key: "entries")
    var entries: [ConversationEntry]
    @Field(key: "participantInfo")
    var participantsInfo: [ConversationParticipantInfo]
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
            .init("participant-info", .array(of: .dictionary))
        ]
    }
}
