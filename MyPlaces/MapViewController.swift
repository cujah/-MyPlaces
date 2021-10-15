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

    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    
    let annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()                     // отвечает за настройку и работу служб геолокации
    let regionInMeters = 10_000.00
    var incomeSegueIdentifier = ""
    var placeCoordinate: CLLocationCoordinate2D?                     // переменная для хранение координат
    
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet var goButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressLabel.text = ""
        mapView.delegate = self
        setupMapView()
        checkLocationServices()
    }

        
    @IBAction func centerViewInUserLocation() {
        
        showUserLocation()
        
    }
    
    @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }

    @IBAction func goButtonPressed() {
        getDirections()
    }
    
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    private func setupMapView() {
        
        goButton.isHidden = true
        
        if incomeSegueIdentifier == "showPlace" {
            setupPlacemark()
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
    }
    
    private func setupPlacemark(){
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()                                     // преобразует адрес в координаты
        geocoder.geocodeAddressString(location) { (placemarks, error) in  // geocodeAddressString координаты из string
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
            
            self.placeCoordinate = placemarkLocation.coordinate         // передаем координаты в переменную
            
            self.mapView.showAnnotations([annotation], animated: true)  // указываем все аннотации которые должны                                                               быть определены в зоне видимости карты
            
            self.mapView.selectAnnotation(annotation, animated: true)   // выделение аннотации
            
        }

    }
    
    private func checkLocationServices() {
        
        if CLLocationManager.locationServicesEnabled() {                // проверка включенных служб геолокаций
            setupLocationManager()
            checkLocationAutorization()
        } else {
        // откладваем вызов алерта на 1 сек(иначе не отобразится), тк вызов во viewDidLoad идет еще до загрузки view
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Location services are disabled",
                    message: "To enable it go: Settings -> Privacy -> Location Services and turn it on")
            }
        }
    }
    
    private func showUserLocation() {
        
        if let location = locationManager.location?.coordinate {        // если удается определить местоположение пользователя
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func getDirections() {
        
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        
        guard let request = crateDirectionRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)                     // создаем маршрут на основе запроса
        
        directions.calculate { (response, error) in                          // запускаем рассчет маршрута
            if let error = error {
                print(error)
                return
            }
          
            guard let response = response else {                             // пробуем извлеч запрос
                self.showAlert(title: "Error", message: "Direction is not available")
                return
            }
            
            // объект response содержит в себе массив routes с маршрутами типа MKRoutes
            for route in response.routes {                                  // делаем перебор по маршрутам
                
                // создаем на карте дополнительное наложение со всеми доступными маршрутами:
                self.mapView.addOverlay(route.polyline)               // в route.poliline подробная геометрия маршрута
                
                // фокусируем карту чтобы весь маршрут был виден целеком (MapRect определяет зону видимости карты)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                
                // работаем с доп. инфо по маршруту(расстояние и время в пути):
                
                // дистанция определяется в метрах, поэтому расстояние/1000 и округляем до десятых:
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime                 // время определяется в секундах
                
                print("Расстояние до места: \(distance) км.")
                print("Время в пути: \(timeInterval) сек.")
            }
            
        }
        
    }
    
    private func crateDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let destinationCoordinate = placeCoordinate else { return nil }   // координаты места назначения
        let startingLocation = MKPlacemark(coordinate: coordinate)              // точка старта маршрута
        let destination = MKPlacemark(coordinate: destinationCoordinate )       // точка назначения
        
        let request = MKDirections.Request()                // данный объект позволяет вернуть начальную и                                                          конечную точку маршрута, а также вид транспорта
        request.source = MKMapItem(placemark: startingLocation)         // точка начала маршрута
        request.destination = MKMapItem(placemark: destination)         // точка конца маршрута
        request.transportType = .automobile                             // тип транспорта
        request.requestsAlternateRoutes = true                          // позволяет строить несколько маршрутов если                                                                   есть альтернативные варианты
        
        return request
    }
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude        // получаем широту
        let longitude = mapView.centerCoordinate.longitude      // получаем долготу
        
        return CLLocation(latitude: latitude, longitude: longitude) // возвращаем координаты точки цента экрана
    }
    
    
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        present(alert, animated: true )
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self      // назначаем делегата для отработки метода locationManager из расширения
        locationManager.desiredAccuracy = kCLLocationAccuracyBest       // настройка точности определения геолокации
    }
    
    private func checkLocationAutorization() {           // проверка статуса на разрешение испрользования геолокации
        switch locationManager.authorizationStatus {        // возвращает статусов состояний использ. геолокации:
        case .authorizedWhenInUse:                          // разрешено при использовании приложения
            if incomeSegueIdentifier == "getAddress" { showUserLocation() }
            mapView.showsUserLocation = true
            break
        case .denied:                                       // не разрешено
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Your location is not available",
                    message: "To give permission go to Settings -> Privacy -> Location Services -> MyPlaces")
            }
            break
        case .notDetermined:                                // статус не определен (еще не был сделан выбор)
            locationManager.requestWhenInUseAuthorization() // делаем запрос на разрешение использ. геолокации
                                                    // в info.plist "Privacy - Location When In Use Usage Description"
        case .restricted:                                   // не авторизовано для использ. служб геолокации
            // alert
            break
        case .authorizedAlways:                             // разрешено всегда
            break
        @unknown default:
            print("New case is available")
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
    
    // данный метот срабатывает каждый раз при смене отображаемого на экране региона
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
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
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAutorization()
    }
    
}
