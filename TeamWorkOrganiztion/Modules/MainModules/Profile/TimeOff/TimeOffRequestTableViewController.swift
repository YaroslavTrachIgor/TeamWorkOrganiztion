//
//  TimeOffRequestTableViewController.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-11-14.
//

import UIKit
import MessageUI

//MARK: - Main ViewController
final class TimeOffRequestTableViewController: UITableViewController {

    //MARK: Weak
    weak var delegate: ProfileTableViewControllerDelegate?
    
    //MARK: Private
    private var confirmationEmaiSent = false
    private var startDate = Date()
    private var endDate = Date()
    private var purpose = "Vocation"
    
    //MARK: @IBOutlets
    @IBOutlet private weak var purposeButton: UIButton!
    @IBOutlet private weak var startDateLabel: UILabel!
    @IBOutlet private weak var endDateLabel: UILabel!
    @IBOutlet private weak var availableDaysLabel: UILabel!
    @IBOutlet private weak var sendEmailButton: UIButton!
    
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(CurrentUserStorage.leaveStartDate)
        print(CurrentUserStorage.leaveEndDate)
        
        availableDaysLabel.text = String(CurrentUserStorage.availableTimeOffDays ?? 0) + " Days"
        
        let actions = [
            UIAction(title: "Vocation", image: nil, handler: { [self] action in
                updatePurpose(action.title)
            }),
            UIAction(title: "Sickness", image: nil, handler: { [self] action in
                updatePurpose(action.title)
            }),
            UIAction(title: "Annual", image: nil, handler: { [self] action in
                updatePurpose(action.title)
            }),
            UIAction(title: "Emergency", image: nil, handler: { [self] action in
                updatePurpose(action.title)
            }),
            UIAction(title: "Education", image: nil, handler: { [self] action in
                updatePurpose(action.title)
            }),
            UIAction(title: "Hajj (unpaid)", image: nil, handler: { [self] action in
                updatePurpose(action.title)
            }),
            UIAction(title: "Partial", image: nil, handler: { [self] action in
                updatePurpose(action.title)
            }),
            UIAction(title: "Working from Home", image: nil, handler: { [self] action in
                updatePurpose(action.title)
            }),
            UIAction(title: "Block", image: nil, handler: { [self] action in
                updatePurpose(action.title)
            }),
            UIAction(title: "PTO", image: nil, handler: { [self] action in
                updatePurpose(action.title)
            }),
            UIAction(title: "Jury Duty", image: nil, handler: { [self] action in
                updatePurpose(action.title)
            })
        ]
        
        let menu = UIMenu(title: "Choose Purpose of the Request", children: actions)
        purposeButton.showsMenuAsPrimaryAction = true
        purposeButton.menu = menu
        purposeButton.contentHorizontalAlignment = .trailing
        purposeButton.setTitle("Vocation", for: .normal)
        
        if !MFMailComposeViewController.canSendMail() {
            sendEmailButton.isEnabled = false
        }
    }
    
    //MARK: @IBActions
    @IBAction func sendEmailToEmployer(_ sender: Any) {
        MailManager.sendLeaveRequestConfirmation(mailComposeDelegate: self, on: self)
    }
    
    @IBAction func sendRequest(_ sender: Any) {
        if CurrentUserStorage.leaveRequestStatus == .delivered {
            AlertManager.present(title: "Two Requests at a time", message: "You cannot send more than one Time-Off request a time.", on: self)
        } else if startDate.isDateInWeekend {
            AlertManager.presentError(message: "Your leave cannot start on the weekend. Consider requesting a Time-Off that will start from a working day.", on: self)
        } else if endDate.isDateInWeekend {
            AlertManager.presentError(message: "Your leave cannot end on the weekend. Consider requesting a Time-Off that will end on a working day.", on: self)
        } else if let leaveStartDate = CurrentUserStorage.leaveStartDate?.dayMonth(),
                  let leaveEndDate = CurrentUserStorage.leaveEndDate?.dayMonth(),
                  leaveStartDate < startDate && leaveEndDate > endDate {
            AlertManager.presentError(message: "Your Time-Off request for the selected dates has been already approved.", on: self)
        } else if startDate <= Date.dateOneDayBefore(Date()) {
            AlertManager.presentError(message: "Your Leave cannot start in the past.", on: self)
        } else if endDate < startDate {
            AlertManager.presentError(message: "Your Leave starting date cannot be greater than the ending date.", on: self)
        } else if (Date.coutWeekdays(from: startDate, to: endDate) <= 0) && !(startDate == endDate) {
            AlertManager.presentError(message: "Your Leave seems to contain all the weekend days.", on: self)
        } else if purpose == "Block" && Date.coutWeekdays(from: startDate, to: endDate) < 10 {
            AlertManager.presentError(message: "Your Block leave should last two or more continuous weeks.", on: self)
        } else {
            DatabaseManager.shared.pushNewLeaveToFirestore(confirmationEmailSent: confirmationEmaiSent,
                                                           purpose: purpose,
                                                           startDate: startDate.dayMonth(),
                                                           endDate: endDate.dayMonth()) { error in
                guard error == nil else {
                    AlertManager.presentError(message: error?.localizedDescription ?? "Unknown Error", on: self)
                    return
                }
                AlertManager.present(title: "Submitted Successfully", 
                                     message: "Your Time-Off Request was successfully submitted.",
                                     onDismiss: {
                    self.delegate?.reloadData()
                    self.navigationController?.popToRootViewController(animated: true)
                }, on: self)
            }
        }
    }
    
    @IBAction func setStartDate(_ sender: UIDatePicker) {
        startDate = sender.date
    }
    
    @IBAction func setEndDate(_ sender: UIDatePicker) {
        endDate = sender.date
    }
}


//MARK: - Main methods
private extension TimeOffRequestTableViewController {
    
    //MARK: Private
    func updatePurpose(_ purpose: String) {
        purposeButton.setTitle(purpose, for: .normal)
        self.purpose = purpose
    }
}


//MARK: - MFMailComposeViewController Delegate protocol extension
extension TimeOffRequestTableViewController: MFMailComposeViewControllerDelegate {
    
    //MARK: Internal
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("Cancelled")
        case .saved:
            print("Saved")
        case .sent:
            confirmationEmaiSent = true
            print("Sent")
        case .failed:
            print("Failed to send Email")
        @unknown default:
            fatalError()
        }
        controller.dismiss(animated: true)
    }
}
