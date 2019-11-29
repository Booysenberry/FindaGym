//
//  PlaceListTable.swift
//  FindaGym
//
//  Created by Brad Booysen on 16/07/19.
//  Copyright © 2019 Brad Booysen. All rights reserved.
//

import UIKit

class PlaceListTable: UITableViewController {
    
    var nearbyPlaces = [Place]()
    
    override func viewDidLoad() {
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Nearby Gyms"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Handle empty table
        if nearbyPlaces.count == 0 {
            
            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
            emptyLabel.text = "No gyms found 😕"
            emptyLabel.textAlignment = NSTextAlignment.center
            self.tableView.backgroundView = emptyLabel
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
            return 0
            
        } else {
            
        tableView.backgroundView = nil
        return nearbyPlaces.count
            
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceViewCell", for: indexPath)
        
        let selectedPlace = nearbyPlaces.sorted(by: { Int($0.distance!) < Int($1.distance!) })[indexPath.row]
        
        cell.textLabel?.text = selectedPlace.name
        
        if let distance = selectedPlace.distance {
            cell.detailTextLabel?.text = "\(String(distance: distance)) away" // String extension
        }
        return cell
    }
    
    // MARK: - Perform segue when user taps a cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlace = nearbyPlaces.sorted(by: { Int($0.distance!) < Int($1.distance!) })[indexPath.row] // Sorted by distance
        self.parent?.performSegue(withIdentifier: "moveToDetailView", sender: selectedPlace)
        
    }
    
    // Pass data to next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "moveToDetailView") {
            if let placeMapVC = segue.destination as? DetailMapView {
                if let selectedPlace = sender as? Place {
                    placeMapVC.currentPlace = selectedPlace
                }
            }
        }
    }
}

