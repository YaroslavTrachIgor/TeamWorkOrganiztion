//
//  DepartmentTask.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-12-03.
//

import Foundation

/// Represents a Model for any Organization's Department Task
struct DepartmentTask: Codable {
    let id: String
    let taskId: String
    let title: String
    let isUrgent: Bool
    let description: String
    let dateCreated: String
    let deadline: String
    let department: String
    let initiatedByEmail: String
    let initiatedByFullname: String
    let status: String
    
    /// Coding keys to specify custom keys for decoding/encoding.
    enum CodingKeys: String, CodingKey {
        case id                  = "id"
        case taskId              = "taskId"
        case title               = "title"
        case isUrgent            = "is_urgent"
        case description         = "description"
        case dateCreated         = "date_created"
        case deadline            = "deadline"
        case department          = "department"
        case initiatedByEmail    = "initiated_by_email"
        case initiatedByFullname = "initiated_by_fullname"
        case status              = "status"
    }
    
    /// Initializes a department task from decoder.
    /// - Parameter decoder: The decoder used to read data from.
    /// - Throws: An error during the decoding process.
    init(from decoder: Decoder) throws {
        let container               = try decoder.container(keyedBy: CodingKeys.self)
        self.id                     = try container.decode(String.self, forKey: .id)
        self.taskId                 = try container.decode(String.self, forKey: .taskId)
        self.title                  = try container.decode(String.self, forKey: .title)
        self.isUrgent               = try container.decode(Bool.self, forKey: .isUrgent)
        self.description            = try container.decode(String.self, forKey: .description)
        self.dateCreated            = try container.decode(String.self, forKey: .dateCreated)
        self.deadline               = try container.decode(String.self, forKey: .deadline)
        self.department             = try container.decode(String.self, forKey: .department)
        self.initiatedByEmail       = try container.decode(String.self, forKey: .initiatedByEmail)
        self.initiatedByFullname    = try container.decode(String.self, forKey: .initiatedByFullname)
        self.status                 = try container.decode(String.self, forKey: .status)
    }
}



enum DepartmentTaskStatus: String {
    case unknown = "Unknwon"
    case inProgress = "In Progress"
    case inRevision = "In Revision"
    case completed = "Completed"
    case rejected = "Rejected"
}
