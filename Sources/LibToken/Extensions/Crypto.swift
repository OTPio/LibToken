//
//  File.swift
//  
//
//  Created by Mason Phillips on 12/10/19.
//

import Foundation
import CommonCrypto
#if canImport(CryptoKit)
    import CryptoKit
#endif

internal func hmac(algorithm: Algorithm, secret: Data, data: Data) -> Data {
    #if canImport(CryptoKit)
    if #available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *) {
        return ckhmac(algorithm, secret, data)
    } else {
        return cchmac(algorithm, secret, data)
    }
    #else
    return cchmac(algorithm, secret, data)
    #endif
}

#if canImport(CryptoKit)
@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
private func ckhmac(_ a: Algorithm, _ s: Data, _ d: Data) -> Data {
    let k = SymmetricKey(data: s)
    
    func create(_ ptr: UnsafeRawBufferPointer) -> Data { Data(bytes: ptr.baseAddress!, count: Int(a.algorithmDetails.1)) }
    
    switch a {
    case .md5   : return CryptoKit.HMAC<Insecure.MD5>.authenticationCode(for: d, using: k).withUnsafeBytes(create)
    case .sha1  : return CryptoKit.HMAC<Insecure.SHA1>.authenticationCode(for: d, using: k).withUnsafeBytes(create)
    case .sha256: return CryptoKit.HMAC<SHA256>.authenticationCode(for: d, using: k).withUnsafeBytes(create)
    case .sha384: return CryptoKit.HMAC<SHA384>.authenticationCode(for: d, using: k).withUnsafeBytes(create)
    case .sha512: return CryptoKit.HMAC<SHA512>.authenticationCode(for: d, using: k).withUnsafeBytes(create)
    }
}
#endif

private func cchmac(_ a: Algorithm, _ s: Data, _ d: Data) -> Data {
    let (function, length) = a.algorithmDetails
    
    let out = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(length))
    defer { out.deallocate() }
    
    s.withUnsafeBytes { kB in
        d.withUnsafeBytes { dB in
            CCHmac(function, kB.baseAddress, s.count, dB.baseAddress, d.count, out)
        }
    }
    
    return Data(bytes: out, count: Int(length))
}
