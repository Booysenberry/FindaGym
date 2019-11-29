//
//  PlaceModel.swift
//  FindaGym
//
//  Created by Brad Booysen on 19/07/19.
//  Copyright © 2019 Brad Booysen. All rights reserved.
//

import Foundation
import MapKit

class Place: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var isCurrentLocation: Bool
    var name: String?
    var phoneNumber: String?
    var placemark: MKPlacemark
    var timeZone: TimeZone?
    var url: URL?
    var distance: Double?
    
    init(isCurrentLocation: Bool, placemark: MKPlacemark, coordinate: CLLocationCoordinate2D) {
        
        self.isCurrentLocation = isCurrentLocation
        self.placemark = placemark
        self.coordinate = coordinate
        
    }
    
    var title: String? {
        return name
    }
    
    //Show distance on annotation view
    var subtitle: String? {
        guard let distanceMeasure = distance else { return "Unknown" }
        return "\(String(distance: distanceMeasure)) away"
    }
}
