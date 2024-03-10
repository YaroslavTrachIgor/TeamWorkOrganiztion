//
//  DepartmentTableViewController.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-11-12.
//

import UIKit

final class DepartmentTableViewController: UITableViewController, TableViewReloadObserver {

    private var users = [User]()
    private var activityIndicator = UIActivityIndicatorView()
    private var loadingLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 140
        
        addActivityIndicator()
        addLoadingLabel()
        
        Task {
            await DatabaseManager.shared.getUserDetailsFromFirestore { [self] error in
                Task {
                    let departmentMemberIds = CurrentOrganizationStorage.departmentMembers.map { $0.userId }
                    let userDetails = await fetchUserDetails(for: departmentMemberIds)
                    users = userDetails.compactMap { $0 }
                    
                    hideLoadingLabel()
                    hideActivityIndicator()
                    tableView.reloadData()
                }
            }
        }
        
        ProfileUpdateManager.shared.buttonTapSubject.addObserver(self)
    }
    
    deinit {
        ProfileUpdateManager.shared.buttonTapSubject.removeObserver(self)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = String(describing: DepartmentMemberTableViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! DepartmentMemberTableViewCell
        let user = users[indexPath.row]
        cell.fullNameLabel.text = user.fullName ?? "Unknown Name"
        cell.emailLabel.text = "\(user.email ?? "Unknown Email")"
        cell.occupationLabel.text = "\(user.occupation ?? "Unknown Occupation") • @\(user.username ?? "unknown")"
        
        if let userID = user.id {
            cell.iconImageView.downloadProfilePictire(with: userID)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        let detailViewController = TeamMemberDetailTableViewController.instantiate()
        detailViewController.user = user
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    
    func reloadTableView() {
        viewDidLoad()
    }
    
    
    private func addActivityIndicator() {
        activityIndicator.style = .medium
        activityIndicator.center = CGPoint(x: navigationController!.navigationBar.center.x, y: navigationController!.navigationBar.frame.maxY + 20)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    private func addLoadingLabel() {
        loadingLabel.text = "Loading..."
        loadingLabel.textColor = .systemGray
        loadingLabel.sizeToFit()
        loadingLabel.center = CGPoint(x:  navigationController!.navigationBar.center.x, y: activityIndicator.frame.maxY + 30)
        view.addSubview(loadingLabel)
    }
    
    private func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    private func hideLoadingLabel() {
        loadingLabel.removeFromSuperview()
    }
    
    private func fetchUserDetails(for userIds: [String?]) async -> [User?] {
        var userDetails = [User?]()
        for userId in userIds {
            if let user = await DatabaseManager.shared.getUserDetailsFromFirestore(uid: userId) {
                userDetails.append(user)
            }
        }
        return userDetails
    }
}
