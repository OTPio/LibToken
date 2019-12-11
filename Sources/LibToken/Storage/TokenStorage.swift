//
//  File.swift
//  
//
//  Created by Mason Phillips on 12/10/19.
//

import Foundation
import Base32

extension Token {
    func serialize() -> URL {
        var components = URLComponents()
        components.scheme = "otpauth"
        
        var queryItems: [URLQueryItem] = []
        
        switch self.generator.type {
        case .totp(let p):
            components.host = "totp"
            queryItems.append(URLQueryItem(name: "period", value: "\(p)"))
            break
        case .hotp(let c):
            components.host = "hotp"
            queryItems.append(URLQueryItem(name: "counter", value: "\(c)"))
            break
        }
        
        components.path = "\(issuer):\(label)"
        queryItems.append(URLQueryItem(name: "issuer", value: issuer))
        
        queryItems.append(URLQueryItem(name: "secret", value: generator.secret.base32EncodedString))
        
        queryItems.append(URLQueryItem(name: "algorithm", value: generator.algorithm.rawValue))
        
        queryItems.append(URLQueryItem(name: "digits", value: "\(generator.digits)"))
        
        return components.url!
    }
    
    func attributes() throws -> [String: AnyObject] {
        let url = serialize()
        guard let data = url.absoluteString.data(using: .utf8) else {
            throw KeychainError.serializationFailed
        }
        
        return [
            kSecAttrGeneric as String: data as NSData,
            kSecValueData   as String: generator.secret as NSData,
            kSecAttrService as String: Keychain.service as NSString
        ]
    }
}
