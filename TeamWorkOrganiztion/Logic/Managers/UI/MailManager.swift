//
//  MailManager.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-12-12.
//

import Foundation
import UIKit
import MessageUI

//MARK: - Main Manager
final public class MailManager {
    
    //MARK: Static
    static func sendLeaveRequestStatus(_ status: UserLeaveRequestStatus,
                                       employeeEmail: String,
                                       employeeFullName: String!,
                                       departmentHeadEmail: String!,
                                       mailComposeDelegate: MFMailComposeViewControllerDelegate,
                                       on vc: UIViewController) {
        var cc = [String]()
        if !CurrentOrganizationStorage.departmentHeadEmails.contains(employeeEmail) {
            cc = [departmentHeadEmail]
        }
        
        let approvedBody = """
        Dear \(employeeFullName ?? employeeEmail), your Time-Off request was Approved.
        """
        
        let declinedBody = """
        Dear \(employeeFullName ?? employeeEmail), your Time-Off request was Declined.
        
        Reason:
        """
        
        send(recipients: [employeeEmail],
             cc: cc,
             subject: "Time-Off Request Status Updated",
             body: status == .approved ? approvedBody : declinedBody,
             mailComposeDelegate: mailComposeDelegate,
             on: vc)
    }
    
    static func sendLeaveRequestConfirmation(mailComposeDelegate: MFMailComposeViewControllerDelegate,
                                             on vc: UIViewController) {
        let recipients: [String]
        if let departmentHeadEmail = CurrentOrganizationStorage.departmentHeadEmail {
            recipients = [CurrentOrganizationStorage.adminEmail!, departmentHeadEmail]
        } else {
            recipients = [CurrentOrganizationStorage.adminEmail!]
        }
        send(recipients: recipients,
             subject: "Time-Off Request Confirmation from \(CurrentUserStorage.fullName ?? "Employee")!",
             mailComposeDelegate: mailComposeDelegate,
             on: vc)
    }
    
    static func sendLetterToEmployer(mailComposeDelegate: MFMailComposeViewControllerDelegate,
                                     on vc: UIViewController) {
        send(recipients: [CurrentOrganizationStorage.adminEmail!],
             subject: "Important Message from \(CurrentUserStorage.fullName ?? "Employee")!",
             mailComposeDelegate: mailComposeDelegate,
             on: vc)
    }
}


//MARK: - Base methods
extension MailManager {
    
    //MARK: Static
    static func send(recipients: [String],
                     cc: [String] = [],
                     subject: String,
                     body: String = "",
                     mailComposeDelegate: MFMailComposeViewControllerDelegate,
                     on vc: UIViewController) {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = mailComposeDelegate
        composeVC.setCcRecipients(cc)
        composeVC.setToRecipients(recipients)
        composeVC.setSubject(subject)
        composeVC.setMessageBody(body, isHTML: false)
        composeVC.view.tintColor = .baseTintColor
        vc.present(composeVC, animated: true, completion: nil)
    }
}
