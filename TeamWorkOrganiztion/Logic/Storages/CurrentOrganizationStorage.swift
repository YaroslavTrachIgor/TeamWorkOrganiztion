//
//  CurrentOrganizationStorage.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-11-10.
//

import Foundation
import UIKit

//MARK: - Main Storage
/**
 `CurrentOrganizationStorage` serves as a singleton storage for the current organization's information within the application. 
 It holds various properties related to the organization, including its name, admin details, team members, leave requests, and department-specific information.

 - Note: This class is designed to store and manage organization-specific data throughout the application lifecycle, providing easy access to information related to the organization's structure and members.
 
 - Important: Properties in this class are static and can be accessed directly without creating an instance of `CurrentOrganizationStorage`.
 - Remark: To access or update organization-related information, use the static properties provided by this class.
*/
final class CurrentOrganizationStorage {
    
    //MARK: Static
    static var name: String?                     = nil
    static var field: String?                    = nil
    static var key: String?                      = nil
    static var adminEmail: String?               = nil
    static var adminFullName: String?            = nil
    static var teamMembers: [TeamMember]         = []
    static var departmentMembers: [TeamMember]   = []
    static var leaveRequests: [LeaveRequest]     = []
    static var departmentTasks: [DepartmentTask] = []
    static var departmentHeadEmails: [String?]   = []
    static var departmentHeadEmail: String?      = nil
     
    
    //MARK: Initialization
    
    /// Prevents creating instances of `CurrentOrganizationStorage`.
    private init() {}
}
