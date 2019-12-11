//
//  ParseToken.swift
//  
//
//  Created by Mason Phillips on 12/10/19.
//

import Foundation
import Base32

extension Token {
    static func extractLabel(path: String) throws -> String {
        let split = path.split(separator: "/")
        guard let last = split.last else { throw TokenError.missingLabel }
        let label = String(last)
        
        if label.contains(":") {
            let parts = label.split(separator: ":")
            guard let last = parts.last else { throw TokenError.missingLabel }
            return String(last)
        } else {
            return label
        }
    }
    static func extractIssuer(path: String, components: [URLQueryItem]?) throws -> String {
        if let components = components, let issuer = components.filter({ $0.name == "issuer" }).first?.value {
            return issuer
        } else if let last = path.split(separator: "/").last {
            let issuer = String(last)
            
            guard
                issuer.contains(":"),
                let first = issuer.split(separator: ":").first
            else { throw TokenError.missingIssuer }
            
            return String(first)
        } else {
            throw TokenError.missingIssuer
        }
    }
}

extension Generator {
    static func extractType(host: String?, components: [URLQueryItem]?) throws -> TokenType {
        guard let host = host else { throw TokenError.missingType }
        switch host {
        case "totp":
            let timer = components?.filter { $0.name == "period" }.first?.value ?? "30"
            let period = TimeInterval(timer) ?? 30
            return .totp(period)
        case "hotp":
            guard
                let timer = components?.filter({ $0.name == "counter" }).first?.value,
                let counter = UInt64(timer)
            else { throw TokenError.missingCounter }
            return .hotp(counter)
        default: throw TokenError.missingType
        }
    }
    static func extractSecret(components: [URLQueryItem]?) throws -> Data {
        guard let secretString = components?.filter({ $0.name == "secret" }).first?.value else { throw TokenError.missingSecret }
        return try Base32.decode(secretString)
    }
    static func extractDigits(components: [URLQueryItem]?) -> Int {
        if let digits = components?.filter({ $0.name == "digits" }).first?.value {
            return Int(digits) ?? 6
        } else { return 6 }
    }
    static func extractAlgorithm(components: [URLQueryItem]?) -> Algorithm {
        if let algorithm = components?.filter({ $0.name == "algorithm" }).first?.value {
            return Algorithm(rawValue: algorithm) ?? .sha1
        } else { return .sha1 }
    }
}
