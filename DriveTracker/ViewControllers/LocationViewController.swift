//
//  LocationViewController.swift
//  DriveTracker
//
//  Created by Charlie Mulholland on 1/11/19.
//  Copyright © 2019 Charlie Mulholland. All rights reserved.
//

import UIKit
import CoreLocation

class LocationViewController: UIViewController, CLLocationManagerDelegate {
    // MARK: - Variables
    let locationManager = CLLocationManager()
    
    // MARK: - @IBOutlets
    @IBOutlet var allowButton: UIButton!
    @IBOutlet var doneButton: UIButton!
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allowButton.layer.cornerRadius = allowButton.frame.height / 2
        doneButton.layer.cornerRadius = doneButton.frame.height / 2
    }
    
    // MARK: - @IBActions
    @IBAction func okPressed(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "welcomeHasShown")
        locationManager.requestAlwaysAuthorization()
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus != .authorizedWhenInUse && authStatus != .authorizedAlways {
            print("Location services restricted")
            print(authStatus.rawValue)
        }
    }
    
    @IBAction func donePressed(_ sender: UIButton) {
        // dismiss pager
        var candidate: UIViewController = self
        while true {
            if let pageViewController = candidate as? WelcomePageViewController {
                pageViewController.dismiss(animated: true, completion: nil)
                break
            }
            guard let next = parent else { break }
            candidate = next
        }
    }
    
}
