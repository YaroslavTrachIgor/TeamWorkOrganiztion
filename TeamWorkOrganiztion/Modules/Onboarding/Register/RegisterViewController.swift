//
//  RegisterViewController.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-11-07.
//

import UIKit

final class RegisterViewController: UIViewController, BaseStoryboarded {

    //MARK: Private
    private let pickerView = UIPickerView()
    private var choosedDepartment: String!
    
    //MARK: @IBOutlets
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    @IBOutlet private weak var organizationKeyTextField: UITextField!
    @IBOutlet private weak var organizationNameTextField: UITextField!
    @IBOutlet private weak var errorDescriptionLabel: UITextView!
    @IBOutlet private weak var chooseDepartmentButton: UIButton!
    
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        organizationKeyTextField.delegate = self
        organizationNameTextField.delegate = self
        
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    //MARK: @@IBActions
    @IBAction func signUp(_ sender: Any) {
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
        
        guard let department = choosedDepartment else {
            presentError(message: "Please, choose your department.")
            return
        }
        
        guard confirmPasswordTextField.text == passwordTextField.text else {
            presentError(message: "Passwords do not match")
            return
        }
        
        DatabaseManager.shared.register(email: emailTextField.text,
                                        password: passwordTextField.text,
                                        organizationName: organizationName,
                                        organizationKey: organizationKey,
                                        department: department) { [self] error in
            if let error = error {
                presentError(message: error.localizedDescription)
                return
            }
            
            errorDescriptionLabel.isHidden = true
            AlertManager.present(title: "Signed Up Successfully", 
                                 message: "Your account has been successfully created and added to the desired organization.",
                                 onDismiss: { [self] in
                navigationController?.popToRootViewController(animated: true)
            }, on: self)
        }
    }
    
    @IBAction func chooseDepartment(_ sender: Any) {
        let alertController = UIAlertController(title: "Select Depatment", message: nil, preferredStyle: .actionSheet)
        let pickerViewController = UIViewController()
        
        let pickerWidth: CGFloat = 250
        let pickerHeight: CGFloat = 200
        
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerViewController.view.addSubview(pickerView)

        pickerView.centerXAnchor.constraint(equalTo: pickerViewController.view.centerXAnchor).isActive = true
        pickerView.centerYAnchor.constraint(equalTo: pickerViewController.view.centerYAnchor).isActive = true

        pickerView.widthAnchor.constraint(equalToConstant: pickerWidth).isActive = true
        pickerView.heightAnchor.constraint(equalToConstant: pickerHeight).isActive = true

        alertController.setValue(pickerViewController, forKey: "contentViewController")
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [self] action in
            chooseDepartmentButton.setTitle("Choose your Department", for: .normal)
            choosedDepartment = nil
        }
        let okAction = UIAlertAction(title: "Choose", style: .default, handler: nil)
        alertController.view.tintColor = .baseTintColor
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}


//MARK: - Main methods
private extension RegisterViewController {
    
    //MARK: Private
    func presentError(message: String) {
        errorDescriptionLabel.isHidden = false
        errorDescriptionLabel.text = message
    }
}


//MARK: - TextField Delegate protocol extension
extension RegisterViewController: UITextFieldDelegate {
    
    //MARK: Internal
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
}


//MARK: - PickerView protocols extension
extension RegisterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK: Internal
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        DatabaseConstants.departments.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        DatabaseConstants.departments[row].transformDepartmentKey()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        choosedDepartment = DatabaseConstants.departments[row]
        chooseDepartmentButton.setTitle(DatabaseConstants.departments[row].transformDepartmentKey(), for: .normal)
    }
}
