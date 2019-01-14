//
//  TripsTableViewController.swift
//  DriveTracker
//
//  Created by Charlie Mulholland on 7/26/18.
//  Copyright © 2018 Charlie Mulholland. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class TripsTableViewController: UIViewController, UITableViewDelegate {
    
    // MARK: - Variables
    var tripStore: TripStore!
    
    
    // MARK: - @IBOutlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var editButton: UIBarButtonItem!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = tripStore
        tableView.rowHeight = 60
        
        tripStore.fetchTrips()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tripStore.saveContext()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tripStore.fetchTrips()
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showTripDetail":
            let vc = segue.destination as! TripDetailViewController
            let selectedTrip = tripStore.allTrips[tableView.indexPathForSelectedRow!.row]
            vc.trip = selectedTrip
        default:
            print("\(#file): Unknown segue identifyer")
        }
    }
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            editButton.title = "Edit"
            editButton.style = .plain
            tableView.setEditing(false, animated: true)
        } else {
            editButton.title = "Done"
            editButton.style = .done
            tableView.setEditing(true, animated: true)
        }
    }
}
