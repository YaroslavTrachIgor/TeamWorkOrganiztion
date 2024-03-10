//
//  Task.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2024-01-12.
//

import Foundation

struct WFInstance: Codable {
    let ID: Int
    let ApplicationReference: String
}

struct WFTaskInstanceJSON: Codable {
    let isDelegationTask: Int?
    let source: String?
    let ID: Int?
    let WFInstanceID: Int?
    let StartDate: String?
    let DirectAssignUserName: String?
    let ActionTakenByUserID: String?
    let ActionTakebByUserFullName: String?
    let WFAssignedRoleID: Int?
    let StatusID: Int?
    let TaskURL: String?
    let isCheckedOut: Bool?
    let Comment: String?
    let CheckOutTo_UserID: String?
    let CheckOutTo_UserName: String?
    let CheckOutTo_History: String?
    let CheckedOutDate: String?
    let WFAssignedStateID: Int?
    let GroupTaskID: Int?
    let StateID: Int?
    let StateName: String?
    let RequireMultiRoleMemberApproval: Bool?
    let AssignedToRoleID: Int?
    let isInitialStep: Bool?
    let isFinalStep: Bool?
    let isAutomatedStep: Bool?
    let TaskPageURL: String?
    let PostDatedDays: Int?
    let WFTemplateID: Int?
}

struct WFResponse: Codable {
    let WFInstance: WFInstance
    let WFTaskInstance_JSON: [WFTaskInstanceJSON]
}
