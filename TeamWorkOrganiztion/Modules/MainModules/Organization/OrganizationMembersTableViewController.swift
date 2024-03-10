//
//  OrganizationMembersTableViewController.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-12-07.
//

import Foundation
import UIKit


final class OrganizationMembersTableViewController: UITableViewController, TableViewReloadObserver {
    
    private var organizationMembers = [String: [User]]()
    private var sectionTitles = [String]()
    private var filteredMembers = [User]()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var activityIndicator = UIActivityIndicatorView()
    private var loadingLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 70
        
        setupSearchController()
        addActivityIndicator()
        addLoadingLabel()
        
        Task {
            await fetchOrganizationMembers()
        }
        
        ProfileUpdateManager.shared.buttonTapSubject.addObserver(self)
    }
    
    deinit {
        ProfileUpdateManager.shared.buttonTapSubject.removeObserver(self)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return searchController.isActive ? 1 : sectionTitles.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return filteredMembers.count
        } else {
            let sectionTitle = sectionTitles[section]
            return organizationMembers[sectionTitle]?.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return searchController.isActive ? "Search Results" : sectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = String(describing: OrganizationMemberTableViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! OrganizationMemberTableViewCell
        
        let user: User
        if searchController.isActive {
            user = filteredMembers[indexPath.row]
        } else {
            let sectionTitle = sectionTitles[indexPath.section]
            let usersInSection = organizationMembers[sectionTitle] ?? []
            user = usersInSection[indexPath.row]
        }
        
        cell.fullnameLabel.text = user.fullName ?? user.email ?? "Unknown Name"
        cell.profileImageView.downloadProfilePictire(with: user.id!)
        cell.ocupationLabel.text = "\(user.occupation ?? "Unknown Occupation") • @\(user.username ?? "unknown")"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user: User
        if searchController.isActive {
            user = filteredMembers[indexPath.row]
        } else {
            let sectionTitle = sectionTitles[indexPath.section]
            let usersInSection = organizationMembers[sectionTitle] ?? []
            user = usersInSection[indexPath.row]
        }
        let detailViewController = TeamMemberDetailTableViewController.instantiate()
        detailViewController.user = user
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    
    func reloadTableView() {
        viewDidLoad()
    }
    
    
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Members"
        searchController.searchBar.tintColor = .baseTintColor
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func addActivityIndicator() {
        activityIndicator.style = .medium
        activityIndicator.center = CGPoint(x: view.center.x, y: view.frame.maxY + 100)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    private func addLoadingLabel() {
        loadingLabel.text = "Loading..."
        loadingLabel.textColor = .systemGray
        loadingLabel.sizeToFit()
        loadingLabel.center = CGPoint(x: view.center.x, y: view.frame.maxY + 100)
        view.addSubview(loadingLabel)
    }
    
    private func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    private func hideLoadingLabel() {
        loadingLabel.removeFromSuperview()
    }
    
    private func fetchOrganizationMembers() async {
        let usersDetails = await fetchUsersDetails()
        
        organizationMembers = Dictionary(grouping: usersDetails) { user in
            guard let name = user.fullName ?? user.email else { return "" }
            return String(name.prefix(1))
        }
        
        sectionTitles = organizationMembers.keys.sorted()
        
        hideLoadingLabel()
        hideActivityIndicator()
        tableView.reloadData()
    }
    
    private func fetchUsersDetails() async -> [User] {
        let departmentMemberIds = CurrentOrganizationStorage.teamMembers.map { $0.userId }
        let userDetails = await fetchUserDetails(for: departmentMemberIds)
        return userDetails.compactMap { $0 }
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



extension OrganizationMembersTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        
        if searchText.isEmpty {
            filteredMembers.removeAll()
        } else {
            filteredMembers = organizationMembers.values.flatMap { $0.filter { user in
                let fullName = user.fullName ?? user.email ?? ""
                return fullName.localizedCaseInsensitiveContains(searchText)
            }}
        }
        tableView.reloadData()
    }
}


final class OrganizationMemberTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var ocupationLabel: UILabel!
    @IBOutlet weak var fullnameLabel: UILabel!
}
