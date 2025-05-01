//
//  NetworkService.swift
//  Rundong
//
//  Created by MAC on 2025/2/25.
//

import Foundation

class NetworkService {
    private var netID: String {
        return AuthenticationUtils.getCurrentUserNetID() ?? ""
    }
    
    private var password: String {
        return AuthenticationUtils.getCurrentUserPassword() ?? ""
    }
    
    // Singleton
    static let shared = NetworkService()
    
    private init() {}
    
    // Generate Basic Authentication Header
    private var authHeader: String {
        let loginString = "\(netID):\(password)"
        guard let data = loginString.data(using: .utf8) else {
            return ""
        }
        return "Basic \(data.base64EncodedString())"
    }
    
    // Note: Using async is to avoid blocking the main thread
    func downloadPersonDTO() async throws -> DukePersonDTO {
        // Note: Use guard to unwrap an Optional object; if the unwrapped value is nil, the execution enters the else branch
        guard let url = URL(string: "http://ece564.rc.duke.edu:8080/entries/\(netID)") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        // add Authorization header
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        
        // For Test
        //        print("[Request] URL: \(url.absoluteString)")
        //        print("[Request] Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        //        // For Test
        //        if String(data: data, encoding: .utf8) != nil {
        //           print("[Response] Raw JSON:\n\(jsonString)")
        //        }
        
        // Decode into DukePerson using JSONDecoder
        let decoder = JSONDecoder()
        return try decoder.decode(DukePersonDTO.self, from: data)
    }
    
    // TODO: 待测试
    func upload(person: DukePerson) async -> Bool {
        guard let url = URL(string: "http://ece564.rc.duke.edu:8080/entries/\(netID)") else {
            return false
        }
        var request = URLRequest(url: url)
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            // 先转换为 DTO
            let dto = convertDukePersonToDTO(person: person)
            // 编码 DTO，而不是直接编码 DukePerson
            request.httpBody = try JSONEncoder().encode(dto)
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }
            
            print("Request URL:", request.url?.absoluteString ?? "Invalid URL")
            print("Request Headers:", request.allHTTPHeaderFields ?? [:])
            print("Request Body:", String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "Empty Data")
            print("Server Response Status Code:", httpResponse.statusCode)
            
            return (200...299).contains(httpResponse.statusCode)
        } catch {
            print("Upload failed:", error.localizedDescription)
            return false
        }
    }
    
    
    // 批量下载所有人员数据
    func fetchAllEntriesDTO() async throws -> [DukePersonDTO] {
        // 构建URL
        guard let url = URL(string: "http://ece564.rc.duke.edu:8080/entries/all") else {
            throw URLError(.badURL)
        }
        
        // 配置请求
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        
        // 发送请求
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // 解码为数组
        return try JSONDecoder().decode([DukePersonDTO].self, from: data)
    }
    
    // 返回组装好的FetchAllEntries的请求头
    func buildFetchAllEntriesRequest() throws -> URLRequest {
        guard let url = URL(string: "http://ece564.rc.duke.edu:8080/entries/all") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        return request
    }
    
    func uploadCardImage(imageData: Data, filename: String) async throws -> URL {
        guard let url = URL(string: "https://flask564.zeabur.app/upload-image") else {
            throw URLError(.badURL)
        }
        
        // 构建multipart请求
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // 构建表单数据
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        // 发送请求
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 验证响应状态
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // 解析返回的URL
        struct UploadResponse: Codable {
            let success: Bool
            let url: String
            let file_name: String
        }
        
        let decoder = JSONDecoder()
        let uploadResponse = try decoder.decode(UploadResponse.self, from: data)
        
        // 这是服务器返回的可访问URL
        guard let serverURL = URL(string: uploadResponse.url) else {
            throw URLError(.badURL)
        }
        
        return serverURL
    }
}
