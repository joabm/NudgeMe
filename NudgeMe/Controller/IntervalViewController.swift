//
//  IntervalViewController.swift
//  NudgeMe
//
//  Created by Joab Maldonado on 11/13/22.
//

import Foundation
import UIKit
import CoreLocation
import CoreData


class IntervalViewContoller: UIViewController {
    
    var randomReminders: [String] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: CoreData
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Category>!
    
    
    fileprivate func setupFetchResultsController() {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: "list")
                
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Data Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: Outlets
    
    @IBOutlet weak var daylightInfoText: UITextView!
    @IBOutlet weak var attributionText: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var rootStackView: UIStackView!
    
    
    
    // MARK: Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getLocationData()
        createRandomReminderArray()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //creating an attributed string for API attribution
        let attributionString = NSMutableAttributedString(string: "Powered by sunrise-sunset.org")
        let url = URL(string: "https://sunrise-sunset.org")!
        attributionString.setAttributes([.link: url], range: NSMakeRange(11, 18))
        attributionText.attributedText = attributionString
        
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isPortrait {
            rootStackView.axis = .vertical
        } else {
            rootStackView.axis = .horizontal
        }
    }
    
    // MARK: Daylight and Location API
    
    func getLocationData() {
        
        var currentLoc: CLLocation!
        var latitude: Double
        var longitude: Double
        let status: CLAuthorizationStatus
        
        //supporting iOS 14 and prior
        if #available(iOS 14, *) {
            status = appDelegate.locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        switch status {
        case .notDetermined, .restricted, .denied:
            daylightInfoText.textColor = UIColor.systemBlue
            daylightInfoText.text = "Approximate location not authorized"
            debugPrint("The user did not authorize location data")
            
        case .authorizedAlways, .authorizedWhenInUse:
            setActivityIndicator(true)
            currentLoc = appDelegate.locationManager.location
            guard currentLoc != nil else {
                daylightInfoText.textColor = UIColor.systemOrange
                daylightInfoText.text = "Location information not available"
                setActivityIndicator(false)
                return
            }
            latitude = currentLoc.coordinate.latitude
            longitude = currentLoc.coordinate.longitude
            debugPrint("current latitude: \(latitude)")
            debugPrint("currenct longitude: \(longitude)")
            getDaylightValues(latitude: latitude, longitude: longitude)
        @unknown default:
            debugPrint("Check for new cases for CLAuthorizationStatus")
        }
                
    }
    
    func getDaylightValues(latitude: Double, longitude: Double) {
        DaylightClient.getDaylightHours(latitude: latitude, longitude: longitude) { (data, error) in
            debugPrint("getDaylightHours call to API has been executed")
            if error == nil {
                self.setActivityIndicator(false)
                let sunrise: String = (data?.results.sunrise)!
                let sunset: String = (data?.results.sunset)!
                self.daylightInfoText.text = "Sunrise: \(sunrise)  Sunset: \(sunset)"
                debugPrint("sunrise: \(sunrise)")
                debugPrint("sunset: \(sunset)")
            }
            else {
                self.setActivityIndicator(false)
                self.showFailure(message: "\(error?.localizedDescription ?? "error")")
            }
        }
    }
    
    // MARK: set up random
    
    func createRandomReminderArray() {
        
        // make an array for each userdefault category
        // if a UserDefault value is empty then it's not added to the array
        
        let mindOne = UserDefaults.standard.string(forKey: "mindOne")
        let mindTwo = UserDefaults.standard.string(forKey: "mindTwo")
        let mindThree = UserDefaults.standard.string(forKey: "mindThree")
        var mindMessages:[String] = []
        
        if mindOne != "" {
            mindMessages.append(mindOne!)
        }
        if mindTwo != "" {
            mindMessages.append(mindTwo!)
        }
        if mindThree != "" {
            mindMessages.append(mindThree!)
        }
        debugPrint("mindMessages: \(mindMessages) + \(mindMessages.count)")
        
        let bodyOne = UserDefaults.standard.string(forKey: "bodyOne")
        let bodyTwo = UserDefaults.standard.string(forKey: "bodyTwo")
        let bodyThree = UserDefaults.standard.string(forKey: "bodyThree")
        var bodyMessages:[String] = []
        
        if bodyOne != "" {
            bodyMessages.append(bodyOne!)
        }
        if bodyTwo != "" {
            bodyMessages.append(bodyTwo!)
        }
        if bodyThree != "" {
            bodyMessages.append(bodyThree!)
        }
        debugPrint("bodyMessages: \(bodyMessages) + \(bodyMessages.count)")
        
        let soulOne = UserDefaults.standard.string(forKey: "soulOne")
        let soulTwo = UserDefaults.standard.string(forKey: "soulTwo")
        let soulThree = UserDefaults.standard.string(forKey: "soulThree")
        var soulMessages:[String] = []
        
        if soulOne != "" {
            soulMessages.append(soulOne!)
        }
        if soulTwo != "" {
            soulMessages.append(soulTwo!)
        }
        if soulThree != "" {
            soulMessages.append(soulThree!)
        }
        debugPrint("soulMessages: \(soulMessages) + \(soulMessages.count)")
        
        //create a reminder array with one random item from each category
        //if a category array is nil, it's not added to the the randomReminder array
        if mindMessages.count > 0 {
            randomReminders.append(mindMessages.randomElement()!)
        }
        if bodyMessages.count > 0 {
            randomReminders.append(bodyMessages.randomElement()!)
        }
        if soulMessages.count > 0 {
            randomReminders.append(soulMessages.randomElement()!)
        }
        if mindMessages.count == 0 && bodyMessages.count == 0 && soulMessages.count == 0 {
            let alertVC = UIAlertController(title: "Reminders are empty.", message: "All reminder messages are empty.  You will not recieve reminders.  Please add messages.", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertVC, animated: true, completion: nil)
        }
        debugPrint("randomReminders: \(randomReminders) + \(randomReminders.count)")
        
    }
    
    func getrandomTime() {
        //create times for reminders
    }
    
    // MARK: Activity Indicator and Failure Message
    
    func setActivityIndicator(_ isFinding: Bool) {
        if isFinding {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    func showFailure(message: String) {
        let alertVC = UIAlertController(title: "Daylight Data", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}
