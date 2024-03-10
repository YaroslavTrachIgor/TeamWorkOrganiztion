//
//  UIExtensions.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-11-08.
//

import Foundation
import FirebaseStorage
import UIKit

//MARK: - Fast Color methods
public extension UIColor {
    
    //MARK: Static
    static let baseTintColor = UIColor.systemOrange
}


//MARK: - Fast Image methods
public extension UIImage {
    
    //MARK: Public
    func convertToStringData() -> String? {
        let picData = self.jpegData(compressionQuality: 0.7)!
        let options = NSData.Base64EncodingOptions(rawValue: 0)
        let picString = picData.base64EncodedString(options: options)
        return picString
    }
}


//MARK: - Fast String methods
public extension String {
    
    //MARK: Public
    func toImage() -> UIImage? {
        let options = NSData.Base64DecodingOptions(rawValue: 0)
        let decodedData = NSData(base64Encoded: self, options: options)
        let decodedImage = UIImage(data: decodedData! as Data)
        return decodedImage
    }
}


//MARK: - Fast ImageView methods
extension UIImageView {
    
    //MARK: Public
    func downloadProfilePictire(with userID: String) {
        let storageRef = Storage.storage().reference()
        let profilePictureRef = storageRef.child("images/\(userID).jpg")
        profilePictureRef.getData(maxSize: 15 * 1024 * 1024) { data, error in
            if error != nil {
                print(error!.localizedDescription)
                self.image = UIImage(systemName: "person.crop.circle")
            } else {
                self.image = UIImage(data: data!)
            }
        }
    }
}
