//
//  AddNewTaskTableViewController.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-11-29.
//

import UIKit

final class AddNewTaskTableViewController: UITableViewController {

    private var taskId = ""
    private var taskName = ""
    private var taskDescription = ""
    private var isUrgent = false
    private var deadline = Date()
    
    @IBOutlet private weak var taskDescriptionTextView: UITextView!
    @IBOutlet private weak var deadlineDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    @IBAction func setDeadlineDate(_ sender: UIDatePicker) {
        deadline = sender.date
    }
    
    @IBAction func setTaskName(_ sender: UITextField) {
        taskName = sender.text ?? ""
    }
    
    @IBAction func setCustomTaskId(_ sender: UITextField) {
        taskId = sender.text ?? ""
    }
    
    @IBAction func urgentTask(_ sender: UISwitch) {
        isUrgent = sender.isOn
    }
    
    @IBAction func dismiss(_ sender: Any) {
        navigationController?.dismiss(animated: true)
    }
    
    @IBAction func createNewTask(_ sender: Any) {
        DatabaseManager.shared.pushNewDepartmentTask(taskId: taskId,
                                                     title: taskName,
                                                     description: taskDescriptionTextView.text!,
                                                     isUrgent: isUrgent,
                                                     dateCreated: Date().dayMonth(),
                                                     deadline: deadline.dayMonth(),
                                                     status: .inProgress) { [self] error in
            guard error == nil else {
                AlertManager.presentError(message: error!.localizedDescription, on: self)
                return
            }
            
            navigationController?.dismiss(animated: true)
        }
    }
}


extension AddNewTaskTableViewController: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        view.endEditing(true)
    }
}


extension AddNewTaskTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
}
