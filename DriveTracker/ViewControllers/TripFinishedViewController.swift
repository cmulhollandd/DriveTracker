//
//  TripFinishedConfirmScreen.swift
//  DriveTracker
//
//  Created by Charlie Mulholland on 7/22/18.
//  Copyright © 2018 Charlie Mulholland. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class TripFinishedViewController: UIViewController {
    // MARK: - Variables
    var start: Date!
    var end: Date!
    var locations: [CLLocation]!
    var avgSpeed: CLLocationSpeed!
    var weather: Weather!
    var distance: CLLocationDistance!
    let nf: NumberFormatter = {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 1
        nf.minimumFractionDigits = 0
        nf.numberStyle = .decimal
        return nf
    }()

    // MARK: - @IBOutlets
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var speedLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var skillField: UITextField!
    @IBOutlet var weatherLabel: UILabel!
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var topBlurConstraint: NSLayoutConstraint!
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapRecognized))
        self.view.addGestureRecognizer(tapRecognizer)
        
        formatTime()
        
        speedLabel.text    = nf.string(from: NSNumber(value: avgSpeed))! + " mph"
        distanceLabel.text = nf.string(from: NSNumber(value: distance * 0.000621371))! + " mi"
        
        saveButton.layer.cornerRadius   = saveButton.frame.height / 7
        deleteButton.layer.cornerRadius = deleteButton.frame.height / 7
        
        blurView.layer.shadowColor   = UIColor.black.cgColor
        blurView.layer.shadowRadius  = 5.0
        blurView.layer.shadowOpacity = 0.9
        
        tempLabel.text    = "\(weather.temp) ℉"
        weatherLabel.text = "\(weather.conditions)"
        
        setupMap()
    }
    
    // MARK: - @IBActions
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var skills = [String]()
        let skill = skillField.text!
        skills += suggestSkills()
        if skill != "" {
            skills.append(skill)
        }
        
        appDelegate.saveTrip(start: start, end: end, locations: locations, weather: weather, speed: avgSpeed, skills: skills)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func panRecognized(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            let translation = sender.translation(in: self.view).y
            if translation > 0 { // swipe up
                self.topBlurConstraint.constant += translation
                self.view.layoutIfNeeded()
            } else { // swipe down
                self.topBlurConstraint.constant += translation
                self.view.layoutIfNeeded()
            }
            sender.setTranslation(CGPoint.zero, in: blurView)
        } else if sender.state == .ended {
            if self.topBlurConstraint.constant > 205 {
                self.animateViewChange(goingDown: true)
            } else {
                self.animateViewChange(goingDown: false)
            }
        }
    }
    
    @objc func tapRecognized() {
        self.view.endEditing(true)
    }
    
    // MARK: - Functions
    func updateWeather() {
        let temp = weather.temp
        let conditions = weather.conditions
        tempLabel.text = "\(temp) ℉"
        weatherLabel.text = "\(conditions)"
    }
    
    
    
    func formatTime() {
        let counter = DateInterval(start: start, end: end).duration
        var tmp = counter
        let hours = (tmp / 3600).rounded(.down)
        tmp -= hours * 3600
        let minutes = (tmp / 60).rounded(.down)
        tmp -= minutes * 60
        let seconds = tmp.rounded(.down)
        
        var finalH = ""
        var finalM = ""
        var finalS = ""
        if hours < 10 {
            finalH = "0\(nf.string(from: NSNumber(value: hours))!)"
        } else {
            finalH = "\(nf.string(from: NSNumber(value: hours))!)"
        }
        if minutes < 10 {
            finalM = "0\(nf.string(from: NSNumber(value: minutes))!)"
        } else {
            finalM = "\(nf.string(from: NSNumber(value: minutes))!)"
        }
        if seconds < 10 {
            finalS = "0\(nf.string(from: NSNumber(value: seconds))!)"
        } else {
            finalS = "\(nf.string(from: NSNumber(value: seconds))!)"
        }
        let str = "\(finalH):\(finalM):\(finalS)"
        self.timeLabel.text = str
    }
    
    func animateViewChange(goingDown: Bool) {
        if goingDown {
            UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
                self.topBlurConstraint.constant = 455
                self.view.layoutIfNeeded()
            })
        } else {
            UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
                self.topBlurConstraint.constant = 45
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func suggestSkills() -> [String] {
        var skills = [String]()
        if !weather.daylight {
            skills.append("Night Driving")
        }
        let code = nf.number(from: weather.code) as! Int
        if code > 200 && code < 300 {
            skills.append("Thunderstorms")
        } else if (code > 300 && code < 400) || (code > 500 && code < 600) {
            skills.append("Rain")
        } else if code > 600 && code < 700 && code != 781 {
            skills.append("Snow")
        } else if code > 700 && code < 800 {
            skills.append("Foggy")
        } else if code == 800 || (code > 949 && code < 957) {
            // Do nothing, normal weather
        } else if code >= 957 {
            skills.append("Severe Winds")
        } else if code == 900 || code == 781 {
            skills.append("Tornado")
        } else if code == 901 {
            skills.append("Severe Storms")
        } else if code == 902 {
            skills.append("Hurricane")
        }
        let time = DateInterval(start: start, end: end).duration
        
        if distance * 0.000621371 > 50 {
            skills.append("Long Distance")
        } else if time > 5400 {
            skills.append("Long Distance")
        }
        
        return skills
    }
    
    func setupMap() {
        let locations = self.locations!
        var regionSize = 0.0
        guard let first = locations.first, let last = locations.last else {
            print("\(#function) No locations")
            return
        }
        var mostX = locations[0]
        var mostY = locations[0]
        var leastX = locations[0]
        var leastY = locations[0]
        var coords = [CLLocationCoordinate2D]()
        for loc in locations {
            coords.append(loc.coordinate)
            if loc.coordinate.latitude > mostX.coordinate.latitude {
                mostX = loc
            }
            if loc.coordinate.longitude > mostY.coordinate.longitude {
                mostY = loc
            }
            if loc.coordinate.latitude < leastX.coordinate.latitude {
                leastX = loc
            }
            if loc.coordinate.longitude < leastY.coordinate.longitude {
                leastY = loc
            }
        }
        let xDiff = mostX.distance(from: leastX) * 1.25
        let yDiff = mostY.distance(from: leastY) + 1.25
        if xDiff > yDiff {
            regionSize = xDiff
        } else {
            regionSize = yDiff
        }
        
        regionSize += 20
        
        let centerX = (mostX.coordinate.latitude + leastX.coordinate.latitude) / 2
        let centerY = (mostY.coordinate.longitude + leastY.coordinate.longitude) / 2
        let centerCoord = CLLocationCoordinate2D(latitude: centerX, longitude: centerY)
        
        let region = MKCoordinateRegion(center: centerCoord, latitudinalMeters: regionSize, longitudinalMeters: regionSize)
        mapView.setRegion(region, animated: true)
        
        let polyLine = MKPolyline(coordinates: coords, count: coords.count)
        mapView.addOverlay(polyLine)
        
        let startPin = MKPointAnnotation()
        startPin.coordinate = first.coordinate
        startPin.title = "Start"
        let endPin = MKPointAnnotation()
        endPin.coordinate = last.coordinate
        endPin.title = "Stop"
        
        mapView.addAnnotation(startPin)
        mapView.addAnnotation(endPin)
    }
}

extension TripFinishedViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 2.0
        renderer.strokeColor = .red
        return renderer
    }
}
