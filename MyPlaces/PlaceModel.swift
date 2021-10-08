//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Илья on 06.10.2021.
//

import UIKit
import RealmSwift

class Place: Object {
    
    @Persisted var name = ""
    @Persisted var location: String?
    @Persisted var type: String?
    @Persisted var imageData: Data?

    
    // convenience - назначенный инициализатор,  для полной инициализации всех свойств в классе
    // - не является обязательным
    // - не создает объект,  а присваивает новые значения уже созданному объекту
    convenience init(name: String, location: String?, type: String?, imageData: Data?) {
        self.init()                                                  // вызываем инициализатор класса и заполняем все свойства значениями по умолчанию
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
        
        
    }
    
    
}
