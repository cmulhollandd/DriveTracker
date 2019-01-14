//
//  Weather.swift
//  DriveTracker
//
//  Created by Charlie Mulholland on 7/19/18.
//  Copyright © 2018 Charlie Mulholland. All rights reserved.
//

import Foundation
import UIKit


@objc public class Weather: NSObject, NSCoding {
    
    let time: Date
    let temp: Double
    let code: String
    let conditions: String
    let daylight: Bool
    
    init(time: Date, temp: Double, conditions: String, code: String, daylight: Bool) {
        self.time = time
        self.temp = temp
        self.conditions = conditions
        self.code = code
        self.daylight = daylight
    }
    
    convenience init(json data: Dictionary<String, Any>) {
        let weatherArr = data["weather"] as! [Any]
        let weatherDict = weatherArr[0] as! Dictionary<String, Any>
        let conditions = weatherDict["main"] as! String
        let codeInt = weatherDict["id"] as! Int
        let code = String(codeInt)
        let iconCode = weatherDict["icon"] as! String
        var daylight = false
        if iconCode.contains("d") {
            daylight = true
        }
        let tempDict = data["main"] as! Dictionary<String, Any>
        var temp = tempDict["temp"] as! Double
        let timeCode = data["dt"] as! Double
        temp = 1.8 * (temp - 273) + 32
        
        let nf: NumberFormatter = {
            let nf = NumberFormatter()
            nf.numberStyle = .decimal
            nf.minimumFractionDigits = 0
            nf.maximumFractionDigits = 1
            return nf
        }()
        
        let tempStr = nf.string(from: NSNumber(value: temp))!
        print(tempStr)
        print(conditions)
        temp = nf.number(from: tempStr) as! Double
        let time = Date(timeIntervalSince1970: timeCode)
        
        self.init(time: time, temp: temp, conditions: conditions, code: code, daylight: daylight)
    }
    
    override convenience init() {
        self.init(time: Date(), temp: 0.0, conditions: "", code: "800", daylight: true)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(time, forKey: "time")
        aCoder.encode(temp, forKey: "temp")
        aCoder.encode(conditions, forKey: "conditions")
        aCoder.encode(code, forKey: "code")
        aCoder.encode(daylight, forKey: "daylight")
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        let time = aDecoder.decodeObject(forKey: "time") as! Date
        let temp = aDecoder.decodeDouble(forKey: "temp")
        let conditions = aDecoder.decodeObject(forKey: "conditions") as! String
        let code = aDecoder.decodeObject(forKey: "code") as! String
        let daylight = aDecoder.decodeBool(forKey: "daylight")
        
        self.init(time: time, temp: temp, conditions: conditions, code: code, daylight: daylight)
    }
}
