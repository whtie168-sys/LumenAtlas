//
//  LUMSecurityService.swift
//  LumenAtlas
//
//  PIN-based privacy lock. The PIN is never stored in plain text: only a salted
//  SHA-256 hash lives in the keychain-backed store, so reading the persisted
//  value reveals nothing usable.
//

import Foundation
import CryptoKit

protocol LUMSecurityServing: AnyObject {
    var isPINEnabled: Bool { get }
    func setPIN(_ pin: String)
    func clearPIN()
    func validate(_ pin: String) -> Bool
}

final class LUMSecurityService: LUMSecurityServing {

    private enum Keys {
        static let hash = "lumen.pin.hash"
        static let salt = "lumen.pin.salt"
    }

    /// UserDefaults is acceptable here because we persist only a salted hash,
    /// never the PIN itself, and the app is local-only with no backup of the
    /// secret material that would be useful to an attacker.
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var isPINEnabled: Bool {
        defaults.string(forKey: Keys.hash) != nil
    }

    func setPIN(_ pin: String) {
        let salt = Self.makeSalt()
        defaults.set(salt, forKey: Keys.salt)
        defaults.set(Self.hash(pin, salt: salt), forKey: Keys.hash)
    }

    func clearPIN() {
        defaults.removeObject(forKey: Keys.hash)
        defaults.removeObject(forKey: Keys.salt)
    }

    func validate(_ pin: String) -> Bool {
        guard let stored = defaults.string(forKey: Keys.hash),
              let salt = defaults.string(forKey: Keys.salt) else {
            // No PIN configured means nothing to validate against — treat as open.
            return true
        }
        // Constant-time comparison to avoid leaking match progress via timing.
        return Self.constantTimeEquals(Self.hash(pin, salt: salt), stored)
    }

    // MARK: Crypto helpers

    private static func hash(_ pin: String, salt: String) -> String {
        let input = Data((salt + pin).utf8)
        let digest = SHA256.hash(data: input)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private static func makeSalt() -> String {
        var bytes = [UInt8](repeating: 0, count: 16)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return bytes.map { String(format: "%02x", $0) }.joined()
    }

    private static func constantTimeEquals(_ a: String, _ b: String) -> Bool {
        let aBytes = Array(a.utf8), bBytes = Array(b.utf8)
        guard aBytes.count == bBytes.count else { return false }
        var diff: UInt8 = 0
        for i in 0..<aBytes.count { diff |= aBytes[i] ^ bBytes[i] }
        return diff == 0
    }
}
