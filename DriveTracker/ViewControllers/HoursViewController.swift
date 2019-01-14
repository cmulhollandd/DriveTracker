//
//  HoursViewController.swift
//  DriveTracker
//
//  Created by Charlie Mulholland on 1/11/19.
//  Copyright © 2019 Charlie Mulholland. All rights reserved.
//

import UIKit

class HoursViewController: UIViewController {
    // MARK: - @IBOutlets
    @IBOutlet var totalHoursField: UITextField!
    @IBOutlet var nightHoursField: UITextField!
    @IBOutlet var weatherHoursField: UITextField!
    @IBOutlet var doneButton: UIButton!
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.layer.cornerRadius = doneButton.frame.height / 2
    }
    
    @IBAction func donePressed(_ sender: UIButton) {
        let total = totalHoursField.text ?? "0"
        let night = nightHoursField.text ?? "0"
        let weather = weatherHoursField.text ?? "0"
        
        UserDefaults.standard.set(Double(total), forKey: "overall_time_required")
        UserDefaults.standard.set(Double(night), forKey: "night_time_required")
        UserDefaults.standard.set(Double(weather), forKey: "weather_time_required")
        
        // advance pager
        var candidate: UIViewController = self
        while true {
            if let pageViewController = candidate as? WelcomePageViewController {
                pageViewController.show(index: 2)
                break
            }
            guard let next = parent else { break }
            candidate = next
        }
    }
}
