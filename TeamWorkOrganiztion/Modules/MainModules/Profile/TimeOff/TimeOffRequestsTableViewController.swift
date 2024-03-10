//
//  TimeOffRequestsTableViewController.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-11-22.
//

import UIKit
import MessageUI


final class TimeOffRequestsTableViewController: UITableViewController {
    
    //MARK: Weak
    weak var delegate: ProfileTableViewControllerDelegate?

    private var leaveRequests = [LeaveRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchLeaveRequests()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.reloadData()
    }

    //MARK: Lifecycle
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Recent Requests"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaveRequests.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let leaveRequest = leaveRequests[row]
        let identifier = String(describing: TimeOffRequestTableViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! TimeOffRequestTableViewCell
        cell.configureCell(with: leaveRequests[row])
        cell.onApprove = { self.approve(leaveRequest: leaveRequest) }
        cell.onDecline = { self.decline(leaveRequest: leaveRequest) }
        return cell
    }
}



private extension TimeOffRequestsTableViewController {
    
    func reloadTableView() {
        tableView.rowHeight = 286
        tableView.reloadData()
    }
    
    func fetchLeaveRequests() {
        DatabaseManager.shared.retrieveLeaveRequests { [self] error in
            
            guard let currentUserEmail = CurrentUserStorage.email, error == nil else {
                AlertManager.presentError(message: error!.localizedDescription, on: self)
                return
            }
            
            leaveRequests = CurrentOrganizationStorage.leaveRequests.filter({ request in
                if CurrentOrganizationStorage.departmentHeadEmails.contains(currentUserEmail) {
                    request.isRecent! && request.departmentHeadEmail == currentUserEmail
                } else if CurrentUserStorage.occupation == "CEO" {
                    request.isRecent! && CurrentOrganizationStorage.departmentHeadEmails.contains(request.employeeEmail)
                } else {
                    request.isRecent!
                }
            })
            reloadTableView()
        }
    }
    
    func approve(leaveRequest: LeaveRequest) {
        guard let employeeEmail = leaveRequest.employeeEmail else { return }
        
        if CurrentUserStorage.email == employeeEmail { presentInsufficientPermissionAlert(); return }
        
        if CurrentOrganizationStorage.departmentHeadEmails.contains(employeeEmail) && (CurrentUserStorage.occupation!.lowercased() != "ceo") {
            presentCEOErrorAlert()
            return
        }
        
        guard let userId = leaveRequest.employeeID else { return }
        DatabaseManager.shared.pushLeaveRequestStatusToFirestore(for: userId,
                                                                 requestStatus: .approved,
                                                                 daysAvailable: leaveRequest.availableTimeOffDays,
                                                                 startDate: leaveRequest.startDate,
                                                                 endDate: leaveRequest.endDate) { [self] error in
            guard error == nil else {
                AlertManager.presentError(message: error!.localizedDescription, on: self)
                return
            }
            presentRequestApprovedAlert(leaveRequest: leaveRequest)
            putRequestToHistory(leaveRequest: leaveRequest, status: "Approved")
        }
    }
    
    func decline(leaveRequest: LeaveRequest) {
        guard let employeeEmail = leaveRequest.employeeEmail else { return }
        
        if CurrentUserStorage.email == employeeEmail { presentInsufficientPermissionAlert(); return }
        
        if CurrentOrganizationStorage.departmentHeadEmails.contains(employeeEmail) && (CurrentUserStorage.occupation?.lowercased() != "ceo") {
            presentCEOErrorAlert()
            return
        }
        
        guard let userId = leaveRequest.employeeID else { return }
        DatabaseManager.shared.pushLeaveRequestStatusToFirestore(for: userId, 
                                                                 requestStatus: .noRequest) { [self] error in
            guard error == nil else {
                AlertManager.presentError(message: error!.localizedDescription, on: self)
                return
            }
            presentRequestDeclinedAlert(leaveRequest: leaveRequest)
            putRequestToHistory(leaveRequest: leaveRequest, status: "Declined")
        }
    }
    
    func putRequestToHistory(leaveRequest: LeaveRequest, status: String) {
        guard let employeeEmail = leaveRequest.employeeEmail,
              let startDate = leaveRequest.startDate,
              let endDate = leaveRequest.endDate else { return }
        let documentName = "\(employeeEmail)_\(startDate)-\(endDate)"
        DatabaseManager.shared.pushLeaveHistoryToFirebase(documentName: documentName, status: status) { [self] error in
            guard error == nil else {
                AlertManager.presentError(message: error!.localizedDescription, on: self)
                return
            }
            reloadTableView()
        }
    }
    
    func presentRequestApprovedAlert(leaveRequest: LeaveRequest) {
        AlertManager.present(title: "Request Approved",
                             message: "The employee's request for Time-Off was successfully approved.",
                             actionTitle: "Send Confirmation to Employee", action: {
            MailManager.sendLeaveRequestStatus(.approved,
                                               employeeEmail: leaveRequest.employeeEmail!,
                                               employeeFullName: leaveRequest.employeeFullName,
                                               departmentHeadEmail: leaveRequest.departmentHeadEmail,
                                               mailComposeDelegate: self,
                                               on: self)
        }, on: self)
    }
    
    func presentRequestDeclinedAlert(leaveRequest: LeaveRequest) {
        AlertManager.present(title: "Request Declined", 
                             message: "The employee's request for Time-Off was successfully declined.",
                             actionTitle: "Send Confirmation to Employee", action: {
            MailManager.sendLeaveRequestStatus(.noRequest,
                                               employeeEmail: leaveRequest.employeeEmail!,
                                               employeeFullName: leaveRequest.employeeFullName,
                                               departmentHeadEmail: leaveRequest.departmentHeadEmail,
                                               mailComposeDelegate: self,
                                               on: self)
        }, on: self)
    }
    
    func presentInsufficientPermissionAlert() {
        AlertManager.present(title: "Insufficient Permission",
                             message: "You do not have permission to approve/decline your own Time-Off requests.",
                             on: self)
    }
    
    func presentCEOErrorAlert() {
        AlertManager.present(title: "Insufficient Permission",
                             message: "Only the CEO can approve/decline Time-Off requests of Heads of Departments (If you are the company's CEO, please fill in the Occupation field with 'CEO'.",
                             on: self)
    }
}


//MARK: - MessageComposeViewController Delegate protocol extension
extension TimeOffRequestsTableViewController: MFMailComposeViewControllerDelegate {
    
    //MARK: Internal
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled:
            print("Canceled")
        case .sent:
            AlertManager.present(title: "Confirmation Sent", 
                                 message: "Time-Off Request Status Update letter was successfully sent to the employee.",
                                 on: self)
        case .failed:
            print("failed")
        @unknown default:
            break
        }
        controller.dismiss(animated: true)
    }
}
