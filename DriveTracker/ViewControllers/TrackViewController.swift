//
//  TrackViewController.swift
//  DriveTracker
//
//  Created by Charlie Mulholland on 7/18/18.
//  Copyright © 2018 Charlie Mulholland. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import MapKit

class TrackViewController: UIViewController {
    // MARK: - Variables
    var tripStore: TripStore!
    var locationAlwaysAllowed = false
    var locationServicesEnabled = true
    var locationManager: CLLocationManager!
    var currentSpeed: CLLocationSpeed!
    var distanceTravelled: CLLocationDistance = 0.0
    var startTime: Date!
    var currentWeather: Weather?
    var isTracking: Bool = false
    var allLocations: [CLLocation] = []
    var lastLocation: CLLocation? = nil
    var timer = Timer()
    var counter = 0
    let nf: NumberFormatter = {
        let nf = NumberFormatter()
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 1
        nf.numberStyle = .decimal
        return nf
    }()
    var overlays = [MKPolyline]()

    // MARK: - @IBOutlets
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var startStopButton: UIButton!
    @IBOutlet var speedLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var mapViewTopContraint: NSLayoutConstraint!
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        // Perform some final UI tweaks
        startStopButton.layer.cornerRadius = startStopButton.frame.height / 6
        
        blurView.layer.shadowRadius  = 3.0
        blurView.layer.shadowOpacity = 0.5
        blurView.layer.shadowColor   = UIColor.black.cgColor
        
        let height = self.blurView.frame.height - self.tabBarController!.tabBar.frame.height
        self.mapViewTopContraint.constant = -1 * height
        
        let button = MKUserTrackingButton(mapView: mapView)
        button.layer.backgroundColor = UIColor(white: 1, alpha: 0.8).cgColor
        button.layer.borderColor = UIColor.clear.cgColor
        button.tintColor = UIColor(named: "idsYellow")!
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -3)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !UserDefaults.standard.bool(forKey: "welcomeHasShown") {
            self.performSegue(withIdentifier: "showWelcome", sender: nil)
        }
        
        if UserDefaults.standard.bool(forKey: "welcomeHasShown") {
            setupLocationServices()
            
            locationManager.stopUpdatingLocation()
            if let location = locationManager.location {
                getWeather(at: location)
            } else {
                print("couldn't get location")
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            resetUI()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showTripCompletion":
            let vc       = segue.destination as! TripFinishedViewController
            vc.start     = startTime
            vc.end       = Date()
            vc.locations = self.allLocations
            vc.avgSpeed  = finishTrip()
            vc.weather   = currentWeather ?? Weather()
            vc.distance  = self.distanceTravelled
            resetUI()
        case "showWelcome":
            print("Showing welcome screen")
        default:
            print("\(#file) unknown segue identifier (\(segue.identifier ?? "no identifier"))")
        }
    }
    
    // MARK: - @IBActions
    @IBAction func startStopPressed(_ sender: UIButton) {
        if !isTracking {
            if locationServicesEnabled {
                animateTabBar(visible: false)
                isTracking = true
                self.startTime = Date()
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
                locationManager.startUpdatingLocation()
                if let location = locationManager.location {
                    getWeather(at: location)
                }
                mapView.setUserTrackingMode(.follow, animated: true)
                sender.backgroundColor = .red
                sender.setTitle("Stop", for: .normal)
                if CLLocationManager.authorizationStatus() != .authorizedAlways {
                     UIApplication.shared.isIdleTimerDisabled = true
                }
            } else {
                let ac = UIAlertController(title: "Location Services restricted", message: "this feature will be unavailable until location services are enabled", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                ac.addAction(ok)
                present(ac, animated: true, completion: nil)
            }
        } else {
            animateTabBar(visible: true)
            isTracking = false
            locationManager.stopUpdatingLocation()
            sender.backgroundColor = .green
            sender.setTitle("Start", for: .normal)
            UIApplication.shared.isIdleTimerDisabled = false
            timer.invalidate()
            if allLocations.count < 5 {
                print("not enough locations")
                resetUI()
                return
            }
            self.performSegue(withIdentifier: "showTripCompletion", sender: nil)
        }
    }
    
    // MARK: - Functions
    func setupLocationServices() {
        self.locationManager = CLLocationManager()
        let authStat = CLLocationManager.authorizationStatus()
        if authStat != .authorizedAlways && authStat != .authorizedWhenInUse {
            locationServicesEnabled = false
            print(authStat.rawValue)
            print("\(#file): Location not authorized")
            // notify user of location services error
            let ac = UIAlertController(title: "Location not authorized", message: "Features will be limited until location services are enabled", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            ac.addAction(okAction)
            self.present(ac, animated: true, completion: nil)
            return
        }
        if authStat == .authorizedAlways {
            locationAlwaysAllowed = true
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
        }
        if !CLLocationManager.locationServicesEnabled() {
            print("\(#file): Location not available")
            return
        }
        locationServicesEnabled = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }
    
    func getWeather(at location: CLLocation) {
        let coords = location.coordinate
        
        let xCoord = coords.latitude
        let yCoord = coords.longitude
        let url = WeatherAPI.getDownloadURL(xCoord: xCoord, yCoord: yCoord)
        WeatherAPI.getWeather(using: url) {
            (weather) -> Void in
            
            guard weather != nil else {
                print("\(#file) weather == nil")
                return
            }
            
            self.currentWeather = weather
            self.updateWeather()
        }
    }
    
    func updateWeather() {
        guard currentWeather != nil else {
            print("No weather available")
            return
        }
    }
    
    func updateDistance() {
        let dist = distanceTravelled * 0.000621371
        let distString = nf.string(from: NSNumber(value: dist))!
        self.distanceLabel.text = "\(distString) mi"
    }
    
    func finishTrip() -> Double {
        let duration = Double(exactly: counter)! / 3600.0
        let miles = distanceTravelled * 0.000621371
        
        return miles / duration
    }
    
    @objc func updateTimer() {
        counter += 1
        var tmp = counter
        let hours = (tmp / 3600)
        tmp -= hours * 3600
        let minutes = (tmp / 60)
        tmp -= minutes * 60
        let seconds = tmp
        
        var finalH = ""
        var finalM = ""
        var finalS = ""
        if hours < 10 {
            finalH = "0\(hours)"
        } else {
            finalH = "\(hours)"
        }
        if minutes < 10 {
            finalM = "0\(minutes)"
        } else {
            finalM = "\(minutes)"
        }
        if seconds < 10 {
            finalS = "0\(seconds)"
        } else {
            finalS = "\(seconds)"
        }
        let str = "\(finalH):\(finalM):\(finalS)"
        self.timeLabel.text = str
    }
    
    func animateTabBar(visible: Bool) {
        let frame = self.tabBarController?.tabBar.frame
        let height = frame?.size.height
        let offsetY = (visible ? -height! : height)
        UIView.animate(withDuration: 0.2, animations: {
            self.tabBarController?.tabBar.frame = frame!.offsetBy(dx: 0, dy: offsetY!)
        })
    }
    
    func resetUI() {
        mapView.removeOverlays(overlays)
        startStopButton.backgroundColor = .green
        startStopButton.setTitle("Start", for: .normal)
        self.timeLabel.text = "00:00:00"
        self.speedLabel.text = "0.0 MPH"
        self.distanceLabel.text = "0.0 mi"
        self.distanceTravelled = 0.0
        timer.invalidate()
        self.currentWeather = nil
        self.allLocations.removeAll()
        self.counter = 0
        self.isTracking = false
    }
}

extension TrackViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(#function)
        if isTracking {
            let currentLocation = locations.last!
            allLocations.append(currentLocation)
            if let last = lastLocation {
                let distance = currentLocation.distance(from: last)
                distanceTravelled += distance
                let coords = [last.coordinate, currentLocation.coordinate]
                let polyLine = MKPolyline(coordinates: coords, count: coords.count)
                mapView.addOverlay(polyLine)
                self.overlays.append(polyLine)
                self.lastLocation = currentLocation
            } else {
                self.lastLocation = currentLocation
            }
            if currentLocation.speed > 0 {
                self.speedLabel.text = nf.string(from: NSNumber(value: currentLocation.speed * 2.23694))! + " MPH"
            } else {
                self.speedLabel.text = "0.0 MPH"
            }
        }
        self.distanceLabel.text = nf.string(from: NSNumber(value: distanceTravelled * 0.000621371))! + " mi"
        if UIApplication.shared.applicationState != .active {
            print("App is backgrounded, but the location has updated")
        }
    }
}

extension TrackViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer         = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .red
        renderer.lineWidth   = 3.0
        return renderer
    }
}
