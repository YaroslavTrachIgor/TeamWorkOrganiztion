//
//  ForgotPasswordViewController.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-12-09.
//

import UIKit
import FirebaseAuth

final class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet private weak var emailTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func sendPassworodResetEmail(_ sender: Any) {
        Auth.auth().sendPasswordReset(withEmail: emailTextField.text!) { error in
            guard error == nil else {
                AlertManager.presentError(message: error!.localizedDescription, on: self)
                return
            }
            
            AlertManager.present(title: "Confirmation Email Sent",
                                 message: "Password Reset confiramtion email was successfully sent to your email address.",
                                 onDismiss: {
                self.dismiss(animated: true)
            }, on: self)
        }
    }
}
