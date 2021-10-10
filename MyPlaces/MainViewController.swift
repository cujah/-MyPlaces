//
//  MainTableViewController.swift
//  MyPlaces
//
//  Created by Илья on 06.10.2021.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let searchController = UISearchController(searchResultsController: nil) // результаты поиска отображаются в исходном view controller(тк  nil)
    private var places: Results<Place>!                                     // Results - автообновляемый тип контейнера, возвращает запрашиваемые объекты
    private var filteredPlaces: Results<Place>!                             // массив для отфильтрованных записей
    private var ascendingSorting = true                                     // переменная для сортировки по возрастанию
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reversedSortingButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        places = realm.objects(Place.self)                              // self в данном случае для пояснения что нам нужен не объект, а тип данных Place
        
        // Setup the search controller:
        searchController.searchResultsUpdater = self                    // получатель инфо об изменении текста в поисковой строке является сам класс VC
        searchController.obscuresBackgroundDuringPresentation = false   // отключение запрета на взаимодействие с получаемым при поиске  контентом
        searchController.searchBar.placeholder = "Search"               // заголовок поиска
        navigationItem.searchController = searchController              // интегрируем стоку поиска в navigationBar
        definesPresentationContext = true                               // позволяет отпустить строку поиска при переходе на другой экран
        
    }
    
    // MARK: - Table view data source
    
    //    override func numberOfSections(in tableView: UITableView) -> Int {
    //        // #warning Incomplete implementation, return the number of sections
    //        return 0
    //    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering {
            return filteredPlaces.count
        }
        
        return places.isEmpty ? 0 : places.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        var place = Place()
        
        if isFiltering {
            place = filteredPlaces[indexPath.row]
        } else {
            place = places[indexPath.row ]
        }
        
        
        cell.nameLable.text = place.name
        cell.locationLable.text = place.location
        cell.typeLable.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        
        
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds = true
        
        return cell
    }
    
    
    // MARK: Table View Delegate
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let place = places[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, complete in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            complete(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            
            let place: Place
            if isFiltering {
                place = filteredPlaces[indexPath.row]
            } else {
                place = places[indexPath.row]
            }
            
            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place
        }
    }
    
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue ) {
        
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        newPlaceVC.savePlace()
        tableView.reloadData()
    }
    
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        sorting()
    }
    
    
    @IBAction func reversedSorting(_ sender: UIBarButtonItem) {
        
        ascendingSorting.toggle()
        
        if ascendingSorting {
            reversedSortingButton.image = #imageLiteral(resourceName: "AZ")
        } else {
            reversedSortingButton.image = #imageLiteral(resourceName: "ZA")
        }
        
        sorting()
    }
    
    
    private func sorting() {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        tableView.reloadData()
    }
    
}



extension MainViewController: UISearchResultsUpdating {
    
    public func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        
        // делаем фильтрацию по полю name и по полю location вне зависимости от регистра[c] %@ - заменяем на переменную searchText в обоих случаях
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        tableView.reloadData()
    }
    
}
