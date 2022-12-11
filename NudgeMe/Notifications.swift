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
            if let error = error {
                debugPrint("Error \(error.localizedDescription)")
                }
        }
    }

    func scheduleNotification(body: String, hour: Int, minute: Int, id: String) {
                
        let content = UNMutableNotificationContent()
        let userActions = "User Actions"
        
        content.title = "NudgeMe"
        content.body = body
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = userActions
        
        var date = DateComponents()
        date.hour = hour
        date.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                
        center.add(request) { (error) in
            if let error = error {
                debugPrint("Error \(error.localizedDescription)")
            }
        }
        debugPrint("A notification has been scheduled for \(hour):\(minute)")
        debugPrint(body)
        
        let deleteAction = UNNotificationAction(identifier: "Delete", title: "Delete", options: [.destructive])
        let category = UNNotificationCategory(identifier: userActions, actions: [deleteAction], intentIdentifiers: [], options: [])

        center.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        //If a response action is deired, it can be added here
        if response.notification.request.identifier == "Local Notification" {
            print("Handling notifications with the Local Notification Identifier")
        }

        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            print("Default")
        case "Delete":
            debugPrint("Notification Deleted")
        default:
            print("Unknown action")
        }
        
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner, .sound])
    }
}
