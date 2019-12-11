//
//  Error.swift
//  
//
//  Created by Mason Phillips on 12/10/19.
//

import Foundation

public enum TokenError: Error {
    case nullUrlPassed
    case schemeIncorrect
    case missingLabel, missingIssuer, missingSecret, missingType, missingCounter
    
    var localizedDescription: String {
        switch self {
        case .nullUrlPassed  : return "A null URL was passed for initialization"
        case .schemeIncorrect: return "An incorrect schema was passed. URLs must begin with otpauth://"
        case .missingLabel   : return "Label is missing. No candidate in path was found"
        case .missingIssuer  : return "Issuer is missing. No candidate in path or query components was found"
        case .missingSecret  : return "Secret is missing. No candidate in query components was found"
        case .missingType    : return "Type is missing. No candidate in path found"
        case .missingCounter : return "Counter is missing. No candidate in query items found"
        }
    }
}

public enum KeychainError: Error {
    case unknownSystemError(OSStatus)
    case incorrectType
    case incorrectIdentifierType
    case serializationFailed
}
