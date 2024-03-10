//
//  EditProfileTableViewController.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-11-10.
//

import UIKit
import Photos

//MARK: - Main ViewController
final class EditProfileTableViewController: UITableViewController, BaseStoryboarded {
    
    //MARK: Weak
    weak var delegate: ProfileTableViewControllerDelegate?
    
    //MARK: @IBOutlets
    @IBOutlet private weak var occupationTextField: UITextField!
    @IBOutlet private weak var fullNameTextField: UITextField!
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var bioTextField: UITextField!
    @IBOutlet private weak var profilePictureImageView: UIImageView!
    @IBOutlet private weak var setNewPhotoButton: UIButton!
    @IBOutlet private weak var facebookLinkTextField: UITextField!
    @IBOutlet private weak var linckedInLinkTextField: UITextField!
    @IBOutlet private weak var telegramLinkTextField: UITextField!
    
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        occupationTextField.text = CurrentUserStorage.occupation
        fullNameTextField.text = CurrentUserStorage.fullName
        usernameTextField.text = CurrentUserStorage.userName
        bioTextField.text = CurrentUserStorage.bio
        
        facebookLinkTextField.text = CurrentUserStorage.facebookLink
        linckedInLinkTextField.text = CurrentUserStorage.linckedInLink
        telegramLinkTextField.text = CurrentUserStorage.telegramLink
        
        occupationTextField.delegate = self
        fullNameTextField.delegate = self
        usernameTextField.delegate = self
        bioTextField.delegate = self
        facebookLinkTextField.delegate = self
        linckedInLinkTextField.delegate = self
        telegramLinkTextField.delegate = self
        
        setupProfilePictureImageView()
    }
    
    //MARK: @IBActions
    @IBAction func setNewPhoto(_ sender: Any) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { [self] status in
                DispatchQueue.main.async { [self] in
                    if status == .authorized {
                        presentImagePicker()
                    } else {
                        presentPhotoLibraryNotAuthorizedAlert()
                    }
                }
            }
        } else if status == .authorized {
            DispatchQueue.main.async { [self] in
                presentImagePicker()
            }
        } else {
            DispatchQueue.main.async { [self] in
                presentPhotoLibraryNotAuthorizedAlert()
            }
        }
    }

    @IBAction func logOut(_ sender: Any) {
        DatabaseManager.shared.logOut { [self] error in
            if let error = error {
                AlertManager.presentError(message: error.localizedDescription, on: self)
                return
            }
            
            navigationController?.dismiss(animated: true)
        }
    }
    
    @IBAction func save(_ sender: Any) {
        Task {
            await DatabaseManager.shared.pushUserDetailsToFirestore(bio: bioTextField.text,
                                                                    username: usernameTextField.text,
                                                                    fullName: fullNameTextField.text,
                                                                    occupation: occupationTextField.text,
                                                                    profilePhoto: profilePictureImageView.image,
                                                                    telegramLink: telegramLinkTextField.text,
                                                                    linckedInLink: linckedInLinkTextField.text,
                                                                    facebookLink: facebookLinkTextField.text
            ) { [self] error in
                if let error = error {
                    AlertManager.presentError(message: error.localizedDescription, on: self)
                    return
                }
            }
            
            await DatabaseManager.shared.getUserDetailsFromFirestore { [self] error in
                if let error = error {
                    AlertManager.presentError(message: error.localizedDescription, on: self)
                    return
                }
                
                delegate?.reloadData()
                ProfileUpdateManager.shared.buttonTapSubject.buttonTapped()
                navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}


//MARK: - Main methods
private extension EditProfileTableViewController {
    
    //MARK: Private
    func presentImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func setupProfilePictureImageView() {
        let cornerRadius: CGFloat = profilePictureImageView.frame.height / 2
        guard let profileImage = CurrentUserStorage.profilePhoto else {
            profilePictureImageView.image = UIImage(systemName: "person.crop.circle")
            return
        }
        profilePictureImageView.layer.cornerRadius = cornerRadius
        profilePictureImageView.contentMode = .scaleAspectFill
        profilePictureImageView.image = profileImage
    }
    
    func presentPhotoLibraryNotAuthorizedAlert() {
        AlertManager.present(title: "Not Authorized",
                             message: "The App is not authorized to use your photo library to pick new photo for your Profile Picture.",
                             on: self)
    }
}


//MARK: - ImagePickerController Delegate protocol extension
extension EditProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Internal
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            profilePictureImageView.image = selectedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


//MARK: - TextField Delegate protocol extension
extension EditProfileTableViewController: UITextFieldDelegate {
    
    //MARK: Internal
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
}
