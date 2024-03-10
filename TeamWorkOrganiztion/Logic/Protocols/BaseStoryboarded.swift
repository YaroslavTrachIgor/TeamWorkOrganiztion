//
//  BaseStoryboarded.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-11-07.
//

import Foundation
import UIKit

//MARK: - Main Storyboarded protocol
/**
 The protocol below wil be used for fast `Storyboard` `UIViewControllers` initianalization
 to proteсt application from possible crashes.
 
 This protocol will normally be used for the so called `Detail` VCs
 which will be shown after selecting the desired cell on `Menu` TableViewControllers.
 */
protocol BaseStoryboarded {
    static var storyboardName: String { get }
    static func instantiate() -> Self
}


//MARK: - Preparing base values ​​for protocol Instances
extension BaseStoryboarded where Self: UIViewController {
    
    //MARK: Static
    static var storyboardName: String {
        AppDelegate.Keys.StoryboardNames.main
    }
    
    static func instantiate() -> Self {
        let identifier = String(describing: Self.self)
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier) as! Self
    }
}
