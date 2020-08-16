//
//  Account.swift
//  App
//
//  Created by Jing Wei Li on 8/1/20.
//

import Foundation

class Account {
    let name: String
    let email: String
    let privacy: AccountPrivacy
    
    
    init(
        name: String,
        email: String,
        privacy: AccountPrivacy)
    {
        self.name = name
        self.email = email
        self.privacy = privacy
    }
}
