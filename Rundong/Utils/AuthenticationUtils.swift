//
//  Untitled.swift
//  Rundong
//
//  Created by MAC on 2025/2/25.
//

import Foundation

struct AuthenticationUtils {
    
    static func getCurrentUserNetID() -> String? {
        guard let authString = UserDefaults.standard.string(forKey: "AuthString") else {
            return nil
        }
        // format: "netID:password"
        let components = authString.split(separator: ":")
        guard components.count == 2 else {
            return nil
        }
        return String(components[0])
    }
    
    static func getCurrentUserPassword() -> String? {
        guard let authString = UserDefaults.standard.string(forKey: "AuthString") else {
            return nil
        }
        let components = authString.split(separator: ":")
        guard components.count == 2 else {
            return nil
        }
        return String(components[1])
    }
}
