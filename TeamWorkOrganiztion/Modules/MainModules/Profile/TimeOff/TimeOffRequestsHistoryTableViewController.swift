//
//  TimeOffRequestsHistoryTableViewController.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-11-27.
//

import UIKit

final class TimeOffRequestsHistoryTableViewController: UITableViewController {

    private var leaveRequests = [LeaveRequest]()
    
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 210
        tableView.allowsSelection = false
        
        fetchLeaveRequests()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Requests History"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaveRequests.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let leaveRequest = leaveRequests[row]
        let identifier = String(describing: TimeOffRequestHistoryTableViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! TimeOffRequestHistoryTableViewCell
        cell.configureCell(with: leaveRequest)
        return cell
    }
}


//MARK: - Main methods
private extension TimeOffRequestsHistoryTableViewController {
    
    //MARK: Private
    func fetchLeaveRequests() {
        let currentUserEmail = CurrentUserStorage.email
        
        DatabaseManager.shared.retrieveLeaveRequests { [self] error in
            guard error == nil else {
                AlertManager.presentError(message: error!.localizedDescription, on: self)
                return
            }
            leaveRequests = CurrentOrganizationStorage.leaveRequests.filter({ request in
                if CurrentOrganizationStorage.departmentHeadEmails.contains(currentUserEmail) {
                    !request.isRecent! && request.departmentHeadEmail == currentUserEmail
                } else if CurrentUserStorage.department == "hr" {
                    true
                } else {
                    !request.isRecent!
                }
            })
            tableView.reloadData()
        }
    }
}
