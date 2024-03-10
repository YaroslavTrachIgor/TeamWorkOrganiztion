//
//  TimeOffRequestHistoryTableViewCell.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-11-27.
//

import UIKit

final class TimeOffRequestHistoryTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var requestStatusLabel: UIButton!
    @IBOutlet private weak var fullNameLabel: UILabel!
    @IBOutlet private weak var submittedOnLabel: UILabel!
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var startDateLabel: UILabel!
    @IBOutlet private weak var endDateLabel: UILabel!
    @IBOutlet private weak var purposeLabel: UILabel!
    @IBOutlet private weak var confirmationEmailSentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    //MARK: Public
    func configureCell(with leaveRequest: LeaveRequest) {
        Task {
            let user = await DatabaseManager.shared.getUserDetailsFromFirestore(uid: leaveRequest.employeeID)
            
            if let employeeID = leaveRequest.employeeID {
                profileImageView.downloadProfilePictire(with: employeeID)
            }
            if let fullName = user?.fullName, !fullName.isEmpty {
                fullNameLabel.text = fullName
            } else {
                fullNameLabel.text = "Unknown Name"
            }
        }
        
        submittedOnLabel.text = "Submitted on \(leaveRequest.submittedDate ?? "Unknwon Date")"
        
        var requestStatusLabelTitleColor: UIColor
        var backgroundColor: UIColor
        
        switch leaveRequest.status {
        case "Approved":
            requestStatusLabelTitleColor = .systemGreen
            backgroundColor = .systemGreen.withAlphaComponent(0.12)
        case "Declined":
            requestStatusLabelTitleColor = .systemRed
            backgroundColor = .systemRed.withAlphaComponent(0.12)
        default:
            requestStatusLabelTitleColor = .link
            backgroundColor = .link.withAlphaComponent(0.12)
        }
        
        requestStatusLabel.layer.cornerRadius = 5
        requestStatusLabel.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        requestStatusLabel.setTitle(leaveRequest.status?.uppercased() ?? "Delivered".uppercased(), for: .normal)
        requestStatusLabel.setTitleColor(requestStatusLabelTitleColor, for: .normal)
        requestStatusLabel.backgroundColor = backgroundColor
        
        startDateLabel.text = leaveRequest.startDate
        endDateLabel.text = leaveRequest.endDate
        purposeLabel.text = leaveRequest.purpose
        confirmationEmailSentLabel.text = leaveRequest.confirmationEmailSent! ? "Yes" : "No"
    }
}
