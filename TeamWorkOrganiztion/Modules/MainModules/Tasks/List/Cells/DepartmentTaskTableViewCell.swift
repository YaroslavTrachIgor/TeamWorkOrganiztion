//
//  DepartmentTaskTableViewCell.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-12-02.
//

import Foundation
import UIKit

final class DepartmentTaskTableViewCell: UITableViewCell {
    
    private var statusColor: UIColor!
    
    @IBOutlet weak var progressRectangleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    func configure(with task: WFResponse) {
        titleLabel.text = task.WFInstance.ApplicationReference
        
        if task.WFTaskInstance_JSON[0].isCheckedOut! {
            descriptionLabel.text = Date.convertCheckedOutDateString(task.WFTaskInstance_JSON[0].StartDate ?? "Unknown Start Date")?.uppercased() ?? "Unknown Start Date".uppercased()
            descriptionLabel.numberOfLines = 1
        } else {
            descriptionLabel.text = Date.convertDateString(task.WFTaskInstance_JSON[0].StartDate ?? "Unknown Start Date")?.uppercased() ?? "Unknown Start Date".uppercased()
            descriptionLabel.numberOfLines = 1
        }
        
        if task.WFTaskInstance_JSON[0].isCheckedOut! {
            statusColor = .systemIndigo
        } else {
            statusColor = .systemGreen
        }
        
        statusLabel.text = "State: \(task.WFTaskInstance_JSON[0].StateName?.lowercased() ?? DepartmentTaskStatus.inProgress.rawValue)"
        
        progressRectangleView.backgroundColor = statusColor.withAlphaComponent(0.15)
    }
}
