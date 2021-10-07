//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Илья on 06.10.2021.
//

import UIKit

struct Place {
    
    var name: String
    var location: String?
    var type: String?
    var image: UIImage?
    var placeImage: String?
    
    
    static let placeNames = ["BetankurSkatePlaza",
                      "СпотПодМостом",
                      "ЯмаДыбенко",
                      "Смена",
                      "Жесть",
                      "StreetSportAcademy",
                      "Бугры",
                      "Черная речка",
                      "Передовиков",
                      "Парк 300-Летия",
                      "Сестроретск рампа",
                      "VseVPark",
                      "Ломоносов",
                      "Молодежное",
                      "Гатчина"]
    
    
    static func getPlaces() -> [Place] {
        
        var places = [Place]()
        
        for place in placeNames {
            places.append(Place(name: place, location: "Санкт-Петербург", type: "cкейтпарк", image: nil, placeImage: place))
        }
        return places
    }
    
    
}
