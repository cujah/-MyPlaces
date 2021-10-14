//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Илья on 14.10.2021.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
          
    }

        
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    

}
