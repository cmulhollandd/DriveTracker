//
//  AppDelegate.swift
//  DriveTracker
//
//  Created by Charlie Mulholland on 7/18/18.
//  Copyright © 2018 Charlie Mulholland. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import Foundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let tripStore = TripStore()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let rootVC = self.window?.rootViewController as! UITabBarController
        let naviController = rootVC.viewControllers![1] as! UINavigationController
        let tableView = naviController.viewControllers[0] as! TripsTableViewController
        let infoView = rootVC.viewControllers![2] as! TripInfoViewController
        infoView.tripStore = self.tripStore
        tableView.tripStore = self.tripStore
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        tripStore.saveContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        tripStore.saveContext()
    }

    func saveTrip(start: Date, end: Date, locations: [CLLocation], weather: Weather, speed: CLLocationSpeed, skills: [String]) {
        print("saving trip from \(#file)")
        
        tripStore.addTrip(start: start, end: end, weather: weather, locations: locations, avgSpeed: speed, skills: skills)
        tripStore.saveContext()
    }
    
    func deleteTrip(with start: Date) {
        let index = tripStore.getIndex(date: start)
        guard index != -1 else {
            print("could not find trip")
            return
        }
        tripStore.deleteTrip(at: index)
    }
}

