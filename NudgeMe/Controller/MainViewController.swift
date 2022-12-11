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
    let intervals = IntervalViewContoller()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        notifications.requestNotificationAuthorization()
        manager.requestLocationAuthorization()
//        repeat24HrsTimer()

    }
    
    func repeat24HrsTimer() {
        let date = Date(timeIntervalSinceReferenceDate: 60)
        let timer = Timer(fireAt: date, interval: 7200, target: self, selector: #selector(startTimer), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
    }

    @objc func startTimer(){
        notifications.center.removeAllPendingNotificationRequests()
        intervals.getCategoryArrays()
        intervals.getRandomReminders()
        intervals.scheduleReminders()
    }

}

