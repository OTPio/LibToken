//
//  Keychain.swift
//  
//
//  Created by Mason Phillips on 12/10/19.
//

import Foundation

public final class Keychain {
    static let service: String = "app.otpio.keychain"
    static let shared: Keychain = Keychain()
    
    public func create(_ token: Token) throws -> PersistantToken {
        let attributes = try token.attributes()
        let id = try addItem(attributes: attributes)
        return PersistantToken(token: token, identifier: id)
    }
    
    public func read(with id: Data) throws -> PersistantToken? {
        return try readItem(ref: id).map { try PersistantToken(from: $0) }
    }
    public func readAll() throws -> Array<PersistantToken> {
        return try readAllItems().compactMap { item -> PersistantToken? in
            return try? PersistantToken(from: item)
        }
    }
    
    public func update(_ persistant: PersistantToken, with token: Token) throws -> PersistantToken {
        let attributes = try token.attributes()
        try updateItem(ref: persistant.identifier, attributes: attributes)
        return PersistantToken(token: token, identifier: persistant.identifier)
    }
    
    public func delete(_ persistant: PersistantToken) throws {
        try deleteItem(ref: persistant.identifier)
    }
}

private extension Keychain {
    func addItem(attributes: [String: AnyObject]) throws -> Data {
        var mutable = attributes
        mutable[kSecClass as String] = kSecClassGenericPassword
        mutable[kSecReturnPersistentRef as String] = kCFBooleanTrue
        mutable[kSecAttrAccount as String] = UUID().uuidString as NSString
        
        var ref: AnyObject?
        
        let result: OSStatus = withUnsafeMutablePointer(to: &ref) { r in
            SecItemAdd(mutable as CFDictionary, r)
        }
        
        guard result == errSecSuccess else {
            throw KeychainError.unknownSystemError(result)
        }
        
        guard let pref = ref as? Data else {
            throw KeychainError.missingReference
        }
        
        return pref
    }
    
    func readItem(ref: Data) throws -> NSDictionary? {
        let query: [String: AnyObject] = [
            kSecClass               as String: kSecClassGenericPassword,
            kSecValuePersistentRef  as String: ref as NSData,
            kSecReturnPersistentRef as String: kCFBooleanTrue,
            kSecReturnAttributes    as String: kCFBooleanTrue,
            kSecReturnData          as String: kCFBooleanTrue
        ]
        
        var item: AnyObject?
        let result: OSStatus = withUnsafeMutablePointer(to: &item) { i in
            SecItemCopyMatching(query as CFDictionary, i)
        }
        
        if result == errSecItemNotFound { return nil }
        guard result == errSecSuccess else { throw KeychainError.unknownSystemError(result) }
        guard let returned = item as? NSDictionary else {
            throw KeychainError.incorrectType
        }
        return returned
    }
    func readAllItems() throws -> Array<NSDictionary> {
        let query: [String: AnyObject] = [
            kSecClass               as String: kSecClassGenericPassword,
            kSecReturnPersistentRef as String: kCFBooleanTrue,
            kSecReturnAttributes    as String: kCFBooleanTrue,
            kSecReturnData          as String: kCFBooleanTrue,
            kSecMatchLimit          as String: kSecMatchLimitAll
        ]
        
        var items: AnyObject?
        let result: OSStatus = withUnsafeMutablePointer(to: &items) { i in
            SecItemCopyMatching(query as CFDictionary, i)
        }

        if result == errSecItemNotFound { return [] }
        guard result == errSecSuccess else { throw KeychainError.unknownSystemError(result) }
        guard let returned = items as? [NSDictionary] else {
            throw KeychainError.incorrectType
        }
        
        return returned
    }
    
    func updateItem(ref: Data, attributes: [String: AnyObject]) throws {
        let query: [String: AnyObject] = [
            kSecClass              as String: kSecClassGenericPassword,
            kSecValuePersistentRef as String: ref as NSData
        ]
        
        let result = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard result == errSecSuccess else { throw KeychainError.unknownSystemError(result) }
    }
    
    func deleteItem(ref: Data) throws {
        let query: [String: AnyObject] = [
            kSecClass              as String: kSecClassGenericPassword,
            kSecValuePersistentRef as String: ref as NSData
        ]
        
        let result = SecItemDelete(query as CFDictionary)
        guard result == errSecSuccess else { throw KeychainError.unknownSystemError(result) }
    }
}
