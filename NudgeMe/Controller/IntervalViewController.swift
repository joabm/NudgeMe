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
    
    var mindMessages:[String] = []
    var bodyMessages:[String] = []
    var soulMessages:[String] = []
    var randomReminders: [String] = []
    var randomHours: [Int] = []
    var randomMinutes: [Int] = []
    
    let manager = LocationManager()
    let notifications = Notifications ()
        
    // MARK: CoreData
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: Outlets
    
    @IBOutlet weak var daylightInfoText: UITextView!
    @IBOutlet weak var attributionText: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var rootStackView: UIStackView!
    @IBOutlet weak var reminderOne: UILabel!
    @IBOutlet weak var reminderTwo: UILabel!
    @IBOutlet weak var reminderThree: UILabel!
    @IBOutlet weak var datePickerStart: UIDatePicker!
    @IBOutlet weak var datePickerEnd: UIDatePicker!
    
    
    // MARK: Actions
    
    @IBAction func datePickerStart(_ sender: Any) {
        
    }
    
    @IBAction func datePickerEnd(_ sender: Any) {
        
    }
    
    @IBAction func toggleTodayButton(_ sender: Any) {
        randomReminders = []
        getRandomReminders()
        getRandomTimes()
        scheduleReminders()
    }
    
    // MARK: Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //getLocationData()
        getCategoryArrays()
        getRandomReminders()
        initialTimePicker()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.requestLocationAuthorization()
        initialAttributionString()
        getLocationData()
        
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
            status = manager.locationManager.authorizationStatus
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
            currentLoc = manager.locationManager.location
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
    
    // MARK: Initial values methods
    
    func initialAttributionString() {
        
        //creating an attributed string for API attribution
        let attributionString = NSMutableAttributedString(string: "Powered by sunrise-sunset.org")
        let url = URL(string: "https://sunrise-sunset.org")!
        attributionString.setAttributes([.link: url], range: NSMakeRange(11, 18))
        attributionText.attributedText = attributionString
    }
    
    func initialTimePicker(){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "HH:mm"

        let startTime = dateFormatter.date(from: UserDefaults.standard.string(forKey: "startTime")!)
        let endTime = dateFormatter.date(from: UserDefaults.standard.string(forKey: "endTime")!)

        datePickerStart.date = startTime!
        datePickerEnd.date = endTime!
    }
    

    // MARK: set up random
    
    func getCategoryArrays() {
        
        // make an array for each userdefault category
        // if a UserDefault value is empty then it's not added to the array
        
        let mindOne = UserDefaults.standard.string(forKey: "mindOne")
        let mindTwo = UserDefaults.standard.string(forKey: "mindTwo")
        let mindThree = UserDefaults.standard.string(forKey: "mindThree")
        
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
        
    }
    
    func getRandomReminders() {
        //create a reminder array with one random item from each category
        //if a category array is nil, it's not added to the the randomReminder array
        let randomMind = mindMessages.randomElement()!
        let randomBody = bodyMessages.randomElement()!
        let randomSoul = soulMessages.randomElement()!
        
        if mindMessages.count > 0 {
            randomReminders.append(randomMind)
            reminderOne.text = randomMind
        }
        if bodyMessages.count > 0 {
            randomReminders.append(randomBody)
            reminderTwo.text = randomBody
        }
        if soulMessages.count > 0 {
            randomReminders.append(randomSoul)
            reminderThree.text = randomSoul
        }
        if mindMessages.count == 0 && bodyMessages.count == 0 && soulMessages.count == 0 {
            let alertVC = UIAlertController(title: "Reminders are empty.", message: "All reminder messages are empty.  You will not recieve reminders.  Please add messages.", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertVC, animated: true, completion: nil)
        }
        debugPrint("randomReminders: \(randomReminders) + \(randomReminders.count)")
        
    }
    
    func getRandomTimes() {
        //create times for reminders
        let startTime = 9
        let endTime = 18
        if startTime == endTime || endTime < startTime || startTime > endTime {
            //error invalid
        } else if endTime - startTime == 1 {
            var t = 0
            while (t < randomReminders.count) {
                randomHours.append(startTime)
                var mins = Int.random(in: 0 ..< 60)
                randomMinutes.append(mins)
                t += 1
            }
        } else {
            var i = 0
            while (i < randomReminders.count) {
                // get random number between start and end Time & append random hours
                var hrs = Int.random(in: startTime..<endTime)
                randomHours.append(hrs)
                
                var mins = Int.random(in: 0 ..< 60)
                randomMinutes.append(mins)
                i += 1
            }
        }
        //        randomHours = [22, 22, 22]
        //        randomMinutes = [10, 11, 12]
    }
    
    func scheduleReminders(){
        var i = 0
        while (i < randomReminders.count) {
            var body = randomReminders[i]
            var hour = randomHours[i]
            var minute = randomMinutes[i]
            notifications.sendNotification(body: body, hour: hour, minute: minute)
            //capture for coredata history
            //            message.text = body
            //            message.creationDate = Date()
            i += 1
        }
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



