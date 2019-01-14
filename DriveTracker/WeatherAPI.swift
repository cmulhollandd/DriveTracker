//
//  Weather.swift
//  DriveTracker
//
//  Created by Charlie Mulholland on 7/19/18.
//  Copyright © 2018 Charlie Mulholland. All rights reserved.
//

import Foundation


struct WeatherAPI {
    private static let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    private static let apiKey = "349649eb6f337fc40201f316456fc62b"
    private static let session: URLSession = {
        let sess = URLSession(configuration: .default)
        return sess
    }()
    
    static func getDownloadURL(xCoord: Double, yCoord: Double) -> URL {
        var components = URLComponents(string: baseURL)!
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "lat", value: "\(xCoord)"))
        queryItems.append(URLQueryItem(name: "lon", value: "\(yCoord)"))
        queryItems.append(URLQueryItem(name: "APPID", value: apiKey))
        components.queryItems = queryItems
        
        return components.url!
    }
    
    static func getWeather(using url: URL, completion: @escaping(Weather?) -> Void) {
        let request = URLRequest(url: url)
        let dataTask = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            guard error == nil else {
                print("Weather download failed")
                print("\(#file) error: \(error!)")
                completion(nil)
                return
            }
            guard data != nil else {
                print("\(#file) no data downloaded")
                completion(nil)
                return
            }
            let weather = processJSON(from: data!)
            OperationQueue.main.addOperation {
                completion(weather)
            }
        }
            
        dataTask.resume()
    }
    
    static func processJSON(from data: Data) -> Weather? {
        do {
            let jsonObj = try JSONSerialization.jsonObject(with: data, options: []) as! Dictionary<String, Any>
            let weather = Weather(json: jsonObj)
            return weather
        } catch {
            print(error)
            return nil
        }
    }
}
