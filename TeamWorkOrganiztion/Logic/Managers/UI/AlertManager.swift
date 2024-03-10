//
//  AlertManager.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-11-08.
//

import Foundation
import UIKit

private enum Constants {
    
    //MARK: Static
    static let errorTitle = "Error"
    static let continueTitle = "Continue"
    static let okTitle = "OK"
}

//MARK: - Main Manager
final class AlertManager {
    
    //MARK: Static
    static func present(title: String, 
                        message: String,
                        okTitle: String = Constants.okTitle,
                        on vc: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertOKAction = UIAlertAction(title: okTitle, style: .cancel)
        alertController.addAction(alertOKAction)
        alertController.view.tintColor = .baseTintColor
        vc.present(alertController, animated: true)
    }
    
    static func present(title: String,
                        message: String,
                        okTitle: String = Constants.continueTitle,
                        actionTitle: String,
                        action: @escaping () -> Void,
                        on vc: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: actionTitle, style: .default, handler: { _ in
            action()
        })
        let alertOKAction = UIAlertAction(title: okTitle, style: .cancel)
        alertController.addAction(alertAction)
        alertController.addAction(alertOKAction)
        alertController.view.tintColor = .baseTintColor
        vc.present(alertController, animated: true)
    }
    
    static func present(title: String, 
                        message: String,
                        dismissTitle: String = Constants.continueTitle,
                        onDismiss: @escaping () -> Void,
                        on vc: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertContinueAction = UIAlertAction(title: dismissTitle, style: .cancel, handler: { _ in
            onDismiss()
        })
        alertController.addAction(alertContinueAction)
        alertController.view.tintColor = .baseTintColor
        vc.present(alertController, animated: true)
    }
}


//MARK: - Fast methods
extension AlertManager {
    
    //MARK: Static
    static func presentError(message: String, on vc: UIViewController) {
        present(title: Constants.errorTitle, message: message, on: vc)
    }
}
