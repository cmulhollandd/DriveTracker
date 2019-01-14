//
//  AddTripViewController.swift
//  DriveTracker
//
//  Created by Charlie Mulholland on 8/3/18.
//  Copyright © 2018 Charlie Mulholland. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class AddTripViewController: UIViewController {
    // MARK: - Variables
    var startDate: Date?
    var endDate: Date?
    var skill: String?
    var tripStore: TripStore!
    let df: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yyyy hh:mm"
        return df
    }()
    
    // MARK: - @IBOutlets
    @IBOutlet var startTextField: UITextField!
    @IBOutlet var endTextField: UITextField!
    @IBOutlet var skillTextField: UITextField!
    @IBOutlet var topLabelConstraint: NSLayoutConstraint!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        let gestureRecog = UITapGestureRecognizer(target: self, action: #selector(tapRecognized))
        view.addGestureRecognizer(gestureRecog)
        
        let datePicker = UIDatePicker()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(tapRecognized))
        doneButton.tintColor = .white
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.barTintColor = UIColor(named: "idsYellow")!
        
        startTextField.inputAccessoryView = toolBar
        startTextField.inputView = datePicker
        
        endTextField.inputAccessoryView = toolBar
        endTextField.inputView = datePicker
    }
    
    @objc func tapRecognized() {
        self.view.endEditing(true)
        animateShiftDown()
    }
    
    // MARK: - @IBActions
    @IBAction func startTimeChanged(_ sender: UITextField) {
        let datePicker = sender.inputView as! UIDatePicker
        self.startDate = datePicker.date
        self.startTextField.text = df.string(from: self.startDate!)
    }
    @IBAction func endTimeChanged(_ sender: UITextField) {
        let datePicker = sender.inputView as! UIDatePicker
        self.endDate = datePicker.date
        self.endTextField.text = df.string(from: self.endDate!)
    }
    
    @IBAction func skillBegan(_ sender: UITextField) {
        print(self.view.frame.height)
        let height = self.view.frame.height
        if height < 600 {
            animateShiftUp()
        }
    }
    
    @IBAction func skillEnded(_ sender: UITextField) {
        animateShiftDown()
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        print(#function)
        if let start = startDate, let end = endDate {
            var primary = skillTextField.text!
            if primary == "" {
                primary = "Unknown"
            }
            let delegate = UIApplication.shared.delegate as! AppDelegate
            delegate.saveTrip(start: start, end: end, locations: [], weather: Weather(), speed: 0.0, skills: [primary])
            let ac = UIAlertController(title: "Added trip", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default, handler: {
                Void in
                
                self.dismiss(animated: true, completion: nil)
                self.navigationController!.popViewController(animated: true)
            })
            
            ac.addAction(ok)
            present(ac, animated: true, completion: nil)
        } else {
            print("No start or end time")
            self.navigationController!.popViewController(animated: true)
        }
    }
    
    // MARK: - Functions
    func animateShiftUp() {
        UIView.animate(withDuration: 0.2) {
            self.topLabelConstraint.constant = -50
            self.view.layoutIfNeeded()
        }
    }
    
    func animateShiftDown() {
        UIView.animate(withDuration: 0.2) {
            self.topLabelConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
}

