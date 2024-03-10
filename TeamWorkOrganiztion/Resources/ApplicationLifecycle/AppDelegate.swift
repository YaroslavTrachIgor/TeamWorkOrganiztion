//
//  AppDelegate.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-11-07.
//

import UIKit
import Firebase

//MARK: - Application delegate Keys
extension AppDelegate {
    
    //MARK: Public
    enum Keys {
        enum AppDelegateConstants {
            
            //MARK: Static
            static let sceneConfigurationName = "Default Configuration"
        }
        enum StoryboardNames {
            
            //MARK: Static
            static let main = "Main"
        }
    }
}


//MARK: - Main AppDelegate
@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    //MARK: Lifecycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: Keys.AppDelegateConstants.sceneConfigurationName, sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}

