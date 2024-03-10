//
//  RegisterOrganizationViewController.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-11-10.
//

import UIKit

//MARK: - Main ViewController
final class RegisterOrganizationViewController: UIViewController, BaseStoryboarded {

    //MARK: @IBOutlets
    @IBOutlet private weak var adminFullNameTextField: UITextField!
    @IBOutlet private weak var adminEmailTextField: UITextField!
    @IBOutlet private weak var adminPasswordTextField: UITextField!
    @IBOutlet private weak var adminPasswordConfirmationTextField: UITextField!
    @IBOutlet private weak var organizationNameTextField: UITextField!
    @IBOutlet private weak var organizationKeyTextField: UITextField!
    @IBOutlet private weak var organizationFieldTextField: UITextField!
    @IBOutlet private weak var errorDescriptionTextView: UITextView!
    
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Register Organization"
        
        
        adminFullNameTextField.delegate = self
        adminEmailTextField.delegate = self
        adminPasswordTextField.delegate = self
        adminPasswordConfirmationTextField.delegate = self
        
        organizationNameTextField.delegate = self
        organizationKeyTextField.delegate = self
        organizationFieldTextField.delegate = self
    }
    
    //MARK: @IBActions
    @IBAction func registerOrganization(_ sender: Any) {
        guard let organizationName = organizationNameTextField.text,
              organizationName.count > 6 else {
            presentError(message: "Organization Name must contain at least 6 characters.")
            return
        }
        
        guard let organizationKey = organizationKeyTextField.text,
              organizationKey.count > 6 else {
            presentError(message: "Organization Key must contain at least 6 characters.")
            return
        }
        
        guard adminPasswordConfirmationTextField.text == adminPasswordTextField.text else {
            presentError(message: "Passwords do not match")
            return
        }
        
        DatabaseManager.shared.registerAdmin(fullName: adminFullNameTextField.text,
                                             email: adminEmailTextField.text,
                                             password: adminPasswordTextField.text,
                                             organizationName: organizationNameTextField.text,
                                             organizationKey: organizationKeyTextField.text, 
                                             organizationField: organizationFieldTextField.text) { [self] error in
            if let error = error {
                presentError(message: error.localizedDescription)
                return
            }
            
            errorDescriptionTextView.isHidden = true
            AlertManager.present(title: "Organization was created Successfully",
                                 message: "Your Admin account has been successfully created and added to the new organization.",
                                 onDismiss: { [self] in
                navigationController?.popToRootViewController(animated: true)
            }, on: self)
        }
    }
    
    @IBAction func copyOrganizationKey(_ sender: Any) {
        
    }
    
    @IBAction func copyOrganizationNmae(_ sender: Any) {
        
    }
}


//MARK: - TextField Delegate protocol extension
extension RegisterOrganizationViewController: UITextFieldDelegate {
    
    //MARK: Internal
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
}


//MARK: - Main methods
private extension RegisterOrganizationViewController {
    
    //MARK: Private
    func presentError(message: String) {
        errorDescriptionTextView.isHidden = false
        errorDescriptionTextView.text = message
    }
}
