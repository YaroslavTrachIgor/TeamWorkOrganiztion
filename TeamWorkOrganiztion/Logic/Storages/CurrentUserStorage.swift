//
//  CurrentUserManager.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-11-09.
//

import Foundation
import UIKit

//MARK: - Main Storage
/**
 `CurrentUserStorage` serves as a singleton storage for the current user's information within the application. 
 It holds various properties related to the user's profile, including personal details, links to social media profiles, and leave request status.

 - Note: This class is designed to store and manage the current user's data throughout the application lifecycle, providing easy access to user-specific information.
 - Important: Properties in this class are static and can be accessed directly without creating an instance of `CurrentUserStorage`.
 - Remark: To access or update user information, use the static properties provided by this class.
*/
final class CurrentUserStorage {
    
    //MARK: Static
    static var userId: String?               = nil
    static var userName: String?             = nil
    static var fullName: String?             = nil
    static var email: String?                = nil
    static var bio: String?                  = nil
    static var occupation: String?           = nil
    static var department: String?           = nil
    static var profilePhoto: UIImage?        = nil
    static var telegramLink: String?         = nil
    static var linckedInLink: String?        = nil
    static var facebookLink: String?         = nil
    static var isOnVocation: Bool?           = false
    static var isAdmin: Bool?                = false
    static var availableTimeOffDays: Int?    = 24
    static var leaveStartDate: String?       = nil
    static var leaveEndDate: String?         = nil
    static var leaveRequestStatus: UserLeaveRequestStatus? = .unknown
    
    
    //MARK: Initialization
    
    /// Prevents creating instances of `CurrentUserStorage`.
    private init() {}
}
