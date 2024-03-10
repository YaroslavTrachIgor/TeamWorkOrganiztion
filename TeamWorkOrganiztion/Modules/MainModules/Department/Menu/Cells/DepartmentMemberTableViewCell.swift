//
//  DepartmentMemberTableViewCell.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-12-09.
//

import Foundation
import UIKit

final class DepartmentMemberTableViewCell: UITableViewCell {
    
    //MARK: @IBOutlets
    @IBOutlet weak var memberContentBackgroundView: UIView! {
        didSet {
            memberContentBackgroundView.layer.cornerRadius = 12
            memberContentBackgroundView.layer.shadowOffset = CGSize.zero
            memberContentBackgroundView.layer.shadowRadius = 6
            memberContentBackgroundView.layer.shadowOpacity = 0.8
            memberContentBackgroundView.layer.shadowColor = UIColor.systemGray5.cgColor
        }
    }
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var occupationLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
}
