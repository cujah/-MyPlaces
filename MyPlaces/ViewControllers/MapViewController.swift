//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Илья on 14.10.2021.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {

    let mapManager = MapManager()
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    
    let annotationIdentifier = "annotationIdentifier"
    

    var incomeSegueIdentifier = ""
    
    
    var previousLocation: CLLocation? {
        didSet {
            mapManager.startTrackingUserLocation(for: mapView, and: previousLocation) { (currentLocation) in
                self.previousLocation = currentLocation
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
            }
        }
    }
    
    
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet var getDirectionsButton: UIButton!
    @IBOutlet var directionsInfo: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        directionsInfo.isHidden = true
        addressLabel.text = ""
        mapView.delegate = self
        setupMapView()
    }

    
    @IBAction func cancelButtonPressed() {
        directionsInfo.isHidden = true
    }
    
    @IBAction func goButtonPressed() {
    }
    
        
    @IBAction func centerViewInUserLocation() {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }

    @IBAction func getDirectionsButtonPressed() {
        mapManager.getDirections(for: mapView) { (location) in
            self.previousLocation = location
        }
    }
    
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    private func setupMapView() {
        
        getDirectionsButton.isHidden = true
        
        mapManager.checkLocationServices(mapView: mapView, segueIdentifier: incomeSegueIdentifier) {
            mapManager.locationManager.delegate = self
        }
        
        if incomeSegueIdentifier == "showPlace" {
            mapManager.setupPlacemark(place: place, mapView: mapView)
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            getDirectionsButton.isHidden = false
        }
    }
    
}


extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil }  // проверка не является ли аннотация текущей                                                                 позицией пользователя
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView             // приводим к типу MKPinAnnotationView тк у него есть уже маркер (булавка)
        
        
        // если на карте не окажется ни одного представления с аннотацией для переиспользования, то инициализируем новый объект соответствующими значениями:
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation,
                                                 reuseIdentifier: annotationIdentifier)
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
    
    // данный метот срабатывает каждый раз при смене отображаемого на экране региона
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let center = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        
        if incomeSegueIdentifier == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {               // с задержкой в 3 сек
                self.mapManager.showUserLocation(mapView: self.mapView)         // обновляем локацию пользователя
            }
        }
        
        // для освобождением ресурсов связанных с геокодированием рекомендуется делать отмену отложенного запроса:
        geocoder.cancelGeocode()
        
        // метод reverseGeocodeLocation принимает координаты и completion handler -
        // данный блок возвращает массив меток соответствующий координатам, а также
        // может вернуть объект ошибки с причинами, по которым метки не были обнаружены
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            if let error =  error {     // проверяем на наличие ошибок
                print(error)            // если есть, печатаем их и выходим из метода
                return
            }
            
            guard let placemarks = placemarks else { return } // извлекаем метки (массив должен вернуть 1 метку)
            let placemark = placemarks.first
            
            let streetName = placemark?.thoroughfare        // извлекаем название улицы
            let buildNumber = placemark?.subThoroughfare    // извлекаем номер дома
            
            // Для корректной работы обновлять интерфейс в основном потоке асинхронно
            DispatchQueue.main.async {
                
                if streetName != nil && buildNumber != nil {
                    self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
            }
        }
    }
    
    
    // метод отображения маршрута на карте (при создании наложения маршрута оно по умолчанию невидимое)
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        // создаем линию по наложению созданному при построении маршрута:
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor =  .blue
        
        return renderer
    }
    
}


extension MapViewController: CLLocationManagerDelegate {
    
    // метод didChangeAuthorization вызывается при каждом изменении статуса авторизации приложения для использования служб геолокации
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        mapManager.checkLocationAutorization(mapView: mapView,
                                             segueIdentifier: incomeSegueIdentifier)
    }
    
}
