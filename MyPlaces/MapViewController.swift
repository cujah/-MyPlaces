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
    
    var place: Place!
    
    override func viewDidLoad() {
        super.viewDidLoad()
          setupPlacemark()
    }

        
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    

    private func setupPlacemark(){
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { placemarks, error in
            if let error = error {
                print (error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first                            // получаем метку на карте
        
            let annotation = MKPointAnnotation()                        // для описания точки на карте
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else { return }   // определяем местоположение маркера
            
            annotation.coordinate = placemarkLocation.coordinate        // привязываем аннотацию к точке на карте
            
            self.mapView.showAnnotations([annotation], animated: true)  // указываем все аннотации которые должны                                                               быть определены в зоне видимости карты
            
            self.mapView.selectAnnotation(annotation, animated: true)   // выделение аннотации
            
            
            
        }
        
    }
    
}
