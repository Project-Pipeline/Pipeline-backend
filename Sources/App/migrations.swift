//
//  migrations.swift
//  
//
//  Created by Jing Wei Li on 2/27/21.
//

import Foundation

let migrations: [Migratable.Type] = [
    User.self,
    Conversation.self,
    UserDetails.self,
    // MARK: - Opportunity
    Opportunity.self,
    OpportunityCategory.self,
    OpportunityCategoryPivot.self,
    Zipcode.self,
    ZipcodePivot.self,
    // MARK: - Posts
    Post.self,
    CommentForPost.self,
    LikeForPost.self,
    CategoryForPost.self,
    // MARK: - Resume
    Resume.self
]
