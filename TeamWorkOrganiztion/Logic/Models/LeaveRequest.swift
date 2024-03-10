//
//  LeaveRequest.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-11-19.
//

import Foundation

/// Represents a Model for any Organization's Team Member Leave Request
struct LeaveRequest: Codable {
    var availableTimeOffDays: Int?
    var confirmationEmailSent: Bool?
    var departmentHeadEmail: String?
    var departmentName: String?
    var submittedDate: String?
    var employeeEmail: String?
    var employeeFullName: String?
    var employeeID: String?
    var endDate: String?
    var startDate: String?
    var purpose: String?
    var isRecent: Bool?
    var status: String?
    
    
    /// Coding keys to specify custom keys for decoding/encoding.
    enum CodingKeys: String, CodingKey {
        case availableTimeOffDays    = "available_time_off_days"
        case confirmationEmailSent   = "confirmation_email_sent"
        case submittedDate           = "submitted_date"
        case departmentHeadEmail     = "department_head_email"
        case departmentName          = "department_name"
        case employeeEmail           = "employee_email"
        case employeeFullName        = "employee_full_name"
        case employeeID              = "employee_id"
        case endDate                 = "end_date"
        case startDate               = "start_date"
        case purpose                 = "purpose"
        case isRecent                = "is_recent"
        case status                  = "status"
    }
    
    
    /// Initializes a leave request from decoder.
    /// - Parameter decoder: The decoder used to read data from.
    /// - Throws: An error during the decoding process.
    init(from decoder: Decoder) throws {
        let container                = try decoder.container(keyedBy: CodingKeys.self)
        self.availableTimeOffDays    = try container.decodeIfPresent(Int.self, forKey: .availableTimeOffDays)
        self.confirmationEmailSent   = try container.decodeIfPresent(Bool.self, forKey: .confirmationEmailSent)
        self.submittedDate           = try container.decodeIfPresent(String.self, forKey: .submittedDate)
        self.departmentHeadEmail     = try container.decodeIfPresent(String.self, forKey: .departmentHeadEmail)
        self.departmentName          = try container.decodeIfPresent(String.self, forKey: .departmentName)
        self.employeeEmail           = try container.decodeIfPresent(String.self, forKey: .employeeEmail)
        self.employeeFullName        = try container.decodeIfPresent(String.self, forKey: .employeeFullName)
        self.employeeID              = try container.decodeIfPresent(String.self, forKey: .employeeID)
        self.endDate                 = try container.decodeIfPresent(String.self, forKey: .endDate)
        self.startDate               = try container.decodeIfPresent(String.self, forKey: .startDate)
        self.purpose                 = try container.decodeIfPresent(String.self, forKey: .purpose)
        self.isRecent                = try container.decodeIfPresent(Bool.self, forKey: .isRecent)
        self.status                  = try container.decodeIfPresent(String.self, forKey: .status)
    }
}
