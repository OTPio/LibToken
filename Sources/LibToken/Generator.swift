//
//  Generator.swift
//  
//
//  Created by Mason Phillips on 12/10/19.
//

import Foundation

struct Generator {
    let secret   : Data
    let algorithm: Algorithm
    let digits   : Int
    let type     : TokenType
    
    init(from components: URLComponents) throws {
        secret = try Generator.extractSecret(components: components.queryItems)
        algorithm = Generator.extractAlgorithm(components: components.queryItems)
        digits = Generator.extractDigits(components: components.queryItems)
        type = try Generator.extractType(host: components.host, components: components.queryItems)
    }
    
    init(secret: Data, algorithm: Algorithm, digits: Int, type: TokenType) {
        self.secret = secret
        self.algorithm = algorithm
        self.digits = digits
        self.type = type
    }
    
    enum TokenType {
        case totp(_ period: TimeInterval)
        case hotp(_ counter: UInt64)
        
        func value(at time: Date) -> UInt64 {
            switch self {
            case .totp(let period):
                let epoch = time.timeIntervalSince1970
                return UInt64(epoch / period)
            case .hotp(let counter):
                return counter
            }
        }
        
        func remaining(at time: Date) -> Int {
            switch self {
            case .totp(let p): return Int(p - time.timeIntervalSince1970.truncatingRemainder(dividingBy: p))
            case .hotp(let c): return Int(c)
            }
        }
    }
    
    func password(at time: Date) -> String {
        var period = type.value(at: time).bigEndian
        let periodAsData = Data(bytes: &period, count: MemoryLayout<UInt64>.size)

        let hash = hmac(algorithm: algorithm, secret: secret, data: periodAsData)
        var truncated = hash.withUnsafeBytes { p -> UInt32 in
            let offset = p[hash.count - 1] & 0x0f
            
            let tp = p.baseAddress! + Int(offset)
            return tp.bindMemory(to: UInt32.self, capacity: 1).pointee
        }
        
        truncated = UInt32(bigEndian: truncated)
        truncated &= 0x7fffffff
        truncated = truncated % UInt32(pow(10, Float(digits)))
        
        return String(truncated).padding(toLength: digits, withPad: "0", startingAt: 0)
    }
    
    func timeRemaining(at time: Date, reversed: Bool) -> Int {
        let t = type.remaining(at: time)
        
        if case .totp(let p) = type {
            return reversed ? Int(abs(Int(p) - t)) : t
        }
        
        return t
    }
    
    func generatorAfter() -> Generator {
        switch type {
        case .totp(_): return self
        case .hotp(let c):
            return Generator(secret: secret, algorithm: algorithm, digits: digits, type: .hotp(c + 1))
        }
    }
}
