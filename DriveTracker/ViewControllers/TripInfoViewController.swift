//
//  TripInfoViewController.swift
//  DriveTracker
//
//  Created by Charlie Mulholland on 8/7/18.
//  Copyright © 2018 Charlie Mulholland. All rights reserved.
//

import UIKit
import Foundation

class TripInfoViewController: UIViewController {
    // MARK: - Variables
    var tripStore: TripStore!
    var nightTime: Double = 0.0
    var overallTime: Double = 0.0
    var badWeatherTime: Double = 0.0
    let overallCircleLayer = CAShapeLayer()
    let nightCircleLayer = CAShapeLayer()
    let weatherCircleLayer = CAShapeLayer()
    let lineWidth: CGFloat = 6.0
    var overallPercent = 0.0
    var weatherPercent = 0.0
    var nightPercent = 0.0
    var totalRequired: Double = 0
    var totalNight: Double = 0
    var totalWeather: Double = 0

    let nf: NumberFormatter = {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 1
        nf.minimumFractionDigits = 0
        nf.numberStyle = .decimal
        return nf
    }()
    
    let dfDate: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yyyy"
        return df
    }()
    
    let dfTime: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "hh:mm a"
        return df
    }()
    
    
    // MARK: - @IBOutlets
    @IBOutlet var timeView: UIView!
    @IBOutlet var nightTimeView: UIView!
    @IBOutlet var weatherTimeView: UIView!
    @IBOutlet var overallTimeLabel: UILabel!
    @IBOutlet var nightTimeLabel: UILabel!
    @IBOutlet var weatherTimeLabel: UILabel!
    @IBOutlet var exportButton: UIButton!
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.totalRequired = UserDefaults.standard.double(forKey: "overall_time_required")
        self.totalNight = UserDefaults.standard.double(forKey: "night_time_required")
        self.totalWeather = UserDefaults.standard.double(forKey: "weather_time_required")
        
        exportButton.layer.borderColor = UIColor(named: "idsYellow")!.cgColor
        exportButton.layer.borderWidth = 1.0
        exportButton.layer.cornerRadius = exportButton.frame.height / 5
 
        setupTaps()
        getStats()
        setupLabels()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getStats()
        setupCircles()
        setupLabels()
    }
    
    // MARK: - @IBActions
    @IBAction func exportButtonPressed(_ sender: UIButton) {
        let csvString = formatCSV()
        let fileName = "Trips.csv"
        let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: path, atomically: true, encoding: .utf8)
            let activityController = UIActivityViewController(activityItems: [path], applicationActivities: [])
            activityController.excludedActivityTypes = [
                .assignToContact,
                .saveToCameraRoll,
                .postToFlickr,
                .postToVimeo,
                .postToWeibo,
                .postToTwitter,
                .postToFacebook,
                .openInIBooks,
                .assignToContact,
                .addToReadingList
            ]
            activityController.view.tintColor = UIColor(named: "idsYellow")!
            present(activityController, animated: true, completion: nil)
        } catch {
            print("Failed to create csv file \(#function)")
            print("\(error)")
            let ac = UIAlertController(title: "Can't export Trips", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            let tryAgain = UIAlertAction(title: "Try Again", style: .default) {
                (action) -> Void in
                self.exportButtonPressed(self.exportButton)
            }
            ac.addAction(ok)
            ac.addAction(tryAgain)
            present(ac, animated: true, completion: nil)
        }
    }
    
    @objc func overallTapped() {
        let ac = UIAlertController(title: "Edit Time Requirement", message: "Enter new time below", preferredStyle: .alert)
        ac.addTextField(configurationHandler: {
            (textField) -> Void in
            textField.keyboardType = .numberPad
            textField.placeholder = "\(UserDefaults.standard.double(forKey: "overall_time_required"))"
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let done = UIAlertAction(title: "Done", style: .default) {
            (action) -> Void in
            
            let text = ac.textFields!.first!
            let value = text.text!
            let hours = Double(value) ?? 0
            self.totalRequired = hours
            print(self.totalRequired)
            UserDefaults.standard.set(hours, forKey: "overall_time_required")
            self.setupCircles()
        }
        ac.addAction(cancel)
        ac.addAction(done)
        present(ac, animated: true, completion: nil)
    }
    
    @objc func nightTapped() {
        let ac = UIAlertController(title: "Edit Time Requirement", message: "Enter new time below", preferredStyle: .alert)
        ac.addTextField(configurationHandler: {
            (textField) -> Void in
            textField.keyboardType = .numberPad
            textField.placeholder = "\(UserDefaults.standard.double(forKey: "night_time_required"))"
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let done = UIAlertAction(title: "Done", style: .default) {
            (action) -> Void in
            
            let text = ac.textFields!.first!
            let value = text.text!
            let hours = Double(value) ?? 0
            self.totalNight = hours
            print(self.totalNight)
            UserDefaults.standard.set(hours, forKey: "night_time_required")
            self.setupCircles()
        }
        ac.addAction(cancel)
        ac.addAction(done)
        present(ac, animated: true, completion: nil)
    }
    
    @objc func weatherTapped() {
        let ac = UIAlertController(title: "Edit Time Requirement", message: "Enter new time below", preferredStyle: .alert)
        ac.addTextField(configurationHandler: {
            (textField) -> Void in
            textField.keyboardType = .numberPad
            textField.placeholder = "\(UserDefaults.standard.double(forKey: "weather_time_required"))"
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let done = UIAlertAction(title: "Done", style: .default) {
            (action) -> Void in
            
            let text = ac.textFields!.first!
            let value = text.text!
            let hours = Double(value) ?? 0
            self.totalWeather = hours
            print(self.totalWeather)
            UserDefaults.standard.set(hours, forKey: "weather_time_required")
            self.setupCircles()
        }
        ac.addAction(cancel)
        ac.addAction(done)
        present(ac, animated: true, completion: nil)
    }
    
    // MARK: - Functions
    func setupTaps() {
        let tapOverall = UITapGestureRecognizer(target: self, action: #selector(overallTapped))
        let tapNight = UITapGestureRecognizer(target: self, action: #selector(nightTapped))
        let tapWeather = UITapGestureRecognizer(target: self, action: #selector(weatherTapped))
        
        self.timeView.addGestureRecognizer(tapOverall)
        self.nightTimeView.addGestureRecognizer(tapNight)
        self.weatherTimeView.addGestureRecognizer(tapWeather)
    }
    
    func setupCircles() {
        setupTimeView()
        setupNightView()
        setupWeatherView()
        
        self.overallPercent = overallTime / (self.totalRequired * 3600)
        self.nightPercent = nightTime / (self.totalNight * 3600)
        self.weatherPercent = badWeatherTime / (self.totalNight * 3600)
        
        animateOverallCircle(to: overallPercent)
        animateNightCircle(to: nightPercent)
        animateWeatherCircle(to: weatherPercent)
        
        checkColors()
    }
    
    func formatCSV() -> String {
        var csv = "Date,Start Time,Practice Skills,End Time,Total Hours\n"
        var totalHours = 0.0
        for trip in tripStore.allTrips.reversed() {
            let date = dfDate.string(from: trip.startTime! as Date)
            let startTime = dfTime.string(from: trip.startTime! as Date)
            var skill = formatSkills(for: trip.practicedSkills ?? ["None"])
            skill = skill.replacingOccurrences(of: ", ", with: "|")
            skill = skill.replacingOccurrences(of: ",", with: "|")
            print(skill)
            let endTime = dfTime.string(from: trip.endTime! as Date)
            let counter = DateInterval(start: trip.startTime! as Date, end: trip.endTime! as Date).duration
            totalHours += counter
            let currentTotal = formatTimeMinutes(from: totalHours)
            
            csv += "\(date),\(startTime),\(skill),\(endTime),\(currentTotal)\n"
        }
        
        return csv
    }
    
    func formatSkills(for skills: [String]) -> String {
        var final = ""
        if skills.count > 1 {
            for skill in skills {
                final += "\(skill); "
            }
        } else {
            for skill in skills {
                final += "\(skill)"
            }
        }
        return final
    }
    
    func formatTimeSeconds(from counter: Double) -> String {
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
        return str
    }
    
    func formatTimeMinutes(from counter: Double) -> String {
        var tmp = counter
        let hours = (tmp / 3600).rounded(.down)
        tmp -= hours * 3600
        let minutes = (tmp / 60).rounded(.down)
        tmp -= minutes * 60
        
        var finalH = ""
        var finalM = ""
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
        let str = "\(finalH):\(finalM)"
        return str
    }
    
    func getStats() {
        if tripStore.allTrips.count == 0 {
            tripStore.fetchTrips()
        }
        
        var overall = 0.0
        var night = 0.0
        var weather = 0.0
        
        for trip in tripStore.allTrips {
            let amount = DateInterval(start: trip.startTime! as Date, end: trip.endTime! as Date).duration
            overall += amount
            
            
            if !trip.weather!.daylight {
                night += amount
            } else {
                for skill in trip.practicedSkills ?? ["None"] {
                    if skill.uppercased().contains("NIGHT") {
                        night += amount
                    }
                }
            }
            
            let code = nf.number(from: trip.weather!.code) as! Int
            if code != 800 {
                weather += amount
            }
        }
        
        self.overallTime = overall
        self.nightTime = night
        self.badWeatherTime = weather
        
    }
}


// MARK: - UI Functions
extension TripInfoViewController {
    
    // Functions for drawing and animating circles
    func setupTimeView() {
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 125.0, y: 125.0), radius: 115, startAngle: -CGFloat.pi / 2, endAngle: 1.5 * CGFloat.pi, clockwise: true)
        
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.path = circlePath.cgPath
        backgroundLayer.lineWidth = lineWidth + 2
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = UIColor.lightGray.cgColor
        timeView.layer.addSublayer(backgroundLayer)
        
        overallCircleLayer.path = circlePath.cgPath
        overallCircleLayer.lineWidth = lineWidth
        overallCircleLayer.fillColor = UIColor.clear.cgColor
        overallCircleLayer.strokeColor = UIColor(named: "idsYellow")!.cgColor
        overallCircleLayer.lineCap = .round
        overallCircleLayer.strokeEnd = 0.0
        timeView.layer.addSublayer(overallCircleLayer)
    }
    
    func setupWeatherView() {
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 75.0, y: 75.0), radius: 65, startAngle: -CGFloat.pi / 2, endAngle: 1.5 * CGFloat.pi, clockwise: true)
        
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.path = circlePath.cgPath
        backgroundLayer.lineWidth = lineWidth + 2
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = UIColor.lightGray.cgColor
        weatherTimeView.layer.addSublayer(backgroundLayer)
        
        weatherCircleLayer.path = circlePath.cgPath
        weatherCircleLayer.lineWidth = lineWidth
        weatherCircleLayer.fillColor = UIColor.clear.cgColor
        weatherCircleLayer.strokeColor = UIColor(named: "idsYellow")!.cgColor
        weatherCircleLayer.lineCap = .round
        weatherCircleLayer.strokeEnd = 0.0
        weatherTimeView.layer.addSublayer(weatherCircleLayer)
    }
    
    func setupNightView() {
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 75.0, y: 75.0), radius: 60, startAngle: -CGFloat.pi / 2, endAngle: 1.5 * CGFloat.pi, clockwise: true)
        
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.path = circlePath.cgPath
        backgroundLayer.lineWidth = lineWidth + 2
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = UIColor.lightGray.cgColor
        nightTimeView.layer.addSublayer(backgroundLayer)
        
        nightCircleLayer.path = circlePath.cgPath
        nightCircleLayer.lineWidth = lineWidth
        nightCircleLayer.fillColor = UIColor.clear.cgColor
        nightCircleLayer.strokeColor = UIColor(named: "idsYellow")!.cgColor
        nightCircleLayer.lineCap = .round
        nightCircleLayer.strokeEnd = 0.0
        nightTimeView.layer.addSublayer(nightCircleLayer)
    }
    
    func animateOverallCircle(to percent: Double) {
        overallCircleLayer.strokeEnd = 0
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.toValue = percent
        animation.duration = 1.0
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        overallCircleLayer.add(animation, forKey: nil)
    }
    
    func animateNightCircle(to percent: Double) {
        nightCircleLayer.strokeEnd = 0
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.toValue = percent
        animation.duration = 1.0
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        nightCircleLayer.add(animation, forKey: nil)
    }
    
    func animateWeatherCircle(to percent: Double) {
        weatherCircleLayer.strokeEnd = 0
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.toValue = percent
        animation.duration = 1.0
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        weatherCircleLayer.add(animation, forKey: nil)
    }
    
    func setupLabels() {
        let overall = formatTimeMinutes(from: overallTime)
        let night = formatTimeMinutes(from: nightTime)
        let weather = formatTimeMinutes(from: badWeatherTime)
        
        overallTimeLabel.text = overall
        nightTimeLabel.text = night
        weatherTimeLabel.text = weather
    }
    
    func checkColors() {
        print(self.overallPercent)
        print(self.nightPercent)
        print(self.weatherPercent)
        if self.overallPercent >= 1 {
            self.overallCircleLayer.strokeColor = UIColor.green.cgColor
            print("Overall is now green")
        } else {
            self.overallCircleLayer.strokeColor = UIColor(named: "idsYellow")!.cgColor
            print("Overall is now yellow")
        }
        
        if self.nightPercent >= 1 {
            self.nightCircleLayer.strokeColor = UIColor.green.cgColor
            print("night is now green")
        } else {
            self.nightCircleLayer.strokeColor = UIColor(named: "idsYellow")!.cgColor
            print("night is now yellow")
        }
        
        if self.weatherPercent >= 1 {
            self.weatherCircleLayer.strokeColor = UIColor.green.cgColor
            print("weather is now green")
        } else {
            self.weatherCircleLayer.strokeColor = UIColor(named: "idsYellow")!.cgColor
            print("weather is now yellow")
        }
    }
}
