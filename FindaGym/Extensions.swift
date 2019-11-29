//
//  Extensions.swift
//  FindaGym
//
//  Created by Brad Booysen on 22/07/19.
//  Copyright © 2019 Brad Booysen. All rights reserved.
//

import Foundation
import MapKit


// Custom colour for UI
extension UIColor {
    class func getCustomRedColor() -> UIColor{
        return UIColor(red: 84.0/255.0, green: 165.0/255.0, blue: 240.0/255.0, alpha: 1.0) //#EE5253
    }
}

// Format distance
extension String {
    init(distance: Double ) {
        let mkDistanceFormatter = MKDistanceFormatter()
        mkDistanceFormatter.unitStyle = .abbreviated
        self = mkDistanceFormatter.string(fromDistance: distance)
    }
}


