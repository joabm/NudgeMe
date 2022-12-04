//
//  Notifications.swift
//  NudgeMe
//
//  Created by Joab Maldonado on 12/3/22.
//

import Foundation
import UserNotifications

class Notifications: NSObject, UNUserNotificationCenterDelegate {
    
    let center = UNUserNotificationCenter.current()
    //center.removeAllPendingNotificationRequests()
    
    func requestNotificationAuthorization() {
        
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("User accepted Notifications")
            } else {
                print("User declined Nofitications")
            }
        }
    }

    func sendNotification() {
        
        let content = UNMutableNotificationContent()
        
        content.title = "NudgeMe"
        content.body = "Test body"
        
//        var dateComponents = DateComponents()
//        dateComponents.hour
//        dateComponents.minute
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                
        center.add(UNNotificationRequest(identifier: "Local Notification", content: content, trigger: trigger))
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner, .sound])
    }
}
