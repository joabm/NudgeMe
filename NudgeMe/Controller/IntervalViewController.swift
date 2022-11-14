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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getLocationCoordinates()
        
    }
    
    func getLocationCoordinates() {
        
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyReduced
        
        var currentLoc: CLLocation!
        
        if(locationManager.authorizationStatus == .authorizedWhenInUse ||
           locationManager.authorizationStatus == .authorizedAlways) {
                 currentLoc = locationManager.location
                 debugPrint("current latitude: \(currentLoc.coordinate.latitude)")
                 debugPrint("currenct longitude: \(currentLoc.coordinate.longitude)")
              }
//        switch locationManager.authorizationStatus {
//        case .restricted, .denied:
//            hasPermission = false
//        default:
//            hasPermission = true
//        }
    }
}
