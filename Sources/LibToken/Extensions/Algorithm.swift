//
//  Algorithm.swift
//  
//
//  Created by Mason Phillips on 12/10/19.
//

import Foundation
import CommonCrypto

public enum Algorithm: String, CaseIterable, CustomStringConvertible {
    case md5    = "md5"
    case sha1   = "sha1"
    case sha256 = "sha256"
    case sha384 = "sha384"
    case sha512 = "sha512"
    
    public init?(rawValue r: String) {
        let check = r.lowercased().replacingOccurrences(of: "-", with: "")
        switch check {
        case "md5"   : self = .md5
        case "sha1"  : self = .sha1
        case "sha256": self = .sha256
        case "sha384": self = .sha384
        case "sha512": self = .sha512
        default: return nil
        }
    }
    
    public var description: String {
        switch self {
        case .md5   : return "MD5"
        case .sha1  : return "SHA-1"
        case .sha256: return "SHA-256"
        case .sha384: return "SHA-384"
        case .sha512: return "SHA-512"
        }
    }
    
    internal var algorithmDetails: (CCHmacAlgorithm, Int32) {
        switch self {
        case .md5   : return (CCHmacAlgorithm(kCCHmacAlgMD5)   , CC_MD5_DIGEST_LENGTH)
        case .sha1  : return (CCHmacAlgorithm(kCCHmacAlgSHA1)  , CC_SHA1_DIGEST_LENGTH)
        case .sha256: return (CCHmacAlgorithm(kCCHmacAlgSHA256), CC_SHA256_DIGEST_LENGTH)
        case .sha384: return (CCHmacAlgorithm(kCCHmacAlgSHA384), CC_SHA384_DIGEST_LENGTH)
        case .sha512: return (CCHmacAlgorithm(kCCHmacAlgSHA512), CC_SHA512_DIGEST_LENGTH)
        }
    }
}
