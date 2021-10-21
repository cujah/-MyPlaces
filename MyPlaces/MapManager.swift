//
//  MapManager.swift
//  MyPlaces
//
//  Created by Илья on 18.10.2021.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager()                     // отвечает за настройку и работу служб геолокации
    
    private let regionInMeters = 1000.00
    private var directionsArray: [MKDirections] = []
    private var placeCoordinate: CLLocationCoordinate2D?                    // переменная для хранение координат
    
    
    func setupPlacemark(place: Place, mapView: MKMapView){
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()                                         // преобразует адрес в координаты
        geocoder.geocodeAddressString(location) { (placemarks, error) in    // geocodeAddressString координаты из string
            if let error = error {
                print (error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first                                // получаем метку на карте
            
            let annotation = MKPointAnnotation()                            // для описания точки на карте
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placemarkLocation = placemark?.location else { return }   // определяем местоположение маркера
            
            annotation.coordinate = placemarkLocation.coordinate        // привязываем аннотацию к точке на карте
            
            self.placeCoordinate = placemarkLocation.coordinate         // передаем координаты в переменную
            
            mapView.showAnnotations([annotation], animated: true)       // указываем все аннотации которые должны                                                               быть определены в зоне видимости карты
            
            mapView.selectAnnotation(annotation, animated: true)        // выделение аннотации
        }
    }
    
    
    // Проверка доступности сервисов геолокации
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        
        if CLLocationManager.locationServicesEnabled() {                // проверка включенных служб геолокаций
            locationManager.desiredAccuracy = kCLLocationAccuracyBest   // настройка точности определения геолокации
            checkLocationAutorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        } else {
        // откладваем вызов алерта на 1 сек(иначе не отобразится), тк вызов во viewDidLoad идет еще до загрузки view
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Location services are disabled",
                    message: "To enable it go: Settings -> Privacy -> Location Services and turn it on")
            }
        }
    }
    
    
    // Проверка авторизации приложения для испрльзования сервисов геолокации
    func checkLocationAutorization(mapView: MKMapView, segueIdentifier: String) {
        switch locationManager.authorizationStatus {        // возвращает статусов состояний использ. геолокации:
        case .authorizedWhenInUse:                          // разрешено при использовании приложения
            mapView.showsUserLocation = true
            if segueIdentifier == "getAddress" { showUserLocation(mapView: mapView) }
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
            break
        case .authorizedAlways:                             // разрешено всегда
            break
        @unknown default:
            print("New case is available")
        }
    }
    
    
    // Фокус карты на местоположении пользователя
    func showUserLocation(mapView: MKMapView) {
        
        if let location = locationManager.location?.coordinate {        // если удается определить местоположение пользователя
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    // Строим маршрут от местоположения пользователя до заведения
    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
        
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        
        locationManager.startUpdatingLocation()              // вкл. постоянного отслеж. местоположения пользователя
        
        // первоначальная инициализация переменной previousLocation по текущим координатам пользователя:
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)                     // создаем маршрут на основе запроса
        
        resetMapView(withNew: directions, mapView: mapView)
        
        directions.calculate { (response, error) in                         // запускаем рассчет маршрута
            if let error = error {
                print(error)
                return
            }
            
            guard let response = response else {                            // пробуем извлеч запрос
                self.showAlert(title: "Error", message: "Directions are not available")
                return
            }
            
            // объект response содержит в себе массив routes с маршрутами типа MKRoutes
            for route in response.routes {                          // делаем перебор по маршрутам
                
                // создаем на карте дополнительное наложение со всеми доступными маршрутами:
                mapView.addOverlay(route.polyline)                  // в route.poliline подробная геометрия маршрута
                
                // фокусируем карту чтобы весь маршрут был виден целеком (MapRect определяет зону видимости карты)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime
                
                print("Расстояние до места: \(distance) км.")
                print("Время в пути составит: \(timeInterval) сек.")
                
            }
            
        }
    
    }
    
    
    //    func showDirectionInfoAlert(routes: [MKRoute],
    //                                directions: MKDirections,
    //                                location: CLLocationCoordinate2D,
    //                                mapView: MKMapView,
    //                                previousLocation: (CLLocation) -> ()) {
    //
    //        let alert = UIAlertController(title: "Найдены маршруты : \(routes.count)",
    //                                      message: nil,
    //                                      preferredStyle: .actionSheet)
    //
    //        for route in routes {
    //
    //            let routeTimeInMinutes = Int(route.expectedTravelTime/60)
    //            var routeTime = ""
    //
    //            if routeTimeInMinutes > 60 {
    //                routeTime = "\(routeTimeInMinutes / 60) ч \(routeTimeInMinutes % 60) мин"
    //            } else {
    //                routeTime = "\(routeTimeInMinutes) мин"
    //            }
    //
    //            let distance = String(format: "%.1f", route.distance / 1000) + " км"
    //
    //            let routeInfoAction = UIAlertAction(title: routeTime + "  /  " +  distance, style: .default) { _ in
    //                //self.resetMapView(withNew: mapView)
    //                mapView.addOverlay(route.polyline)
    //                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
    //                self.locationManager.startUpdatingLocation() // вкл. постоянного отслеж. местоположения пользователя
    //                // первоначальная инициализация переменной previousLocation по текущим координатам пользователя:
    //                previousLocation = (CLLocation(latitude: location.latitude, longitude: location.longitude))
    //            }
    //
    //            alert.addAction(routeInfoAction)
    //        }
    //        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    //        alert.addAction(cancelAction)
    //        present(alert, animated: true)
    //    }
    
    
    // Настройка запроса для рассчета маршрута
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
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
    
    
    // Меняем отображаемую зону области карты в соответствии с перемещением пользователя
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        
        guard let location = location else { return }
        let center = getCenterLocation(for: mapView)                      // координаты центра отображаемой обл.
        
        // если расстояние от предыдущего местоположения пользователя до текущей центральной точки карты больше 50м
        guard center.distance(from: location ) > 50 else { return }
        
        closure(center)
        //        self.previousLocation = center                                  // обновляем предыдущие координаты на текущие
        //
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {           // задержка в 3 сек чтобы показать маршрут
        //            self.showUserLocation()                                     // показываем текущее положение пользователя
        //        }
    }
    
    
    
    // Сброс всех ранее построенных маршрутов перед построением нового
    func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)              // удаляем все текущие наложения на карте
        directionsArray.append(directions)                    // добавляем в массив текущие маршруты
        let _ = directionsArray.map { $0.cancel() }           // перебераем все значения в массиве и отменяем маршрут
        directionsArray.removeAll()                           // удаляем все элементы из массива
    }
    
    
    
    // Определение центра отображаемой области карты
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude        // получаем широту
        let longitude = mapView.centerCoordinate.longitude      // получаем долготу
        
        return CLLocation(latitude: latitude, longitude: longitude) // возвращаем координаты точки цента экрана
    }
    
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)         // определяем окно по границе главного экрана
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1    // определяем позиционирование окна относительно других
        alertWindow.makeKeyAndVisible()                       // делаем окно ключевым и видимым
        alertWindow.rootViewController?.present(alert, animated: true ) // вызываем окно в качестве alert contoller
    }
    
}







