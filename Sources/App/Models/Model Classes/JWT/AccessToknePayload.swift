//
//  AccessToknePayload.swift
//  App
//
//  Created by Jing Wei Li on 9/13/20.
//

import JWT
import Foundation

struct AccessTokenPayload: JWTPayload {
    
    var issuer: IssuerClaim
    var issuedAt: IssuedAtClaim
    var expirationAt: ExpirationClaim
    var userEmail: String
    
    init(userEmail: String) {
        self.issuer = IssuerClaim(value: "ProjectPipeline")
        self.issuedAt = IssuedAtClaim(value:  Date())
        self.expirationAt = ExpirationClaim(value: Date().addingTimeInterval(18000)) // valid for 5 hours
        self.userEmail = userEmail
    }
    
    func verify(using signer: JWTSigner) throws {
        try expirationAt.verifyNotExpired()
    }
}
