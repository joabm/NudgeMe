//
//  AppDelegate.swift
//  NudgeMe
//
//  Created by Joab Maldonado on 11/5/22.
//

import UIKit
import CoreData
import UserNotifications
import CoreLocation


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //let dataController = DataController(modelName: "NudgeMe")
    
    
    //instantiate UNUserNotificationCenter and CLLocationManager frameworks API
    let notifications = Notifications()
    let manager = LocationManager()
    
    //sets mapView if the app have never launched before
    func checkIfFirstLaunch(){
        if(UserDefaults.standard.bool(forKey: "hasLaunchedBefore")){
            print("NudgeMe has launched before")
        } else {
            print("This is the first launch ever!")
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            UserDefaults.standard.set("Today I create...", forKey: "mindOne")
            UserDefaults.standard.set("Three things I am grateful for", forKey: "mindTwo")
            UserDefaults.standard.set("Expectations invite disappointment. Expectancy invites hope.", forKey: "mindThree")
            UserDefaults.standard.set("Stand up and stretch", forKey: "bodyOne")
            UserDefaults.standard.set("Do the Hokey Pokey", forKey: "bodyTwo")
            UserDefaults.standard.set("Gather Qi", forKey: "bodyThree")
            UserDefaults.standard.set("Abandon the phone for a walk", forKey: "soulOne")
            UserDefaults.standard.set("Whatever the situation, I help", forKey: "soulTwo")
            UserDefaults.standard.set("Smile at each doorway", forKey: "soulThree")
            UserDefaults.standard.set("09:00", forKey: "startTime")
            UserDefaults.standard.set("18:00", forKey: "endTime")
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        checkIfFirstLaunch()
        
        //framework API delegates
        notifications.center.delegate = notifications
        manager.locationManager.delegate = manager

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "NudgeMe")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

