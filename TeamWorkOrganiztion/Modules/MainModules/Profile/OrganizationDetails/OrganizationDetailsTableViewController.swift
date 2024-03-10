//
//  OrganizationDetailsTableViewController.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-11-11.
//

import UIKit
import MessageUI

final class OrganizationDetailsTableViewController: UITableViewController {

    
    @IBOutlet private weak var organizationNameLabel: UILabel!
    @IBOutlet private weak var organizationFieldLabel: UILabel!
    @IBOutlet private weak var numberOfTeamMembersLabel: UILabel!
    @IBOutlet private weak var adminFullNameLabel: UILabel!
    @IBOutlet private weak var adminEmailLabel: UILabel!
    @IBOutlet private weak var contactEmployerButton: UIButton!
    @IBOutlet private weak var contactEmployerTableViewCell: UITableViewCell!
    @IBOutlet private weak var departmentNameLabel: UILabel!
    @IBOutlet private weak var numberOfDepartmentMembers: UILabel!
    
    
    @IBOutlet private var departmentHeadTextFields: [UITextField]!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        organizationNameLabel.text = CurrentOrganizationStorage.name
        organizationFieldLabel.text = CurrentOrganizationStorage.field
        numberOfTeamMembersLabel.text = String(CurrentOrganizationStorage.teamMembers.count)
        adminFullNameLabel.text = CurrentOrganizationStorage.adminFullName
        adminEmailLabel.text = CurrentOrganizationStorage.adminEmail
        
        
        departmentNameLabel.text = CurrentUserStorage.department?.transformDepartmentKey()
        numberOfDepartmentMembers.text = String(CurrentOrganizationStorage.departmentMembers.count)
        
        
        if let isAdmin = CurrentUserStorage.isAdmin, isAdmin {
            contactEmployerTableViewCell.isHidden = true
        }
        
        for departmentHeadTextField in departmentHeadTextFields {
            departmentHeadTextField.tintColor = .baseTintColor
            departmentHeadTextField.delegate = self
            
            if let departmentHeadEmail = CurrentOrganizationStorage.departmentHeadEmails[departmentHeadTextField.tag] {
                departmentHeadTextField.text = departmentHeadEmail
            }
            
            if let isAdmin = CurrentUserStorage.isAdmin, !isAdmin {
                departmentHeadTextField.isUserInteractionEnabled = false
            }
        }
        
        if !MFMailComposeViewController.canSendMail() {
            contactEmployerButton.isEnabled = false
        }
    }
    
    @IBAction func contactEmployer(_ sender: Any) {
        MailManager.sendLetterToEmployer(mailComposeDelegate: self, on: self)
    }
    
    @IBAction func copyOrganizationKey(_ sender: Any) {
        UIPasteboard.general.string = CurrentOrganizationStorage.key
    }
}


//MARK: - TextField Delegate protocol extension
extension OrganizationDetailsTableViewController: UITextFieldDelegate {
    
    //MARK: Internal
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text!.isValidEmail() {
            Task {
                await DatabaseManager.shared.pushNewDepartmentHeadToFirestore(organizationName: CurrentOrganizationStorage.name,
                                                                              departmentName: DatabaseConstants.departments[textField.tag],
                                                                              departmentHeadEmail: textField.text) { error in
                    guard error == nil else {
                        AlertManager.presentError(message: error?.localizedDescription ?? "Unknown Error", on: self)
                        return
                    }
                    CurrentOrganizationStorage.departmentHeadEmails[textField.tag] = textField.text
                }
            }
        } else {
            if let departmentHeadEmail = CurrentOrganizationStorage.departmentHeadEmails[textField.tag] {
                textField.text = departmentHeadEmail
            } else {
                textField.text = nil
            }
                
            AlertManager.present(title: "Invalid Email Address", message: "The email address you entered for your department head is badly formatted.", on: self)
        }
        return true
    }
}


//MARK: - MFMailComposeViewController Delegate protocol extension
extension OrganizationDetailsTableViewController: MFMailComposeViewControllerDelegate {
    
    //MARK: Internal
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("Cancelled")
        case .saved:
            print("Saved")
        case .sent:
            print("Email was Sent")
        case .failed:
            print("Failed to send Email")
        @unknown default:
            fatalError()
        }
        controller.dismiss(animated: true)
    }
}
