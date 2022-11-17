//
//  IntervalViewController.swift
//  NudgeMe
//
//  Created by Joab Maldonado on 11/13/22.
//

import Foundation
import UIKit
import CoreLocation

class IntervalViewContoller: UIViewController {
    
    @IBOutlet weak var daylightInfoText: UITextView!
    @IBOutlet weak var attributionText: UITextView!
            
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getLocationCoordinates()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //creating an attributed string for API attribution
        let attributionString = NSMutableAttributedString(string: "Powered by sunrise-sunset.org")
        let url = URL(string: "https://sunrise-sunset.org")!
        attributionString.setAttributes([.link: url], range: NSMakeRange(11, 18))
        attributionText.attributedText = attributionString
//        getLocationCoordinates()
        
    }
    
    // MARK: Daylight and Location API
    
    func getLocationCoordinates() {
        
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyReduced
        
        var currentLoc: CLLocation!
        var latitude: Double
        var longitude: Double
        let status: CLAuthorizationStatus
        
        //supporting iOS 14 and prior
        if #available(iOS 14, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        switch status {
        case .notDetermined, .restricted, .denied:
            let unauthorizedString = NSMutableAttributedString(string: "Approximate location data is not yet authorized")
            daylightInfoText.attributedText = unauthorizedString
            debugPrint("User did not authorize location data")
            
        case .authorizedAlways, .authorizedWhenInUse:
            currentLoc = locationManager.location
            latitude = currentLoc.coordinate.latitude
            longitude = currentLoc.coordinate.longitude
            debugPrint("current latitude: \(latitude)")
            debugPrint("currenct longitude: \(longitude)")
            getDaylightValues(latitude: latitude, longitude: longitude)
        @unknown default:
            fatalError()
        }
                
    }
    
    func getDaylightValues(latitude: Double, longitude: Double) {
        DaylightClient.getDaylightHours(latitude: latitude, longitude: longitude) { (data, error) in
            debugPrint("getDaylightHours call to API has been executed")
            if error == nil {
                let sunrise: String = (data?.results.sunrise)!
                let sunset: String = (data?.results.sunset)!
                self.daylightInfoText.text = "Sunrise: \(sunrise)  Sunset: \(sunset)"
                debugPrint("sunrise: \(sunrise)")
                debugPrint("sunset: \(sunset)")
            }
            else {
                self.showFailure(message: "\(error?.localizedDescription ?? "error")")
            }
        }
    }
    
    // MARK: Activity Indicator and Failure Messate
    
    func showFailure(message: String) {
        let alertVC = UIAlertController(title: "Daylight Data", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}
