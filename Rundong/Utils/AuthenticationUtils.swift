//
//  Untitled.swift
//  Rundong
//
//  Created by MAC on 2025/2/25.
//

import Foundation

struct AuthenticationUtils {
    
    /// 获取当前登录用户的 netID，从 UserDefaults 的 "AuthString" 中解析。
    static func getCurrentUserNetID() -> String? {
        guard let authString = UserDefaults.standard.string(forKey: "AuthString") else {
            return nil
        }
        // 格式为 "netID:password"
        let components = authString.split(separator: ":")
        guard components.count == 2 else {
            return nil
        }
        return String(components[0])
    }
    
    /// 获取当前登录用户的密码
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
