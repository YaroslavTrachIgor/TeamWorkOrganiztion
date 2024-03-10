//
//  ViewController.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-11-07.
//

import UIKit

//MARK: - Main ViewController
final class LoginViewController: UIViewController, BaseStoryboarded {

    //MARK: @IBOutlets
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    
    //MARK: Overrides
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTextField.delegate = self
        emailTextField.delegate = self
        
        DatabaseManager.shared.currentUserExists { [weak self] in
            self?.presentMainModulesTabBarController()
        }
    }
    
    //MARK: @IBActions
    @IBAction func login(_ sender: Any) {
        DatabaseManager.shared .login(email: emailTextField.text, password: passwordTextField.text) { [self] error in
            guard error == nil else {
                AlertManager.present(title: "Error", message: error!.localizedDescription, on: self)
                return
            }
            
            presentMainModulesTabBarController()
        }
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        
    }
    
    @IBAction func register(_ sender: Any) {
        presentRegisterViewController()
    }
    
    @IBAction func createOrganization(_ sender: Any) {
        presentRegisterOrganizationViewController()
    }
}


//MARK: - TextField Delegate protocol extension
extension LoginViewController: UITextFieldDelegate {
    
    //MARK: Internal
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
}



//MARK: - Main methods
private extension LoginViewController {
    
    //MARK: Private
    func presentRegisterViewController() {
        let registerViewController = RegisterViewController.instantiate()
        navigationController?.pushViewController(registerViewController, animated: true)
    }
    
    func presentMainModulesTabBarController() {
        let mainModulesTabBarController = MainModulesTabBarController.instantiate()
        mainModulesTabBarController.modalPresentationStyle = .fullScreen
        present(mainModulesTabBarController, animated: true)
    }
    
    func presentRegisterOrganizationViewController() {
        let registerOrganizationViewController = RegisterOrganizationViewController.instantiate()
        navigationController?.pushViewController(registerOrganizationViewController, animated: true)
    }
}
