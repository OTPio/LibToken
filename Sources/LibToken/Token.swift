//
//  Token.swift
//  
//
//  Created by Mason Phillips on 12/10/19.
//

import Foundation

public struct Token {
    public var label : String
    public var issuer: String
    
    var generator: Generator
    
    public var digits: Int {
        get { return generator.digits }
        set { generator.digits = newValue }
    }
    public var algorithm: Algorithm {
        get { return generator.algorithm }
        set { generator.algorithm = newValue }
    }
    public var secret: Data {
        get { return generator.secret }
    }
    public var period: Int {
        get {
            switch generator.type {
            case .totp(let p): return Int(p)
            case .hotp(let c): return Int(c)
            }
        }
    }
    public var type: String {
        get {
            switch generator.type {
            case .totp(_): return "TOTP"
            case .hotp(_): return "HOTP"
            }
        }
    }
    
    
    public init(_ url: URL?) throws {
        guard let url = url, let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { throw TokenError.nullUrlPassed }
        
        guard components.scheme == "otpauth" else { throw TokenError.schemeIncorrect }
        
        label = try Token.extractLabel(path: components.path)
        issuer = try Token.extractIssuer(path: components.path, components: components.queryItems)
        
        generator = try Generator(from: components)
    }
    
    init(label: String, issuer: String, generator: Generator) {
        self.label = label
        self.issuer = issuer
        self.generator = generator
    }
    
    public func password(at time: Date = Date()) -> String {
        return generator.password(at: time)
    }
    
    public func timeRemaining(at time: Date = Date(), reversed: Bool = false) -> Int {
        return generator.timeRemaining(at: time, reversed: reversed)
    }
    
    public func nextToken() -> Token {
        return Token(label: label, issuer: issuer, generator: generator.generatorAfter())
    }
}
