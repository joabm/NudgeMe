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
    var identifiers: [String] = ["mind", "body", "soul"]
    
    let manager = LocationManager ()
    let notifications = Notifications ()
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter
    }()

        
    // MARK: CoreData
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var message: Message!
//    var fetchedResultsController:NSFetchedResultsController<Message>!
//
//    fileprivate func setupFetchedResultsController() {
//        let fetchRequest:NSFetchRequest<Message> = Message.fetchRequest()
//        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
//
//        do {
//            try fetchedResultsController.performFetch()
//        } catch {
//            fatalError("The fetch could not be performed: \(error.localizedDescription)")
//        }
//    }
    
    
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
        let pickerStart = dateFormatter.string(from: datePickerStart.date)
        UserDefaults.standard.set(pickerStart, forKey: "startTime")
    }
    
    @IBAction func datePickerEnd(_ sender: Any) {
        let pickerEnd = dateFormatter.string(from: datePickerEnd.date)
        UserDefaults.standard.set(pickerEnd, forKey: "endTime")
    }
    
    @IBAction func toggleTodayButton(_ sender: Any) {
        notifications.center.removeAllPendingNotificationRequests()
        getRandomReminders()
    }
    
    @IBAction func sendNotificationsButton(_ sender: Any) {
        setAndSendReminders()
    }
    
    // MARK: Lifecycle
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        //getLocationData()
//        getRandomReminders()
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        initialAttributionString()
        
        //set saved TimePicker Value
        datePickerStart.date = dateFormatter.date(from: UserDefaults.standard.string(forKey: "startTime")!)!
        datePickerEnd.date = dateFormatter.date(from: UserDefaults.standard.string(forKey: "endTime")!)!
        
        getLocationData()
        getCategoryArrays()
        getRandomReminders()
        //setupFetchedResultsController()
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
                self.showAlert(title: "Daylight Data", message: "\(error?.localizedDescription ?? "error")")
            }
        }
    }
    
    // MARK: String for API Attribution
    
    func initialAttributionString() {
        
        //creating an attributed string for API attribution
        let attributionString = NSMutableAttributedString(string: "Powered by sunrise-sunset.org")
        let url = URL(string: "https://sunrise-sunset.org")!
        attributionString.setAttributes([.link: url], range: NSMakeRange(11, 18))
        attributionText.attributedText = attributionString
    }
    

    // MARK: set up random arrays
    
    func getCategoryArrays() {
        
        // make an array for each userdefault category
        // if a UserDefault value is empty then it's not added to the array
        
        let mindOne = UserDefaults.standard.string(forKey: "mindOne")
        let mindTwo = UserDefaults.standard.string(forKey: "mindTwo")
        let mindThree = UserDefaults.standard.string(forKey: "mindThree")
        
        if mindOne != "" {
            mindMessages.append(mindOne ?? "")
        }
        if mindTwo != "" {
            mindMessages.append(mindTwo ?? "")
        }
        if mindThree != "" {
            mindMessages.append(mindThree ?? "")
        }
//        debugPrint("mindMessages: \(mindMessages) + \(mindMessages.count)")

        let bodyOne = UserDefaults.standard.string(forKey: "bodyOne")
        let bodyTwo = UserDefaults.standard.string(forKey: "bodyTwo")
        let bodyThree = UserDefaults.standard.string(forKey: "bodyThree")
        
        if bodyOne != "" {
            bodyMessages.append(bodyOne ?? "")
        }
        if bodyTwo != "" {
            bodyMessages.append(bodyTwo ?? "")
        }
        if bodyThree != "" {
            bodyMessages.append(bodyThree ?? "")
        }
//        debugPrint("bodyMessages: \(bodyMessages) + \(bodyMessages.count)")
        
        let soulOne = UserDefaults.standard.string(forKey: "soulOne")
        let soulTwo = UserDefaults.standard.string(forKey: "soulTwo")
        let soulThree = UserDefaults.standard.string(forKey: "soulThree")
        
        if soulOne != "" {
            soulMessages.append(soulOne ?? "")
        }
        if soulTwo != "" {
            soulMessages.append(soulTwo ?? "")
        }
        if soulThree != "" {
            soulMessages.append(soulThree ?? "")
        }
//        debugPrint("soulMessages: \(soulMessages) + \(soulMessages.count)")
        
    }
    
    func getRandomReminders() {
        randomReminders = []
        //create a reminder array with one random item from each category
        //if a category array is nil, it's not added to the the randomReminder array
        
        if mindMessages.count == 0 && bodyMessages.count == 0 && soulMessages.count == 0 {
            showAlert(title: "Reminders are empty.", message: "All reminder categories are empty.  You will not recieve reminders.  Please add a message to at least one category: MIND, BODY, SOUL.")
        }
        
        let randomMind = mindMessages.randomElement()
        let randomBody = bodyMessages.randomElement()
        let randomSoul = soulMessages.randomElement()
        
        if mindMessages.count > 0 {
            randomReminders.append(randomMind ?? "")
            reminderOne.text = randomMind
        }
        if bodyMessages.count > 0 {
            randomReminders.append(randomBody ?? "")
            reminderTwo.text = randomBody
        }
        if soulMessages.count > 0 {
            randomReminders.append(randomSoul ?? "")
            reminderThree.text = randomSoul
        }
        
//        debugPrint("randomReminders: \(randomReminders) + \(randomReminders.count)")
        
    }
    
    // MARK: Calculate Random Time and Schedule Reminders
    
    func setAndSendReminders() {
        randomHours = []
        randomMinutes = []

        //convert stored default time string to integer array
        let startValue = UserDefaults.standard.string(forKey: "startTime")
        let endValue = UserDefaults.standard.string(forKey: "endTime")

        let start = startValue?.components(separatedBy: ":")
        let end = endValue?.components(separatedBy: ":")

        //create time components as integer for reminders
        let startHour = Int(start?[0] ?? "") ?? 9
        let startMin = Int(start?[1] ?? "") ?? 0
        let endHour = Int(end?[0] ?? "") ?? 6
        let endMin = Int(end?[1] ?? "") ?? 0
        
        // check for valid interval input
        let intervalCheck = endHour - startHour

        guard intervalCheck > 1 else {
            showAlert(title: "Adjust the Time Interval", message: "Please check the time interval. The time interval must fall in the same day and should be at least two hours long.")
            return
        }

        // create a randomhours and randomminutes values for each random reminder.  append to array
        var i = 0
        while (i < randomReminders.count) {
            
            // get random number between start and end Time & append random hours array
            
            if startMin == 0 && endMin == 0 { //if both start and end minutes are 0
                let hrs = Int.random(in: startHour..<endHour )
                randomHours.append(hrs)
                
                let mins = Int.random(in: 10 ..< 60)
                randomMinutes.append(mins)
                
            } else if startMin == 30 && endMin == 0 { //if start minutes is 30 and end is 0
                let hrs = Int.random(in: startHour..<endHour)
                randomHours.append(hrs)
                
                if hrs == startHour { //when the randomly selected hour is the startHour
                    let mins = Int.random(in: 30 ..< 60) //restrict minutes selection for startHour
                    randomMinutes.append(mins)
                } else { // all other hr selections
                    let mins = Int.random(in: 10 ..< 60 )
                    randomMinutes.append(mins)
                }
                
            } else if startMin == 0 && endMin == 30 { //if start minutes is 0 and end is 30
                let hrs = Int.random(in: startHour...endHour) //include the endHour in hr selection
                randomHours.append(hrs)
                
                if hrs == endHour { //when the randomly selected hour is the endHour
                    let mins = Int.random(in: 10 ..< 30)//restrict the minute selection for endHour
                    randomMinutes.append(mins)
                } else {// all othe hr selections
                    let mins = Int.random(in: 10 ..< 60)
                    randomMinutes.append(mins)
                }
            } else { //both start and end minutes are 30
                let hrs = Int.random(in: startHour...endHour) //include the endHour in hr selection
                randomHours.append(hrs)
                
                if hrs == startHour {//when the randomly selected hour is starthour
                    let mins = Int.random(in: 30 ..< 60) //restrict the minute selection
                    randomMinutes.append(mins)
                } else if hrs == endHour {//when the randomly selected hour is endHour
                    let mins = Int.random(in: 10 ..< 30) // restrict the minute selection
                    randomMinutes.append(mins)
                } else { //all other hour selections
                    let mins = Int.random(in: 10 ..< 60)
                    randomMinutes.append(mins)
                }
            }
            
            i += 1
        }
        
        scheduleNotifications()
    }
    
    
    func scheduleNotifications(){
        var i = 0
        while (i < randomReminders.count) {
            debugPrint("random hours count: \(randomHours.count)")
            let body = randomReminders[i]
            let hour = randomHours[i]
            let minute = randomMinutes[i]
            let identifier = identifiers[i]
            notifications.scheduleNotification(body: body, hour: hour, minute: minute, id: identifier)
            
            //capture reminder history for coredata
            let message = Message(context: context)
            message.text = body
            message.creationDate = Date()
            try? context.save()
            
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
    
    func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}



