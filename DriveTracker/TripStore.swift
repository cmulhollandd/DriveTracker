//
//  TripStore.swift
//  DriveTracker
//
//  Created by Charlie Mulholland on 7/26/18.
//  Copyright © 2018 Charlie Mulholland. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation

class TripStore: NSObject {
    var allTrips: [Trip] = [Trip]()
    
    let df: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yyyy"
        return df
    }()
    
    let nf: NumberFormatter = {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 1
        nf.minimumFractionDigits = 0
        nf.numberStyle = .decimal
        return nf
    }()
    
    let persistantContainer: NSPersistentContainer = {
        let pc = NSPersistentContainer(name: "DriveTracker")
        pc.loadPersistentStores(completionHandler: { (description, error) in
            guard error == nil else {
                print("Something bad happened at \(#file): \(#function)")
                
                return
            }
        })
        return pc
    }()
    
    func saveContext() {
        let context = persistantContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print(error)
                print(#file)
            }
            print("Saved successfully")
        }
    }
    
    func addTrip(start: Date, end: Date, weather: Weather, locations: [CLLocation], avgSpeed: CLLocationSpeed, skills: [String]) {
        let trip = Trip(context: persistantContainer.viewContext)
        trip.startTime = start as NSDate
        trip.endTime = end as NSDate
        trip.weather = weather
        trip.locations = locations
        trip.averageSpeed = avgSpeed
        trip.practicedSkills = skills
        
        allTrips.append(trip)
        
        saveContext()
    }
    
    func fetchTrips() {
        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Trip.startTime), ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        persistantContainer.viewContext.performAndWait {
            do {
                let trips = try fetchRequest.execute()
                self.allTrips = trips
            } catch {
                print(error)
            }
        }
    }
    
    func deleteTrip(at index: Int) {
        let context = persistantContainer.viewContext
        let trip = allTrips[index]
        context.delete(trip)
        allTrips.remove(at: index)
    }
    
    func getIndex(date: Date)  -> Int {
        for trip in self.allTrips {
            if trip.startTime! as Date == date {
                return Int(allTrips.firstIndex(of: trip)!)
            }
        }
        return -1
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
    
    func makeDurationString(from start: Date, to end: Date) -> String {
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
        return "\(finalH):\(finalM):\(finalS)"
        
    }
}

extension TripStore: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTrips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let trip = allTrips[row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripTableViewCell", for: indexPath) as! TripTableViewCell
        cell.skillLabel.text = formatSkills(for: trip.practicedSkills ?? [""])
        cell.dateLabel.text = df.string(from: trip.startTime! as Date)
        let durationString = makeDurationString(from: trip.startTime! as Date, to: trip.endTime! as Date)
        cell.timeLabel.text = durationString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            deleteTrip(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        default:
            print("Unknown editing style: \(#file)")
        }
    }
}
