//
//  Token.swift
//  
//
//  Created by Mason Phillips on 12/10/19.
//

import Foundation

struct Token {
    let label : String
    let issuer: String
    
    let generator: Generator
    
    init(_ url: URL?) throws {
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
    
    func password(at time: Date = Date()) -> String {
        return generator.password(at: time)
    }
    
    func timeRemaining(at time: Date = Date(), reversed: Bool = false) -> Int {
        return generator.timeRemaining(at: time, reversed: reversed)
    }
    
    func nextToken() -> Token {
        return Token(label: label, issuer: issuer, generator: generator.generatorAfter())
    }
}
