//
//  MainViewController.swift
//  NudgeMe
//
//  Created by Joab Maldonado on 11/5/22.
//

import UIKit
import CoreData
import Foundation

class MainViewController: UIViewController {
    
    let notifications = Notifications()
    let manager = LocationManager()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .black

        notifications.requestNotificationAuthorization()
        manager.requestLocationAuthorization()

    }
    
}

