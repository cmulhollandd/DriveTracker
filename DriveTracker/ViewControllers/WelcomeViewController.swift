//
//  WelcomeViewController.swift
//  DriveTracker
//
//  Created by Charlie Mulholland on 1/11/19.
//  Copyright © 2019 Charlie Mulholland. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    // MARK: - @IBOutlets
    @IBOutlet var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.layer.cornerRadius = doneButton.frame.height / 2
    }
    
    @IBAction func donePressed(_ sender: UIButton) {
        // advance page controller
        var candidate: UIViewController = self
        while true {
            if let pageViewController = candidate as? WelcomePageViewController {
                pageViewController.show(index: 1)
                break
            }
            guard let next = parent else { break }
            candidate = next
        }
    }
}
