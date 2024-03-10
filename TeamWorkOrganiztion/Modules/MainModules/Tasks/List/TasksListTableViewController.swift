//
//  TasksListTableViewController.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-11-29.
//

import UIKit

final class TasksListTableViewController: UITableViewController {
    
    private var tasksService: TasksAPIProtocol = TasksAPI()
    private var tasks: [WFResponse] = []
    private var filteredTasks: [WFResponse] = []
    
    @IBOutlet private weak var tasksSegmentedControl: UISegmentedControl!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupSegmentedControl()
        fetchTasks()
    }

    //MARK: TableView protocols
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 18
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let departmentTask = filteredTasks[indexPath.row]
        let cellIdentifier = String(describing: DepartmentTaskTableViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DepartmentTaskTableViewCell
        let cellBackgroundView = UIView()
        cellBackgroundView.backgroundColor = .clear
        cell.selectedBackgroundView = cellBackgroundView
        cell.configure(with: departmentTask)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let departmentTask = filteredTasks[indexPath.row]
        let detailViewController = DetailTaskTableViewController.instantiate()
        detailViewController.departmentTask = departmentTask
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    //MARK: @IBActions
    @IBAction func filterTasks(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            filteredTasks = tasks.filter { !$0.WFTaskInstance_JSON[0].isCheckedOut! }
        case 1:
            filteredTasks = tasks.filter { $0.WFTaskInstance_JSON[0].isCheckedOut! }
        default:
            break
        }
        tableView.reloadData()
    }
}


//MARK: - Main methods
private extension TasksListTableViewController {
    
    //MARK: Private
    func fetchTasks() {
        do {
//            Task {
//                tasks = try await tasksService.getTasks(url: URL(string: "insert your url here"))
//            }
            tasks = try tasksService.loadJSONFromFile()
            filteredTasks = tasks.filter { !$0.WFTaskInstance_JSON[0].isCheckedOut! }
            tableView.reloadData()
        } catch {
            AlertManager.presentError(message: error.localizedDescription, on: self)
        }
    }
    
    func setupTableView() {
        tableView.rowHeight = 115
        tableView.allowsSelection = true
    }
    
    func setupSegmentedControl() {
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemBackground]
        tasksSegmentedControl.setTitleTextAttributes(titleTextAttributes, for: .selected)
    }
}
