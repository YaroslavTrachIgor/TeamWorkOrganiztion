//
//  ProfileUpdateTapSubject.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-12-11.
//

import Foundation

protocol TableViewReloadObserver: AnyObject {
    func reloadTableView()
}


final class ProfileUpdateManager {
    
    static let shared = ProfileUpdateManager()
    
    let buttonTapSubject = ProfileUpdateTapSubject()
    
    private init() {}
}


class ProfileUpdateTapSubject {
    private var observers = [TableViewReloadObserver]()

    func addObserver(_ observer: TableViewReloadObserver) {
        observers.append(observer)
    }

    func removeObserver(_ observer: TableViewReloadObserver) {
        observers = observers.filter { $0 !== observer }
    }

    func notifyObservers() {
        for observer in observers {
            observer.reloadTableView()
        }
    }
    
    func buttonTapped() {
        notifyObservers()
    }
}
