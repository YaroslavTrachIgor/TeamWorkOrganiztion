//
//  TimeOffRequestTableViewCell.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-11-22.
//

import Foundation
import UIKit

final class TimeOffRequestTableViewCell: UITableViewCell {
    
    var onApprove: (() -> Void)!
    var onDecline: (() -> Void)!
    
    //MARK: Private
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var submittedOnLabel: UILabel!
    @IBOutlet private weak var fullNameLabel: UILabel!
    @IBOutlet private weak var startDateLabel: UILabel!
    @IBOutlet private weak var endDateLabel: UILabel!
    @IBOutlet private weak var daysAvailableLabel: UILabel!
    @IBOutlet private weak var purposeLabel: UILabel!
    @IBOutlet private weak var confirmationSentLabel: UILabel!
    @IBOutlet private weak var diclineButton: UIButton!
    @IBOutlet private weak var approveButton: UIButton!
    
    //MARK: Public
    func configureCell(with leaveRequest: LeaveRequest) {
        Task {
            let user = await DatabaseManager.shared.getUserDetailsFromFirestore(uid: leaveRequest.employeeID)
            
            if let employeeID = leaveRequest.employeeID {
                iconImageView.downloadProfilePictire(with: employeeID)
            }
            
            if let fullName = user?.fullName, !fullName.isEmpty {
                fullNameLabel.text = fullName
            } else {
                fullNameLabel.text = "Unknown Name"
            }
        }
        
        submittedOnLabel.text = "Submitted on \(leaveRequest.submittedDate ?? "Unknwon Date")"
        
        startDateLabel.text = leaveRequest.startDate
        endDateLabel.text = leaveRequest.endDate
        daysAvailableLabel.text = String(leaveRequest.availableTimeOffDays!)
        purposeLabel.text = leaveRequest.purpose
        confirmationSentLabel.text = leaveRequest.confirmationEmailSent! ? "Yes" : "No"
        diclineButton.isEnabled = true
        approveButton.isEnabled = true
    }
    
    //MARK: @IBAction
    @IBAction func approve(_ sender: UIButton) {
        onApprove()
    }
    
    @IBAction func decline(_ sender: Any) {
        onDecline()
    }
}
