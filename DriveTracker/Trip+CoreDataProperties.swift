//
//  Trip+CoreDataProperties.swift
//  DriveTracker
//
//  Created by Charlie Mulholland on 12/10/18.
//  Copyright © 2018 Charlie Mulholland. All rights reserved.
//
//

import Foundation
import CoreData
import CoreLocation

extension Trip {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Trip> {
        return NSFetchRequest<Trip>(entityName: "Trip")
    }

    @NSManaged public var averageSpeed: Double
    @NSManaged public var endTime: NSDate?
    @NSManaged public var locations: [CLLocation]?
    @NSManaged public var practicedSkills: [String]?
    @NSManaged public var startTime: NSDate?
    @NSManaged public var weather: Weather?

}
