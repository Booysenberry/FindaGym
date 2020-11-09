//
//  DetailMapView.swift
//  FindaGym
//
//  Created by Brad Booysen on 24/07/19.
//  Copyright © 2019 Brad Booysen. All rights reserved.
//

import UIKit
import MapKit

class DetailMapView: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var mapRegion = MKCoordinateRegion()
    
    @IBOutlet weak var mapView: MKMapView!
    
    var currentPlace: Place?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMapRegion()
        
        let place = currentPlace
        
        navigationItem.title = place?.name
        
        // show place on map
        if let location = place?.placemark {
            let placeAnnotation = MKPointAnnotation()
            placeAnnotation.coordinate = location.coordinate
            placeAnnotation.title = place?.name
            mapView.addAnnotation(placeAnnotation)
        }
    }
    
    func setMapRegion() {
        if let placeLocation = currentPlace?.placemark.coordinate {
            let viewRegion = MKCoordinateRegion(center: placeLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(viewRegion, animated: true)
            mapRegion = viewRegion
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "embeddedSegue") {
            
            if let vc = segue.destination as? DetailTableView {
                if let selectedPlace = currentPlace {
                    vc.currentPlace = selectedPlace
                }
            }
        }
    }
}


