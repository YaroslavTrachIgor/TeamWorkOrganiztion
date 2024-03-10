//
//  APIManager.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2024-01-12.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
}

class APIManager {

    init() {}

    func get(url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return data
        } catch {
            print()
            print("-----------------")
            print()
            print("API DEBUG DESCRIPTION")
            print("API GET Request Error \(error.localizedDescription)")
            print()
            print("-----------------")
            print()
            throw NSError(domain: "com.example", code: 404, userInfo: [NSLocalizedDescriptionKey: "API GET Request Error \(error.localizedDescription)"])
        }
    }

    func post(url: URL, body: Data?) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.httpBody = body
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }
    
    func put(url: URL, body: Data?) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.put.rawValue
        request.httpBody = body
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }
}

