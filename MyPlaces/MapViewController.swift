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
    let annotationIdentifier = "annotationIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
          setupPlacemark()
    }

        
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    

    private func setupPlacemark(){
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()                                     // преобразует адрес в координаты
        geocoder.geocodeAddressString(location) { placemarks, error in  // geocodeAddressString координаты из string
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


extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil }  // проверка не является ли аннотация текущей                                                                 позицией пользователя
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView             // приводим к типу MKPinAnnotationView тк у него есть уже маркер (булавка)
        
        
        // если на карте не окажется ни одного представления с аннотацией для переиспользования, то инициализируем новый объект соответствующими значениями:
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true           // отображаем аннотацию в виде баннера
        }
        
        // отображаем фото места на баннере
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView                       // отображаем фото справа
        }
        
        return annotationView
        
    }
    
}
