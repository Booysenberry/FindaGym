//
//  DetailTableView..swift
//  FindaGym
//
//  Created by Brad Booysen on 24/07/19.
//  Copyright © 2019 Brad Booysen. All rights reserved.
//

import UIKit
import MapKit
import SafariServices

class DetailTableView: UITableViewController {
    
    var currentPlace: Place?
    
    @IBOutlet weak var placeAddress: UILabel!
    @IBOutlet weak var placePhoneNumber: UILabel!
    @IBOutlet weak var placeURL: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let place = currentPlace
        
        if place?.phoneNumber != nil {
            if let phoneNumber = place?.phoneNumber {
                placePhoneNumber.text = phoneNumber
            }
        } else {
            placePhoneNumber.text = "We can't find a phone number 😕"
        }
        
        if place?.url != nil {
            if let url = place?.url {
                placeURL.text = url.absoluteString
                
            }
        } else {
            placeURL.text = "We can't find a website 😕"
        }
        
        if let street = place?.placemark.thoroughfare {
            if let number = place?.placemark.subThoroughfare {
                if let suburb = place?.placemark.locality {
                    
                    placeAddress.text = "\(number) \(street), \(suburb)"
                    
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
            
        case 0: // Open maps with directions to place
            if let coordinates = currentPlace?.placemark.coordinate {
                
                if let name = currentPlace?.name {
                    let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: (coordinates), addressDictionary:nil))
                    mapItem.name = "\(String(describing: name))"
                    mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
                }
            }
            
        case 1: // Call phone number
            if currentPlace?.phoneNumber != nil {
                
                if let phoneNumber = currentPlace?.phoneNumber?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "") {
                    if let phoneURL = URL(string: "telprompt://+\(phoneNumber)") {
                        UIApplication.shared.open(phoneURL)
                    } else {
                        break
                    }
                }
            }
            
        case 2: // Visit website
            
            if let url = currentPlace?.url {
                
                let safariViewController = SFSafariViewController(url: url)
                present(safariViewController, animated: true, completion: nil)
            }
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
