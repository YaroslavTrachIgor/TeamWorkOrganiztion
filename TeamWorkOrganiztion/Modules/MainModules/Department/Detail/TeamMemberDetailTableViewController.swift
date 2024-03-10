//
//  TeamMemberDetailTableViewController.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-11-13.
//

import UIKit

final class TeamMemberDetailTableViewController: UITableViewController, BaseStoryboarded {
    
    var user: User?
    
    @IBOutlet private weak var availableLabel: UILabel!
    @IBOutlet private weak var availableBackgroundView: UIView!
    @IBOutlet private weak var availableIconView: UIView!
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var fullNameLabel: UILabel!
    @IBOutlet private weak var occupationLabel: UILabel!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var detailFullNameLabel: UILabel!
    @IBOutlet private weak var detailOccupationLabel: UILabel!
    @IBOutlet private weak var departmentLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        
        print(user?.leaveStartDate ?? "Unknown Start")
        print(user?.leaveEndDate ?? "Unknown End")
        
        title = "Profile"
        
        if let startDate = user?.leaveStartDate, let endDate = user?.leaveEndDate {
            if startDate.dayMonth() > Date() || endDate.dayMonth() < Date() {
                availableIconView.backgroundColor = .systemGreen.withAlphaComponent(0.8)
                availableLabel.text = "Available"
            } else {
                availableIconView.backgroundColor = .systemRed.withAlphaComponent(0.8)
                availableLabel.text = "Not Available"
            }
        }
        
        
        availableBackgroundView.layer.cornerRadius = 8
        availableBackgroundView.layer.shadowRadius = 4
        availableBackgroundView.layer.shadowOffset = CGSize.zero
        availableBackgroundView.layer.shadowColor = UIColor.systemGray.cgColor
        availableBackgroundView.layer.shadowOpacity = 0.4
        
        if let userId = user?.id {
            profileImageView.downloadProfilePictire(with: userId)
        }
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 1.5
        profileImageView.contentMode = .scaleToFill
        
        fullNameLabel.text = user?.fullName ?? "Unknown Name"
        occupationLabel.text = user?.occupation ?? "Unknown Occupation"
        
        usernameLabel.text = "@" + (user?.username ?? "unknown")
        detailFullNameLabel.text = user?.fullName ?? "Unknown"
        detailOccupationLabel.text = user?.occupation ?? "Unknown"
        departmentLabel.text = user?.department?.transformDepartmentKey() ?? "Unknown"
        emailLabel.text = user?.email ?? "Unknown"
        
        tableView.backgroundColor = .systemGroupedBackground
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
    }
    
    @IBAction func shareProfile(_ sender: Any) {
        let textToShare = """
        username: \(usernameLabel.text!)
        Full name: \(detailFullNameLabel.text!)
        Email: \(emailLabel.text!)
        Occupation: \(detailOccupationLabel.text!)
        Department: \(departmentLabel.text!)
        """
        let activityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        activityViewController.view.tintColor = .baseTintColor
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func copyTelegramLink(_ sender: Any) {
        if let telegramLink = user?.telegramLink {
            AlertManager.present(title: "Copied", message: "Telegram Link was copied to your pasteboard.", on: self)
            UIPasteboard.general.string = telegramLink
        } else {
            AlertManager.presentError(message: "The following user did not add a link to their Telegram account", on: self)
        }
    }
    
    @IBAction func copyLinckedInLink(_ sender: Any) {
        if let linckedInLink = user?.linckedInLink {
            AlertManager.present(title: "Copied", message: "LinckedIn Link was copied to your pasteboard.", on: self)
            UIPasteboard.general.string = linckedInLink
        } else {
            AlertManager.presentError(message: "The following user did not add a link to their LinckedIn account", on: self)
        }
    }
    
    @IBAction func copyFacebookLink(_ sender: Any) {
        if let facebookLink = user?.facebookLink {
            AlertManager.present(title: "Copied", message: "Facebook Link was copied to your pasteboard.", on: self)
            UIPasteboard.general.string = facebookLink
        } else {
            AlertManager.presentError(message: "The following user did not add a link to their Facebook account", on: self)
        }
    }
}
