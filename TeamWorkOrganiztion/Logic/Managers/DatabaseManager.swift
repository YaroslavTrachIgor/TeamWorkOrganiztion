//
//  DatabaseManager.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-11-07.
//

import Foundation
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

//MARK: - Constants
public enum DatabaseConstants {
    
    //MARK: Static
    static var departments: [String] = [
        "audit_committee",
        "risk_committee",
        "business_department",
        "treasury_department",
        "asset_management",
        "compliance",
        "information_technology",
        "operations_settlements",
        "finance",
        "hr"
    ]
}



//MARK: - Base typealiases
typealias BaseErrorCompletionHandler = (Error?) -> Void


//MARK: - Main Manager
/**
 The `DatabaseManager` class serves as the main manager 
 for handling interactions with Firebase Firestore and Authentication.
 It provides a set of asynchronous functions for tasks such as user authentication, organization management, and data storage/retrieval.
 
 - Important Notes:
 - Ensure that Firebase is properly configured in your project.
 - This class assumes a specific Firestore database structure. Adjust the implementation as needed for your database schema.
 */
final class DatabaseManager {
    
    //MARK: Static
    static let shared = DatabaseManager()
    
    
    //MARK: Login
    /**
     Function to authenticate a user using email and password
     and retrieve user details from Firestore upon successful authentication.
     - Parameters:
        - email: A non-optional String representing the user's email address.
        - password: A non-optional String representing the user's password.
        - completion: An escaping closure to handle the result of the authentication process. It takes a parameter of type `Error` that represents any error that may occur during authentication.
     */
    func login(email: String!,
               password: String!,
               completion: @escaping BaseErrorCompletionHandler
    ) {
        ///Authenticate the user using Firebase Authentication
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            
            ///Check if there is an authentication error
            guard error == nil else {
                
                ///If there is an error, execute the completion handler on the main queue
                DispatchQueue.main.async { completion(error) }
                return
            }
            
            ///If authentication is successful, retrieve user details from Firestore
            Task {
                await self.getUserDetailsFromFirestore { error in
                    
                    ///Execute the completion handler on the main queue
                    ///The completion handler will contain any error that may occur during user details retrieval
                    DispatchQueue.main.async { completion(error) }
                }
            }
        }
    }
    
    //MARK: User Regiatration
    /**
     Function to register a new user, link them to an organization, and store user details in Firestore.
     - Parameters:
        - email: A non-optional String representing the user's email address.
        - password: A non-optional String representing the user's password.
        - confirmedPassword: A non-optional String representing the confirmed password to ensure accuracy.
        - organizationName: A non-optional String representing the name of the organization to link the user to.
        - organizationKey: A non-optional String representing the key or identifier of the organization.
        - completion: An escaping closure to handle the result of the registration process. It takes a parameter of type `Error` that represents any error that may occur during registration.
     */
    func register(email: String!,
                  password: String!,
                  organizationName: String!,
                  organizationKey: String!,
                  department: String!,
                  completion: @escaping BaseErrorCompletionHandler
    ) {
        ///Link the user to the specified organization using organization key and name.
        self.linkUserToOrganization(organizationName: organizationName, organizationKey: organizationKey) { error in
            
            ///Check if there is an error during organization linking
            guard error == nil else {
                DispatchQueue.main.async { completion(error) }
                return
            }
            
            ///Create a new user in Firebase Authentication
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                
                ///Check if there is any error during user creation
                guard error == nil else { DispatchQueue.main.async { completion(error) }; return }
                
                ///Push new user to the team members list of the organization
                Task {
                    await self.pushNewTeamMemberToFirestore(organizationName: organizationName)
                }
                
                ///Push new team member to the specific department in the organization
                Task {
                    await self.pushNewUserToDepartmentFirestore(organizationName: organizationName,
                                                                department: department)
                }
                
                ///Push new user details to Firestore
                Task {
                    await self.pushNewUserToFirestore(isAdmin: false,
                                                      email: Auth.auth().currentUser?.email,
                                                      fullName: nil, 
                                                      department: department,
                                                      organizationKey: organizationKey,
                                                      organizationName: organizationName) { error in
                        
                        ///Execute the completion handler on the main queue
                        ///The completion handler will contain any error that may occur during user details pushing
                        DispatchQueue.main.async { completion(error) }
                    }
                }
            }
        }
    }
    
    //MARK: Organization Regiatration
    /**
     Function to register a new administrator, create a new organization, and store administrator details in Firestore.
     - Parameters:
        - fullName: A non-optional String representing the full name of the administrator.
        - email: A non-optional String representing the administrator's email address.
        - password: A non-optional String representing the administrator's password.
        - organizationName: A non-optional String representing the name of the organization to be created.
        - organizationKey: A non-optional String representing the key or identifier of the organization.
        - organizationField: A non-optional String representing the field or industry of the organization.
        - completion: An escaping closure to handle the result of the registration process. It takes a parameter of type `Error` that represents any error that may occur during registration.
     */
    func registerAdmin(fullName: String!,
                       email: String!,
                       password: String!,
                       organizationName: String!,
                       organizationKey: String!,
                       organizationField: String!,
                       completion: @escaping BaseErrorCompletionHandler) {
        
        ///Create a new administrator in Firebase Authentication
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            
            ///Check if there is an error during administrator creation
            guard error == nil else {
                
                ///If there is an error, execute the completion handler on the main queue
                DispatchQueue.main.async { completion(error) }
                return
            }
            
            ///Create a new organization in Firestore
            Task {
                await self.createNewOrganization(name: organizationName,
                                                 key: organizationKey,
                                                 field: organizationField, 
                                                 adminFullName: fullName,
                                                 adminEmail: email) { error in
                    
                    ///Check if there is an error during organization creation
                    ///If there is an error, execute the completion handler on the main queue
                    guard error == nil else { DispatchQueue.main.async { completion(error) }; return }
                }
            }
            
            ///Push new user to the team members list of the organization
            Task {
                await self.pushNewTeamMemberToFirestore(organizationName: organizationName)
            }
            
            ///Push admin to the specific department
            Task {
                await self.pushNewUserToDepartmentFirestore(organizationName: organizationName, department: "admin")
            }
            
            ///Push new administrator details to Firestore
            Task {
                await self.pushNewUserToFirestore(isAdmin: true,
                                                  email: email, 
                                                  fullName: fullName, 
                                                  department: "admin",
                                                  organizationKey: organizationKey,
                                                  organizationName: organizationName) { error in
                    
                    ///Check if there is an error during organization creation
                    ///If there is an error, execute the completion handler on the main queue
                    DispatchQueue.main.async { completion(error) }
                }
            }
        }
    }
    
    //MARK: Log Out
    /**
        Function to log out the currently authenticated user.
        - Parameters:
            - completion: An escaping closure to handle the result of the log out process. It takes a parameter of type `Error` that represents any error that may occur during the log out process.
    */
    func logOut(completion: @escaping BaseErrorCompletionHandler) {
        do {
            ///Sign out the currently authenticated user using Firebase Authentication
            try Auth.auth().signOut()
            
            ///Execute the completion handler on the main queue with no error (successful log out)
            DispatchQueue.main.async { completion(nil) }
        } catch {
            
            ///If an error occurs during log out, execute the completion handler on the main queue with the error
            DispatchQueue.main.async { completion(error) }
        }
    }
    
    //MARK: Current User Exists Check
    /**
     Function to check if there is a currently authenticated user.
     - Parameters:
        - completion: A closure to be executed when the check is complete. It takes no parameters.
     */
    func currentUserExists(completion: @escaping () -> Void) {
        if Auth.auth().currentUser != nil {
            DispatchQueue.main.async { completion() }
        }
    }
    
    
    //MARK: Retrieve User by ID
    func getUserDetailsFromFirestore(uid: String!) async -> User? {
        do {
            ///Retrieve user details from Firestore using the user's UID
            let snapshot = try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .getDocument()
            
            ///Check if the retrieved document contains data
            guard let data = snapshot.data() else { return nil }
        
            let id                   = data["user_id"] as? String
            let email                = data["email"] as? String
            let userName             = data["username"] as? String
            let fullName             = data["full_name"] as? String
            let bio                  = data["bio"] as? String
            let department           = data["department"] as? String
            let occupation           = data["occupation"] as? String
            let telegramLink         = data["telegramLink"] as? String
            let linckedInLink        = data["linckedInLink"] as? String
            let facebookLink         = data["facebookLink"] as? String
            let leaveStartDate       = data["leave_start_date"] as? String
            let leaveEndDate         = data["leave_end_date"] as? String
            
            return User(id: id, username: userName, fullName: fullName, email: email, bio: bio, occupation: occupation, department: department, telegramLink: telegramLink, linckedInLink: linckedInLink, facebookLink: facebookLink, leaveStartDate: leaveStartDate, leaveEndDate: leaveEndDate)
        } catch {
            return nil
        }
    }
    
    
    //MARK: Retrieve User Details
    /**
     Asynchronous function to retrieve user details from Firestore and update the current user storage.
     - Parameters:
        - completion: An escaping closure to handle the result of the user details retrieval process. It takes a parameter of type `Error` that represents any error that may occur during the retrieval process.
     - Important:
        - This function assumes the existence of a Firestore collection containing user details. 
        - Update the implementation based on your Firestore database structure.
        - Ensure that Firebase is properly configured in your project.
     */
    func getUserDetailsFromFirestore(completion: @escaping BaseErrorCompletionHandler) async {
        do {
            
            ///Check if there is a currently authenticated user
            guard let uid = Auth.auth().currentUser?.uid else {
                
                ///If no user is authenticated, execute the completion handler on the main queue with no error
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            ///Retrieve user details from Firestore using the user's UID
            let snapshot = try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .getDocument()
            
            ///Check if the retrieved document contains data
            guard let data = snapshot.data() else {
                
                ///If no data is found, execute the completion handler on the main queue 
                ///with a bad server response error
                DispatchQueue.main.async { completion(URLError(.badServerResponse)) }
                return
            }
            
            ///Extract user details from the retrieved data
            let userId               = data["user_id"] as? String
            let email                = data["email"] as? String
            let userName             = data["username"] as? String
            let fullName             = data["full_name"] as? String
            let bio                  = data["bio"] as? String
            let occupation           = data["occupation"] as? String
            let isOnVocation         = data["on_vocation"] as? Bool
            let organizationName     = data["organization_name"] as? String
            let organizationKey      = data["organization_key"] as? String
            let telegramLink         = data["telegramLink"] as? String
            let facebookLink         = data["facebookLink"] as? String
            let linckedInLink        = data["linckedInLink"] as? String
            let department           = data["department"] as? String
            let isAdmin              = data["is_admin"] as? Bool
            let availableTimeOffDays = data["available_timeoff_days"] as? Int
            let leaveStartDate       = data["leave_start_date"] as? String
            let leaveEndDate         = data["leave_end_date"] as? String
            let leaveRequestStatus   = UserLeaveRequestStatus(rawValue: (data["leave_request_status"] as? String ?? "No Request"))
            
            ///Update the current user storage with the retrieved user details
            CurrentUserStorage.userId = userId
            CurrentUserStorage.email = email
            CurrentUserStorage.userName = userName
            CurrentUserStorage.fullName = fullName
            CurrentUserStorage.bio = bio
            CurrentUserStorage.occupation = occupation
            CurrentUserStorage.isOnVocation = isOnVocation
            CurrentUserStorage.telegramLink = telegramLink
            CurrentUserStorage.facebookLink = facebookLink
            CurrentUserStorage.linckedInLink = linckedInLink
            CurrentUserStorage.isAdmin = isAdmin
            CurrentUserStorage.department = department
            CurrentUserStorage.availableTimeOffDays = availableTimeOffDays
            CurrentUserStorage.leaveStartDate = leaveStartDate
            CurrentUserStorage.leaveEndDate = leaveEndDate
            CurrentUserStorage.leaveRequestStatus = leaveRequestStatus
           
            ///Update the current user storage with the retrieved user profile picture
            retrieveProfilePhotoFromFirebaseStorage(userId: uid) { image in
                CurrentUserStorage.profilePhoto = image
            }
            
            ///Link the user to the specified organization
            linkUserToOrganization(organizationName: organizationName, organizationKey: organizationKey) { [self] error in
                
                ///Check if there is an error during linking user to organization
                guard error == nil else {
                    
                    ///If there is an error, execute the completion handler on the main queue
                    DispatchQueue.main.async { completion(error) }
                    return
                }
                
                ///Linking the authenticated user to the specific department
                linkUserToDepartment(organizationName: organizationName, department: department) { error in
                    
                    ///Execute the completion handler on the main queue with any error that may occur during department linking
                    DispatchQueue.main.async { completion(error) }
                }
            }
        } catch {
            
            ///If an error occurs during user details retrieval, 
            ///execute the completion handler on the main queue with the error
            DispatchQueue.main.async { completion(error) }
        }
    }
    
    //MARK: Push User Details
    /**
     Asynchronous function to push user details to Firestore.
     - Parameters:
        - bio: An optional String representing the user's biography.
        - username: An optional String representing the user's username.
        - fullName: An optional String representing the user's full name.
        - occupation: An optional String representing the user's occupation.
        - profilePhoto: A non-optional UIImage representing the user's profile photo.
        - completion: An escaping closure to handle the result of the user details pushing process. It takes a parameter of type `Error` that represents any error that may occur during the pushing process.
     */
    func pushUserDetailsToFirestore(bio: String?,
                                    username: String?,
                                    fullName: String?,
                                    occupation: String?,
                                    profilePhoto: UIImage!,
                                    telegramLink: String!,
                                    linckedInLink: String!,
                                    facebookLink: String!,
                                    completion: @escaping BaseErrorCompletionHandler) async {
        ///Check if there is a currently authenticated user
        guard let currentUser = Auth.auth().currentUser else { return }
        
        ///Prepare a dictionary to internaly  store user details
        var userData: [String: Any] = [:]
        
        ///Check and update user details if provided
        if let bio = bio, !bio.isEmpty {
            userData["bio"] = bio
            CurrentUserStorage.bio = bio
        }
        
        if let username = username, !username.isEmpty {
            userData["username"] = username
            CurrentUserStorage.userName = username
        }
        
        if let fullName = fullName, !fullName.isEmpty {
            userData["full_name"] = fullName
            CurrentUserStorage.fullName = fullName
        }
        
        if let occupation = occupation, !occupation.isEmpty {
            userData["occupation"] = occupation
            CurrentUserStorage.occupation = occupation
        }
        
        if let telegramLink = telegramLink, !telegramLink.isEmpty {
            userData["telegramLink"] = telegramLink
            CurrentUserStorage.telegramLink = telegramLink
        }
        
        if let facebookLink = facebookLink, !facebookLink.isEmpty {
            userData["facebookLink"] = facebookLink
            CurrentUserStorage.facebookLink = facebookLink
        }
        
        if let linckedInLink = linckedInLink, !linckedInLink.isEmpty {
            userData["linckedInLink"] = linckedInLink
            CurrentUserStorage.linckedInLink = linckedInLink
        }
        
        uploadProfilePhotoToFirebaseStorage(image: profilePhoto, userId: currentUser.uid)
        
        do {
            ///Push user details to Firestore using the user's UID
            try await Firestore.firestore()
                .collection("users")
                .document(currentUser.uid)
                .setData(userData, merge: true)
            
            ///Execute the completion handler on the main queue 
            ///with no error (successful user details pushing)
            DispatchQueue.main.async { completion(nil) }
        } catch {
            
            ///If an error occurs during user details pushing,
            ///execute the completion handler on the main queue with the error
            DispatchQueue.main.async { completion(error) }
        }
    }
    
    //MARK: Push Head of Department
    /**
     Pushes new department head details to Firestore for a specific organization and department.
     - Parameters:
        - organizationName: The name of the organization in Firestore.
        - departmentName: The name of the department within the organization.
        - departmentHeadEmail: The email address of the department head.
        - completion: A closure to be executed after the operation completes, indicating success or failure.
     */
    func pushNewDepartmentHeadToFirestore(organizationName: String!,
                                          departmentName: String,
                                          departmentHeadEmail: String!,
                                          completion: @escaping BaseErrorCompletionHandler) async {
        ///Prepare a dictionary with the specific department head details.
        let organizationData: [String: Any] = [
            "\(departmentName)_head_email": departmentHeadEmail!,
        ]
        do {
            ///Push Department Head details to Firestore using the department name
            try await Firestore.firestore()
                .collection("organizations")
                .document(organizationName)
                .setData(organizationData, merge: true)
            
            ///Execute the completion handler on the main queue
            ///with no error (successful user details pushing)
            DispatchQueue.main.async { completion(nil) }
        } catch {
            
            ///If an error occurs during organization details pushing,
            ///execute the completion handler on the main queue with the error
            DispatchQueue.main.async { completion(error) }
        }
    }
    
    //MARK: Push User Leave Status
    func pushLeaveRequestStatusToFirestore(for userId: String,
                                           requestStatus: UserLeaveRequestStatus,
                                           daysAvailable: Int? = nil,
                                           startDate: String? = nil,
                                           endDate: String? = nil,
                                           completion: @escaping BaseErrorCompletionHandler) {
        Task {
            ///Prepare a dictionary with the specific Leave Request details.
            var userData: [String: Any] = [
                "leave_request_status": requestStatus.rawValue,
            ]
            if let startDate = startDate, let endDate = endDate {
                userData["leave_start_date"] = startDate
                userData["leave_end_date"] = endDate
            }
            if let daysAvailable = daysAvailable, let startDate = startDate?.dayMonth(), let endDate = endDate?.dayMonth() {
                let newDaysAvailable = daysAvailable - Date.coutWeekdays(from: startDate, to: endDate)
                userData["available_timeoff_days"] = newDaysAvailable
            }
            do {
                ///Push Leave Request of a user to Firestore using their Id
                try await Firestore.firestore()
                    .collection("users")
                    .document(userId)
                    .setData(userData, merge: true)
                
                ///Execute the completion handler on the main queue
                ///with no error (successful user details pushing)
                DispatchQueue.main.async { completion(nil) }
            } catch {
                
                ///If an error occurs during user details pushing,
                ///execute the completion handler on the main queue with the error
                DispatchQueue.main.async { completion(error) }
            }
        }
    }
    
    //MARK: Push New Leave
    /**
     Pushes a new leave request to Firestore for the current user within the organization.
     
     This asynchronous function stores a new leave request for the current user in the Firestore database of the organization. 
     It gathers necessary user and leave details and stores them under the 'leaves' collection.
     - Parameters:
        - confirmationEmailSent: A Boolean flag indicating whether a confirmation email has been sent for the leave request.
        - purpose: The purpose or reason for the leave.
        - startDate: The start date of the leave request in string format (YYYY-MM-DD).
        - endDate: The end date of the leave request in string format (YYYY-MM-DD).
        - completion: A closure to be called upon completion. It takes an optional `Error` parameter. If the operation is successful, the error parameter is nil; otherwise, it contains the encountered error.
     */
    func pushNewLeaveToFirestore(confirmationEmailSent: Bool,
                                 purpose: String,
                                 startDate: String,
                                 endDate: String,
                                 completion: @escaping BaseErrorCompletionHandler) {
        Task {
            
            ///Check that user's organization details are available
            guard let organizationName = CurrentOrganizationStorage.name,
                  let department = CurrentUserStorage.department else {
                DispatchQueue.main.async { completion(URLError(.badServerResponse)) }
                return
            }
            
            ///Prepare leave request data
            let departmentHeadEmail = await getDepartmentHeadEmail(for: department)
            let leaveData: [String: Any] = [
                "is_recent": true,
                "submitted_date": Date().dayMonth(),
                "department_name": department,
                "department_head_email": departmentHeadEmail ?? "Unknown",
                "employee_full_name": CurrentUserStorage.fullName ?? "Unknown",
                "employee_email": Auth.auth().currentUser?.email ?? "Unknown",
                "employee_id": Auth.auth().currentUser?.uid ?? "Unknown",
                "available_time_off_days": CurrentUserStorage.availableTimeOffDays ?? 0,
                "confirmation_email_sent": confirmationEmailSent,
                "start_date": startDate,
                "end_date": endDate,
                "purpose": purpose,
            ]
            do {
                ///Push leave request details to Firestore
                try await Firestore.firestore()
                    .collection("organizations")
                    .document(organizationName)
                    .collection("leaves")
                    .document("\(CurrentUserStorage.email!)_\(startDate)-\(endDate)")
                    .setData(leaveData, merge: false)
                
                ///Update Current User request status
                pushLeaveRequestStatusToFirestore(for: CurrentUserStorage.userId!,
                                                  requestStatus: .delivered) { error in
                    CurrentUserStorage.leaveRequestStatus = .delivered
                }
                
                ///Execute the completion handler on the main queue
                ///with no error (successful user details pushing)
                DispatchQueue.main.async { completion(nil) }
            } catch {
                
                ///If an error occurs during organization details pushing,
                ///execute the completion handler on the main queue with the error
                DispatchQueue.main.async { completion(error) }
            }
        }
    }
    
    //MARK: Push Leave Updates
    func pushLeaveHistoryToFirebase(documentName: String,
                                    status: String,
                                    completion: @escaping BaseErrorCompletionHandler) {
        Task {
            
            ///Check that user's organization details are available
            guard let organizationName = CurrentOrganizationStorage.name else {
                DispatchQueue.main.async { completion(URLError(.badServerResponse)) }
                return
            }
            let leaveData: [String: Any] = [
                "is_recent": false,
                "status": status,
            ]
            do {
                ///Push leave request details to Firestore
                try await Firestore.firestore()
                    .collection("organizations")
                    .document(organizationName)
                    .collection("leaves")
                    .document(documentName)
                    .setData(leaveData, merge: true)
                
                ///Execute the completion handler on the main queue
                ///with no error (successful user details pushing)
                DispatchQueue.main.async { completion(nil) }
            } catch {
                
                ///If an error occurs during organization details pushing,
                ///execute the completion handler on the main queue with the error
                DispatchQueue.main.async { completion(error) }
            }
        }
    }
    
    //MARK: Retrieve Leaves
    func retrieveLeaveRequests(completion: @escaping BaseErrorCompletionHandler) {
        Firestore.firestore()
            .collection("organizations")
            .document(CurrentOrganizationStorage.name!)
            .collection("leaves")
            .addSnapshotListener { querySnapshot, error in
                
                ///Check if there is an error during the snapshot listener
                guard error == nil else {
                    completion(error);
                    return }
                
                ///Check if there are documents in the snapshot
                guard let documents = querySnapshot?.documents else {
                    print("No Documents"); return }
                
                ///Update the current organization storage
                ///with the department members retrieved from the snapshot
                CurrentOrganizationStorage.leaveRequests = documents.compactMap { queryDocumentSnapshot in
                    return try? queryDocumentSnapshot.data(as: LeaveRequest.self)
                }
                
                ///Execute the completion handler on the main queue with no error (successful department info fetching)
                completion(nil)
            }
    }
    
    //MARK: Push New Task
    func pushNewDepartmentTask(taskId: String,
                               title: String,
                               description: String,
                               isUrgent: Bool,
                               dateCreated: String,
                               deadline: String,
                               status: DepartmentTaskStatus,
                               completion: @escaping BaseErrorCompletionHandler) {
        Task {
            
            let id = UUID()
            
            ///Check that user's organization details are available
            guard let organizationName = CurrentOrganizationStorage.name,
                  let department = CurrentUserStorage.department else {
                DispatchQueue.main.async { completion(URLError(.badServerResponse)) }
                return
            }
            
            ///Prepare department task data
            let leaveData: [String: Any] = [
                "id": id.description,
                "taskId": taskId,
                "title": title,
                "is_urgent": isUrgent,
                "description": description,
                "date_created": dateCreated,
                "deadline": deadline,
                "department": department,
                "initiated_by_email": Auth.auth().currentUser?.email ?? "Unknown",
                "initiated_by_fullname": CurrentUserStorage.fullName ?? "Unknown",
                "status": status.rawValue,
            ]
            do {
                ///Push department task details to Firestore
                try await Firestore.firestore()
                    .collection("organizations")
                    .document(organizationName)
                    .collection("\(department)_tasks")
                    .document(id.description)
                    .setData(leaveData, merge: false)
                
                ///Execute the completion handler on the main queue
                ///with no error (successful user details pushing)
                DispatchQueue.main.async { completion(nil) }
            } catch {
                
                ///If an error occurs during organization details pushing,
                ///execute the completion handler on the main queue with the error
                DispatchQueue.main.async { completion(error) }
            }
        }
    }
    
    //MARK: Update Task Status
    func pushUpdatedDepartmentTaskStatus(with id: String,
                                         status: DepartmentTaskStatus,
                                         completion: @escaping BaseErrorCompletionHandler) {
        Task {
            
            ///Check that user's organization details are available
            guard let organizationName = CurrentOrganizationStorage.name,
                  let department = CurrentUserStorage.department else {
                DispatchQueue.main.async { completion(URLError(.badServerResponse)) }
                return
            }
            
            ///Prepare department task data
            let leaveData: [String: Any] = [
                "status": status.rawValue,
            ]
            do {
                ///Push an updated department task status to Firestore
                try await Firestore.firestore()
                    .collection("organizations")
                    .document(organizationName)
                    .collection("\(department)_tasks")
                    .document(id)
                    .setData(leaveData, merge: true)
                
                ///Execute the completion handler on the main queue
                ///with no error (successful user details pushing)
                DispatchQueue.main.async { completion(nil) }
            } catch {
                
                ///If an error occurs during organization details pushing,
                ///execute the completion handler on the main queue with the error
                DispatchQueue.main.async { completion(error) }
            }
        }
    }
    
    //MARK: Retrieve Tasks
    func retrieveDepartmentTasks(completion: @escaping BaseErrorCompletionHandler) {
        guard let organizationName = CurrentOrganizationStorage.name,
              let department = CurrentUserStorage.department else { return }
        
        Firestore.firestore()
            .collection("organizations")
            .document(organizationName)
            .collection("\(department)_tasks")
            .addSnapshotListener { querySnapshot, error in
                
                ///Check if there is an error during the snapshot listener
                guard error == nil else {
                    completion(error);
                    return }
                
                ///Check if there are documents in the snapshot
                guard let documents = querySnapshot?.documents else {
                    print("No Documents"); return }
                
                ///Update the current organization storage
                ///with the department tasks retrieved from the snapshot
                CurrentOrganizationStorage.departmentTasks = documents.compactMap { queryDocumentSnapshot in
                    return try? queryDocumentSnapshot.data(as: DepartmentTask.self)
                }
                
                ///Execute the completion handler on the main queue with no error (successful department info fetching)
                completion(nil)
            }
    }
}


//MARK: - Main methods
private extension DatabaseManager {
    
    //MARK: Push New Organization
    /**
     Asynchronous function to create a new organization in Firestore.
     - Parameters:
        - name: A non-optional String representing the name of the organization.
        - key: A non-optional String representing the key or identifier of the organization.
        - field: A non-optional String representing the field or industry of the organization.
        - adminFullName: A non-optional String representing the full name of the organization administrator.
        - adminEmail: A non-optional String representing the email address of the organization administrator.
        - completion: An escaping closure to handle the result of the organization creation process. It takes a parameter of type `Error` that represents any error that may occur during the creation process.
     */
    func createNewOrganization(name: String!,
                               key: String!,
                               field: String!,
                               adminFullName: String!,
                               adminEmail: String!,
                               completion: @escaping BaseErrorCompletionHandler) async {
        
        ///Prepare a dictionary with organization details
        let organizationData: [String: Any] = [
            "field"           : field!,
            "organization_key": key!,
            "name"            : name!,
            "admin_fullName"  : adminFullName!,
            "admin_email"     : adminEmail!
        ]
        do {
            ///Create a new organization in Firestore using the organization name as the document ID
            try await Firestore.firestore()
                .collection("organizations")
                .document(name)
                .setData(organizationData, merge: false)
            
            ///Execute the completion handler on the main queue with no error (successful organization creation)
            completion(nil)
        } catch {
            
            ///If an error occurs during organization creation, execute the completion handler on the main queue with the error
            completion(error)
        }
    }
    
    //MARK: Link User to Organization
    /**
     Asynchronous function to link a user to an organization and update the current organization storage.
     - Parameters:
        - organizationName: A non-optional String representing the name of the organization.
        - organizationKey: A non-optional String representing the key or identifier of the organization.
        - completion: An escaping closure to handle the result of the organization linking process. It takes a parameter of type `Error` that represents any error that may occur during the linking process.
     */
    func linkUserToOrganization(organizationName: String!,
                                organizationKey: String!,
                                completion: @escaping BaseErrorCompletionHandler) {
        ///Execute the organization linking process in a background task
        Task {
            do {
                
                ///Retrieve organization details from Firestore using the organization name as the document ID
                let snapshot = try await Firestore.firestore()
                    .collection("organizations")
                    .document(organizationName)
                    .getDocument()
                
                ///Check if the retrieved document contains data
                ///If no data is found, execute the completion handler 
                ///on the main queue with a bad server response error
                guard let data = snapshot.data() else {
                    completion(URLError(.badServerResponse)); return
                }
                
                ///Extract organization details from the retrieved data
                let name             = data["name"] as! String
                let field            = data["field"] as! String
                let key              = data["organization_key"] as! String
                let adminEmail       = data["admin_email"] as! String
                let adminFullName    = data["admin_fullName"] as! String
                
                ///Check if the provided organization key matches the retrieved organization key
                ///If the keys do not match, execute the completion handler on the main queue with no error
                if organizationKey != key {
                    completion(nil); return
                }
                
                ///Update the current organization storage with the retrieved organization details
                CurrentOrganizationStorage.name = name
                CurrentOrganizationStorage.key = key
                CurrentOrganizationStorage.field = field
                CurrentOrganizationStorage.adminEmail = adminEmail
                CurrentOrganizationStorage.adminFullName = adminFullName
                
                for department in DatabaseConstants.departments {
                    CurrentOrganizationStorage.departmentHeadEmails.append(data["\(department)_head_email"] as? String)
                    print("\(department): \(data["\(department)_head_email"] as? String ?? "_")")
                }
                
                ///Set up a snapshot listener for the team members collection in the organization
                Firestore.firestore()
                    .collection("organizations")
                    .document(name)
                    .collection("team_members")
                    .addSnapshotListener { querySnapshot, error in
                    
                    ///Check if there is an error during the snapshot listener
                    guard error == nil else { 
                        completion(error);
                        return }
                    
                    ///Check if there are documents in the snapshot
                    guard let documents = querySnapshot?.documents else { print("No Documents"); return }
                    
                    ///Update the current organization storage
                    /// with the team members retrieved from the snapshot
                    CurrentOrganizationStorage.teamMembers = documents.compactMap { queryDocumentSnapshot in
                        return try? queryDocumentSnapshot.data(as: TeamMember.self)
                    }
                    
                    ///Execute the completion handler on the main queue with no error (successful organization linking)
                    completion(nil)
                }
            } catch {
                ///If an error occurs during organization linking,
                ///execute the completion handler on the main queue with the error
                completion(error)
            }
        }
    }
    
    //MARK: Retrieve Department Members
    func linkUserToDepartment(organizationName: String!,
                              department: String!,
                              completion: @escaping BaseErrorCompletionHandler) {
        
        Firestore.firestore()
            .collection("organizations")
            .document(organizationName)
            .collection(department)
            .addSnapshotListener { querySnapshot, error in
                
                ///Check if there is an error during the snapshot listener
                guard error == nil else {
                    completion(error);
                    return }
                
                ///Check if there are documents in the snapshot
                guard let documents = querySnapshot?.documents else {
                    print("No Documents"); return }
                
                ///Update the current organization storage
                ///with the department members retrieved from the snapshot
                CurrentOrganizationStorage.departmentMembers = documents.compactMap { queryDocumentSnapshot in
                    return try? queryDocumentSnapshot.data(as: TeamMember.self)
                }
                
                ///Execute the completion handler on the main queue with no error (successful department info fetching)
                completion(nil)
            }
    }
    
    //MARK: Retrieve Department Head
    /**
     Retrieves the email of the head of a department within the organization.

     This asynchronous function uses Firebase Firestore to fetch the email of the head of a specified department.
     Once the email is retrieved, it stores it in the CurrentOrganizationStorage and executes the completion handler.
     - Parameters:
        - departmentName: The name of the department to retrieve the head's email for.
     - completion: A closure to be called upon completion. It takes an optional `Error` parameter. If the operation is successful, the error parameter is nil; otherwise, it contains the encountered error.
     */
    func getDepartmentHeadEmail(for departmentName: String) async -> String? {
        do {
            ///Fetch document snapshot from Firestore
            guard let organizationName = CurrentOrganizationStorage.name else { return nil }
            let snapshot = try await Firestore.firestore()
                .collection("organizations")
                .document(organizationName)
                .getDocument()
            
            ///Extract department head email from retrieved data
            guard let data = snapshot.data() else { return nil }
            
            ///Extract department head email from retrieved data
            guard let departmentHeadEmail = data["\(departmentName)_head_email"] as? String else {
                return nil
            }
            
            ///Store department head email in CurrentOrganizationStorage
            CurrentOrganizationStorage.departmentHeadEmail = departmentHeadEmail
            return departmentHeadEmail
        } catch {
            ///If an error occurs during organization linking,
            ///execute the completion handler on the main queue with the error
            return nil
        }
    }
    
    
    //MARK: Push new User
    /**
     Asynchronous function to push new user details to Firestore.
     - Parameters:
        - isAdmin: A non-optional Boolean indicating whether the user has administrative privileges.
        - email: A non-optional String representing the email address of the user.
        - fullName: An optional String representing the full name of the user.
        - organizationKey: A non-optional String representing the key or identifier of the organization.
        - organizationName: A non-optional String representing the name of the organization.
        - completion: An escaping closure to handle the result of the user details pushing process. It takes a parameter of type `Error` that represents any error that may occur during the pushing process.
     */
    func pushNewUserToFirestore(isAdmin: Bool!,
                                email: String!,
                                fullName: String!,
                                department: String!,
                                organizationKey: String!,
                                organizationName: String!,
                                completion: BaseErrorCompletionHandler) async {
        
        ///Check if there is a currently authenticated user
        guard let currentUser = Auth.auth().currentUser else { return }
        
        ///Prepare a dictionary with user details
        var userData: [String: Any] = [
            "user_id": currentUser.uid,
            "is_admin": isAdmin!,
            "email": email!,
            "department": department!,
            "organization_key": organizationKey!,
            "organization_name": organizationName!,
            "available_timeoff_days": 24,
        ]
        
        ///Check and update user details if full name is provided
        if let fullName = fullName {
            userData["full_name"] = fullName
        }
        
        do {
            ///Push user details to Firestore using the user's UID as the document ID
            try await Firestore.firestore()
                .collection("users")
                .document(currentUser.uid)
                .setData(userData, merge: false)
            
            ///Execute the completion handler on the main queue
            ///with no error (successful user details pushing)
            completion(nil)
        } catch {
            ///If an error occurs during user details pushing,
            ///execute the completion handler on the main queue with the error
            completion(error)
        }
    }
    
    //MARK: Push new Team Member
    /**
     Pushes a new team member entry to Firestore under the specified organization's `team_members` collection.
     - Parameters:
        - organizationName: A string representing the name of the organization where the team member is being added.
     */
    func pushNewTeamMemberToFirestore(organizationName: String) async {
        if let userId = Auth.auth().currentUser?.uid {
            let teamMemberData: [String: Any] = [
                "user_id"           : userId,
                "date_created"      : Timestamp()
            ]
            
            try? await Firestore.firestore()
                .collection("organizations")
                .document(organizationName)
                .collection("team_members")
                .document()
                .setData(teamMemberData)
        }
    }
    
    //MARK: Link Team Member to Department
    /** 
     Pushes a new team member entry to Firestore under the specified organization's department collection.
     - Parameters:
        - organizationName: A string representing the name of the organization where the team member is being added.
        - department: A string representing the specific department under which the team member is being added.
     */
    func pushNewUserToDepartmentFirestore(organizationName: String, department: String) async {
        if let userId = Auth.auth().currentUser?.uid {
            let teamMemberData: [String: Any] = [
                "user_id"           : userId,
                "date_created"      : Timestamp()
            ]
            
            try? await Firestore.firestore()
                .collection("organizations")
                .document(organizationName)
                .collection(department)
                .document()
                .setData(teamMemberData)
        }
    }
    
    //MARK: Push Photo
    func uploadProfilePhotoToFirebaseStorage(image: UIImage?, userId: String) {
        guard let image = image, image != UIImage(systemName: "person.crop.circle") else { return }
        
        let storageRef = Storage.storage().reference()
        
        let imageData = image.jpegData(compressionQuality: 0.8)
        
        guard imageData != nil else { return }
        
        let fileRef = storageRef.child("images/\(userId).jpg")
        
        let uploadTask = fileRef.putData(imageData!, metadata: nil) { metadata, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
        }
    }
    
    //MARK: Retrieve Photo
    func retrieveProfilePhotoFromFirebaseStorage(userId: String, completion: @escaping (UIImage?) -> ()) {
        let storageRef = Storage.storage().reference()
        let profilePhotoRef = storageRef.child("images/\(userId).jpg")
        profilePhotoRef.getData(maxSize: 15 * 1024 * 1024) { data, error in
            if let error = error {
                completion(nil)
            } else {
                completion(UIImage(data: data!)!)
            }
        }
    }
}
