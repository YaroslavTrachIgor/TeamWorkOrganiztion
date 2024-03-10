//
//  DetailTaskTableViewController.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-12-03.
//

import UIKit

final class DetailTaskTableViewController: UITableViewController, BaseStoryboarded {
    
    var departmentTask: WFResponse!
    
    private var currentStatus: DepartmentTaskStatus!
    
    private var statusUpdateFirstOption: DepartmentTaskStatus!
    private var statusUpdateSecondOption: DepartmentTaskStatus!
    
    private var statusColor: UIColor!
    private var statusUpdateFirstOptionColor: UIColor!
    private var statusUpdateSecondOptionColor: UIColor!
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var taskIdLabel: UILabel!
    @IBOutlet private weak var stateName: UILabel!
    @IBOutlet private weak var startDate: UILabel!
    @IBOutlet private weak var checkedOutToLabel: UILabel!
    @IBOutlet private weak var checkedOutDateLabel: UILabel!
    @IBOutlet private weak var checkOutToTableViewCell: UITableViewCell!
    @IBOutlet private weak var checkOutDateTableViewCell: UITableViewCell!
    
    @IBOutlet private weak var groupTaskIDLabel: UILabel!
    @IBOutlet private weak var WFAssignedRoleIDLabel: UILabel!
    @IBOutlet private weak var WFTemplateIDLavel: UILabel!
    @IBOutlet private weak var WFInstanceIDLabel: UILabel!
    @IBOutlet private weak var stateIDLabel: UILabel!
    
    @IBOutlet private weak var postDatedDaysLabel: UILabel!
    @IBOutlet private weak var isMultiApprovalLabel: UILabel!
    @IBOutlet private weak var isDelegationTaskLabel: UILabel!
    
    @IBOutlet private weak var isInitialStepLabel: UILabel!
    @IBOutlet private weak var isAutomatedStepLabel: UILabel!
    @IBOutlet private weak var isFinalStepLABEL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = departmentTask.WFInstance.ApplicationReference
        taskIdLabel.text = String(departmentTask.WFTaskInstance_JSON[0].ID ?? 0)
        
        stateName.text = departmentTask.WFTaskInstance_JSON[0].StateName
        stateIDLabel.text = String(departmentTask.WFTaskInstance_JSON[0].StateID ?? 0)
        
        
        groupTaskIDLabel.text = String(departmentTask.WFTaskInstance_JSON[0].GroupTaskID ?? 0)
        WFAssignedRoleIDLabel.text = String(departmentTask.WFTaskInstance_JSON[0].WFAssignedRoleID ?? 0)
        WFTemplateIDLavel.text = String(departmentTask.WFTaskInstance_JSON[0].WFTemplateID ?? 0)
        WFInstanceIDLabel.text = String(departmentTask.WFTaskInstance_JSON[0].WFInstanceID ?? 0)
        
        
        if !departmentTask.WFTaskInstance_JSON[0].isCheckedOut! {
            isInitialStepLabel.text = departmentTask.WFTaskInstance_JSON[0].isInitialStep! ? "YES" : "NO"
            isAutomatedStepLabel.text = departmentTask.WFTaskInstance_JSON[0].isAutomatedStep! ? "YES" : "NO"
            isFinalStepLABEL.text = departmentTask.WFTaskInstance_JSON[0].isFinalStep! ? "YES" : "NO"
            
            startDate.text = Date.convertDateString(departmentTask.WFTaskInstance_JSON[0].StartDate ?? "Unknown Date")
            
            setupYesNoLabel(tintColor: departmentTask.WFTaskInstance_JSON[0].isInitialStep! ? .systemIndigo : .systemPurple, for: isInitialStepLabel)
            setupYesNoLabel(tintColor: departmentTask.WFTaskInstance_JSON[0].isAutomatedStep! ? .systemIndigo : .systemPurple, for: isAutomatedStepLabel)
            setupYesNoLabel(tintColor: departmentTask.WFTaskInstance_JSON[0].isFinalStep! ? .systemIndigo : .systemPurple, for: isFinalStepLABEL)
        } else {
            isInitialStepLabel.text = "NO"
            isAutomatedStepLabel.text = "NO"
            isFinalStepLABEL.text = "NO"
            
            startDate.text = Date.convertCheckedOutDateString(departmentTask.WFTaskInstance_JSON[0].StartDate ?? "Unknown Date")
            
            setupYesNoLabel(tintColor: .systemPurple, for: isInitialStepLabel)
            setupYesNoLabel(tintColor: .systemPurple, for: isAutomatedStepLabel)
            setupYesNoLabel(tintColor: .systemPurple, for: isFinalStepLABEL)
        }
        
        postDatedDaysLabel.text = String(departmentTask.WFTaskInstance_JSON[0].PostDatedDays ?? 0)
        
        isMultiApprovalLabel.text = departmentTask.WFTaskInstance_JSON[0].RequireMultiRoleMemberApproval ?? false ? "YES" : "NO"
        setupYesNoLabel(tintColor: departmentTask.WFTaskInstance_JSON[0].RequireMultiRoleMemberApproval ?? false ? .systemIndigo : .systemPurple, for: isMultiApprovalLabel)
        
        isDelegationTaskLabel.text = departmentTask.WFTaskInstance_JSON[0].isDelegationTask! == 1 ? "YES" : "NO"
        setupYesNoLabel(tintColor: departmentTask.WFTaskInstance_JSON[0].isDelegationTask! == 1 ? .systemIndigo : .systemPurple, for: isDelegationTaskLabel)
        
        if departmentTask.WFTaskInstance_JSON[0].isCheckedOut! {
            checkedOutToLabel.text = departmentTask.WFTaskInstance_JSON[0].CheckOutTo_UserName
            checkedOutDateLabel.text = Date.convertDateString(departmentTask.WFTaskInstance_JSON[0].CheckedOutDate ?? "Unknown Date")
        } else {
            checkOutToTableViewCell.isHidden = true
            checkOutDateTableViewCell.isHidden = true
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 42
        } else {
            return 16
        }
    }
    
    @IBAction func copyTaskURL(_ sender: Any) {
        if let taskURL = departmentTask.WFTaskInstance_JSON[0].TaskURL {
            UIPasteboard.general.string = taskURL
            AlertManager.present(title: "Copied",
                                 message: "Task URL was successfully copied to your pasteboard.", on: self)
        } else {
            AlertManager.presentError(message: "Task URL is unknown.", on: self)
        }
    }
    
    @IBAction func copyTaskPageURL(_ sender: Any) {
        if let taskPageURL = departmentTask.WFTaskInstance_JSON[0].TaskPageURL {
            UIPasteboard.general.string = taskPageURL
            AlertManager.present(title: "Copied", 
                                 message: "Task Page URL was successfully copied to your pasteboard.", on: self)
        } else {
            AlertManager.presentError(message: "Task Page URL is unknown.", on: self)
        }
    }
    
    private func setupYesNoLabel(tintColor: UIColor, for label: UILabel) {
        label.textColor = tintColor
        label.backgroundColor = tintColor.withAlphaComponent(0.14)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 6
    }
}
