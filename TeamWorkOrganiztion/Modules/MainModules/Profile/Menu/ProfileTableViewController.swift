//
//  ProfileTableViewController.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-11-08.
//

import UIKit
import Foundation

//MARK: - ViewController Delegate protcol
protocol ProfileTableViewControllerDelegate: AnyObject {
    func reloadData()
}


//MARK: - Main ViewController
final class ProfileTableViewController: UITableViewController {

    //MARK: @IBOutlets
    @IBOutlet private weak var profilePhoto: UIImageView!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var logOutButton: UIBarButtonItem!
    @IBOutlet private weak var timeOffRequestsCell: UITableViewCell!
    @IBOutlet private weak var requestTimeOffCell: UITableViewCell!
    @IBOutlet private weak var timeOffRequestsHistoryCell: UITableViewCell!
    @IBOutlet private weak var requestNotificationsIndicatorButton: UIButton!
    
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 40
        tableView.allowsSelection = false
        
        requestNotificationsIndicatorButton.isHidden = true
        
        Task {
            await DatabaseManager.shared.getUserDetailsFromFirestore { [self] error in
                setupProfilePhoto()
                setupEmailLabel()
                setupUserNameLabel()
                
                if error == nil {
                    tableView.allowsSelection = true
                } else {
                    AlertManager.presentError(message: error!.localizedDescription, on: self)
                }
                
                DatabaseManager.shared.retrieveLeaveRequests { [self] error in
                    if error == nil {
                        let currentUserEmail = CurrentUserStorage.email
                        let recentRequests = CurrentOrganizationStorage.leaveRequests.filter { request in
                            if CurrentUserStorage.occupation == "CEO" {
                                request.isRecent! && CurrentOrganizationStorage.departmentHeadEmails.contains(request.employeeEmail)
                            } else if CurrentOrganizationStorage.departmentHeadEmails.contains(currentUserEmail) {
                                request.isRecent! && request.departmentHeadEmail == currentUserEmail
                            } else {
                                request.isRecent!
                            }
                        }
                        if recentRequests.count > 0 {
                            requestNotificationsIndicatorButton.setTitle("\(recentRequests.count)", for: .normal)
                            requestNotificationsIndicatorButton.isHidden = false
                        }
                    } else {
                        AlertManager.presentError(message: error!.localizedDescription, on: self)
                    }
                }
                tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if cell == requestTimeOffCell && CurrentUserStorage.isAdmin! {
            return 0
        }
        
        if cell == timeOffRequestsCell && CurrentOrganizationStorage.departmentHeadEmails.contains(CurrentUserStorage.email) {
            return 40
        }
        
        if cell == timeOffRequestsHistoryCell && CurrentUserStorage.department != "hr" {
            return 0
        }
        
        if cell == timeOffRequestsCell && (CurrentUserStorage.occupation?.lowercased() == "ceo" || CurrentUserStorage.occupation?.lowercased() == "chief executive officer") {
            return 40
        }
        
        if cell == timeOffRequestsCell && !CurrentUserStorage.isAdmin! {
            return 0
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TimeOffRequestSegueIdentifier" {
            if let destinationVC = segue.destination as? TimeOffRequestTableViewController {
                destinationVC.delegate = self
            }
        }
        
        if segue.identifier == "TimeOffRequestsSegueIdentifier" {
            if let destinationVC = segue.destination as? TimeOffRequestsTableViewController {
                destinationVC.delegate = self
            }
        }
        
        if segue.identifier == "EditProfileSegueIdentifier" {
            if let destinationVC = segue.destination as? EditProfileTableViewController {
                destinationVC.delegate = self
            }
        }
    }
    
    //MARK: @IBActions
    @IBAction func logOut(_ sender: Any) {
        DatabaseManager.shared.logOut { [self] _ in
            dismiss(animated: true)
        }
    }
}


//MARK: - ViewController Delegate protcol extension
extension ProfileTableViewController: ProfileTableViewControllerDelegate {
    
    //MARK: Internal
    func reloadData() {
        viewDidLoad()
    }
}


//MARK: - Main methods
private extension ProfileTableViewController {
    
    //MARK: Private
    func setupEmailLabel() {
        guard let email = CurrentUserStorage.email else {
            emailLabel.text = "Unknown Email"
            return
        }
        emailLabel.text = email
    }
    
    func setupUserNameLabel() {
        guard let userName = CurrentUserStorage.fullName else {
            userNameLabel.text = "Unknown Name"
            return
        }
        userNameLabel.text = userName
    }
    
    func setupProfilePhoto() {
        let cornerRadius: CGFloat = profilePhoto.frame.height / 2
        guard let profileImage = CurrentUserStorage.profilePhoto else {
            profilePhoto.image = UIImage(systemName: "person.crop.circle")
            return
        }
        profilePhoto.layer.cornerRadius = cornerRadius
        profilePhoto.contentMode = .scaleAspectFill
        profilePhoto.image = profileImage
    }
}
