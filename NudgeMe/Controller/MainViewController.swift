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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notifications.requestNotificationAuthorization()
    }

}

