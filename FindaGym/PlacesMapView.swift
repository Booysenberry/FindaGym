//
//  PlacesMapView.swift
//  FindaGym
//
//  Created by Brad Booysen on 16/07/19.
//  Copyright © 2019 Brad Booysen. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class PlacesMapView: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var keyword = "gym"
    let locationManager = CLLocationManager()
    var mapRegion = MKCoordinateRegion()
    var nearbyPlaces = [Place]()
    var fetchedData = [MKMapItem]()
    var embedVC: PlaceListTable?
    
    override func viewDidLoad() {
        
        navigationItem.title = "FindaGym"
        mapView.delegate = self
        setMapRegion()
        initLocationManager()
    }
    
    @IBAction func centreMapOnUserButtonTapped(_ sender: Any) {
        self.mapView.setUserTrackingMode( MKUserTrackingMode.follow, animated: true)
    }
    
    @IBAction func refreshDataButtonTapped(_ sender: Any) {
        handleRefresh()
    }
    
    // Refresh data / pull to refresh
    func handleRefresh() {
        initLocationManager()
    }
    
    // MARK: - Location data
    func initLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManagerDidChangeAuthorization(locationManager)
    }
    
    // Delegate method to check authorization status and request "When In Use" authorization
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            let status = manager.authorizationStatus
            if (status == .denied || status == .restricted || !CLLocationManager.locationServicesEnabled()) {
                
                let alert = UIAlertController(title: "Need Authorization", message: "We cannot find nearby places if you don't authorize the app to use your location", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
                    let url = URL(string: UIApplication.openSettingsURLString)!
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }))
                self.present(alert, animated: true, completion: nil)
                
                print("User denied location access")
                
                return
                
            }
            if status == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
                return
            }
            
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        }
    
    func setMapRegion() {
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 5000, longitudinalMeters: 5000)
            mapView.setRegion(viewRegion, animated: false)
            mapRegion = viewRegion
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        setMapRegion()
        searchNearbyPlaces()
        
    }
    
    // MARK: - Search request
    func searchNearbyPlaces() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = keyword
        request.region = mapRegion
        
        let search = MKLocalSearch(request: request)
        
        search.start(completionHandler: {(response, error) in
            
            if error != nil {
                print("Error occurred in search: \(error!.localizedDescription)")
            } else if response!.mapItems.count == 0 {
                print("No matches found")
            } else {
                print("Matches found")
                
                if let results = response?.mapItems {
                    self.fetchedData = results
                    self.sortPlaces()
                }
            }
        })
    }
    
    // MARK: - Sort fetched data for presentation in tableview
    func sortPlaces() {
        nearbyPlaces.removeAll()
        self.embedVC?.nearbyPlaces.removeAll()
        
        for item in fetchedData {
            
            let place = Place(isCurrentLocation: item.isCurrentLocation, placemark: item.placemark, coordinate: item.placemark.coordinate)
            
            // Calculate distance from current location
            let source = MKMapItem.forCurrentLocation()
            let destination = item
            
            let directionRequest = MKDirections.Request()
            directionRequest.source = source
            directionRequest.destination = destination
            
            let directions = MKDirections(request: directionRequest)
            
            directions.calculate { (response, error) -> Void in
                if error != nil {
                    print("Error occurred in search: \(error!.localizedDescription)")
                } else {
                    
                    let distance = response!.routes.first?.distance // meters
                    
                    place.distance = distance
                    place.name = item.name
                    place.phoneNumber = item.phoneNumber
                    place.timeZone = item.timeZone
                    place.url = item.url
                    
                }
                self.nearbyPlaces.append(place)
                
                // Pass data to embedded tableviewcontroller
                self.embedVC?.nearbyPlaces.append(place)
                self.embedVC?.tableView.reloadData()
                
                self.mapView.addAnnotations(self.nearbyPlaces)
            }
            
        }
    }
    
    // MARK: - Perform segue when user taps an annotation
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let place = view.annotation as! Place
        performSegue(withIdentifier: "moveToDetailView", sender: place)
        
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
        
        // Pass data to embedded tableviewcontroller
        if (segue.identifier == "embeddedListingSegue") {
            
            let listView = segue.destination as! PlaceListTable
            self.embedVC = listView
            
        }
    }
}

// MARK: - Show annotations on map
extension PlacesMapView: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? Place else { return nil }
        
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
}
