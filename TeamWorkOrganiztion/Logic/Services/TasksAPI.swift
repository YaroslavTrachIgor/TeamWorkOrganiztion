//
//  TasksAPI.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2024-01-12.
//

import Foundation

private enum Constants {
    static let jsonFileName = "sarah_tasks_updated"
    static let fileNotFoundError = NSError(domain: "com.example", code: 404, userInfo: [NSLocalizedDescriptionKey: "File not found or invalid."])
}

protocol TasksAPIProtocol {
    func getTasks(url: URL?) async throws -> [WFResponse]
    func loadJSONFromFile() throws -> [WFResponse]
}

final class TasksAPI: APIManager, TasksAPIProtocol {
    
    //MARK: Internal
    func getTasks(url: URL?) async throws -> [WFResponse] {
        guard let url = url else {
            print()
            print("-----------------")
            print()
            print("API DEBUG DESCRIPTION")
            print("URL IS INVALID")
            print()
            print("-----------------")
            print()
            throw URLError(.badURL)
        }
        do {
            let data = try await self.get(url: url)
            return try JSONDecoder().decode([WFResponse].self, from: data)
        } catch {
            print()
            print("-----------------")
            print()
            print("API DEBUG DESCRIPTION")
            print("\(error.localizedDescription)")
            print()
            print("-----------------")
            print()
            return []
        }
    }
    
    func loadJSONFromFile() throws -> [WFResponse] {
        guard let fileURL = Bundle.main.url(forResource: Constants.jsonFileName, withExtension: "json"),
              let data = try? Data(contentsOf: fileURL) else {
            print()
            print("-----------------")
            print()
            print("FILE API DEBUG DESCRIPTION")
            print("File not found or invalid.")
            print()
            print("-----------------")
            print()
            throw Constants.fileNotFoundError
        }
        do {
            return try JSONDecoder().decode([WFResponse].self, from: data)
        } catch {
            print()
            print("-----------------")
            print()
            print("FILE API DEBUG DESCRIPTION")
            print(error.localizedDescription)
            print()
            print("-----------------")
            print()
            return []
        }
    }
}
