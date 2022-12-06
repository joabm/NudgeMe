//
//  MainViewController.swift
//  NudgeMe
//
//  Created by Joab Maldonado on 11/5/22.
//

import UIKit
import CoreData

class MainViewController: UIViewController {
    
    let notifications = Notifications()
    let manager = LocationManager()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        notifications.requestNotificationAuthorization()
        manager.requestLocationAuthorization()

    }

}

