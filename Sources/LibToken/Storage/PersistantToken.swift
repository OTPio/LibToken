//
//  Persistant.swift
//  
//
//  Created by Mason Phillips on 12/10/19.
//

import Foundation

public struct PersistantToken {
    public let token     : Token
    public let identifier: Data
    
    init(token: Token, identifier: Data) {
        self.token = token
        self.identifier = identifier
    }
    
    init(from keychain: NSDictionary) throws {
        guard let ref = keychain[kSecValuePersistentRef as String] as? Data else {
            throw KeychainError.missingReference
        }
        guard
            let data = keychain[kSecAttrGeneric as String] as? Data,
            let urlString = String(data: data, encoding: .utf8),
            let url = URL(string: urlString)
        else { throw TokenError.nullUrlPassed }

        let token = try Token(url)
        self.init(token: token, identifier: ref)
    }
}
