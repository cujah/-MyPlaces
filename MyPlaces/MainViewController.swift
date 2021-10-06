//
//  MainTableViewController.swift
//  MyPlaces
//
//  Created by Илья on 06.10.2021.
//

import UIKit

class MainViewController: UITableViewController {
    
    let placeNames = ["BetankurSkatePlaza",
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

    override func viewDidLoad() {
        super.viewDidLoad()

    
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return placeNames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell

        cell.nameLable.text = placeNames[indexPath.row]
        cell.imageOfPlace.image = UIImage(named: placeNames[indexPath.row])
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        
        cell.imageOfPlace.clipsToBounds = true
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
