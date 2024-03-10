//
//  User.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-11-25.
//

import Foundation
import UIKit

/// Enum defining different statuses for user leave request
enum UserLeaveRequestStatus: String {
    case unknown     = "Unknown"
    case noRequest   = "No Request"
    case delivered   = "Delivered"
    case approved    = "Approved"
}

/// Represents a Model for any user profile with various details.
struct User {
    var id: String?
    var username: String?
    var fullName: String?
    var email: String?
    var bio: String?
    var occupation: String?
    var department: String?
    var telegramLink: String?
    var linckedInLink: String?
    var facebookLink: String?
    var leaveStartDate: String?
    var leaveEndDate: String?
}
