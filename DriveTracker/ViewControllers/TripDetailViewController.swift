//
//  TripDetailViewController.swift
//  DriveTracker
//
//  Created by Charlie Mulholland on 7/26/18.
//  Copyright © 2018 Charlie Mulholland. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit
import CoreData

class TripDetailViewController: UIViewController {
    // MARK: - Variables
    var trip: Trip!
    let df: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yyyy: hh:mm"
        return df
    }()
    let nf: NumberFormatter = {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 1
        nf.minimumFractionDigits = 0
        nf.numberStyle = .decimal
        return nf
    }()
    
    // MARK: - @IBOutlets
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var weatherLabel: UILabel!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var skillLabel: UILabel!
    @IBOutlet var averageSpeedLabel: UILabel!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var distanceLabel: UILabel!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        mapView.layer.cornerRadius = mapView.frame.height / 20
        self.navigationItem.largeTitleDisplayMode = .never
        formatInfo()
        if let locations = trip!.locations {
            print(locations.count)
        }
    }
    
    // MARK: - @IBActions
    @IBAction func editPressed(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "Change Skill", message: "Enter new skill below", preferredStyle: .alert)
        ac.addTextField(configurationHandler: nil)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let done = UIAlertAction(title: "Done", style: .default) {
            (action) -> Void in
            
            let text = ac.textFields!.first!.text!
            self.skillLabel.text = text
            // Save changes
            let delegate = UIApplication.shared.delegate as! AppDelegate
            delegate.deleteTrip(with: self.trip!.startTime! as Date)
            delegate.saveTrip(start: self.trip!.startTime! as Date, end: self.trip!.endTime! as Date, locations: self.trip!.locations ?? [], weather: self.trip!.weather!, speed: self.trip!.averageSpeed, skills: [text])
        }
        ac.addAction(cancel)
        ac.addAction(done)
        present(ac, animated: true, completion: nil)
    }
    
    
    
    // MARK: - Functions    
    func formatInfo() {
        let trip = self.trip!
        var distance = 0.0
        if let locations = trip.locations, !locations.isEmpty {
            var lastLocation: CLLocation?
            for loc in locations {
                if lastLocation != nil {
                    distance += loc.distance(from: lastLocation!)
                }
                lastLocation = loc
            }
            self.distanceLabel.text = nf.string(from: NSNumber(value: distance * 0.000621371))! + " mi"
        } else {
            self.distanceLabel.text = "N/A mi"
        }
        
        self.navigationItem.title = df.string(from: trip.startTime! as Date)
        formatTime()
        self.weatherLabel.text = trip.weather?.conditions ?? "N/A"
        self.tempLabel.text = "\(trip.weather?.temp ?? 0.0) ℉"
        self.skillLabel.text = formatSkills(for: trip.practicedSkills ?? ["None"])
        self.averageSpeedLabel.text = nf.string(from: NSNumber(value: trip.averageSpeed))! + " mph"
        
        
        setupMap()
    }
    
    func formatSkills(for skills: [String]) -> String {
        var final = ""
        if skills.count > 1 {
            for skill in skills {
                final += "\(skill), "
            }
        } else {
            for skill in skills {
                final += "\(skill)"
            }
        }
        return final
    }
    
    func formatTime() {
        let counter = DateInterval(start: trip!.startTime! as Date, end: trip!.endTime! as Date).duration
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
    
    func setupMap() {
        guard let locations = trip!.locations, !locations.isEmpty else {
            let label = UILabel()
            label.text = "No location recorded"
            label.textAlignment = .center
            label.frame = mapView.layer.bounds
            mapView.layer.addSublayer(label.layer)
            return
        }
        var regionSize = 0.0
        let first = locations.first!
        let last = locations.last!
        
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
        let yDiff = mostY.distance(from: leastY) * 1.25
        if xDiff > yDiff {
            regionSize = xDiff
        } else {
            regionSize = yDiff
        }
        
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

extension TripDetailViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .red
        renderer.lineWidth = 2.0
        
        return renderer
    }
}
