//
//  NewPlaceTableViewController.swift
//  MyPlaces
//
//  Created by Илья on 07.10.2021.
//

import UIKit

class NewPlaceViewController: UITableViewController {

    var newPlace: Place?
    var imageIsChanged = false
    
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        tableView.tableFooterView = UIView()                        // убираем разлиновку в ячейках без контента
        saveButton.isEnabled = false
        
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        
    }
    
    
    // MARK: Table View delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            let cameraIcon = #imageLiteral(resourceName: "camera")
            let photoIcon = #imageLiteral(resourceName: "photo")
            
            let actionSheet = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
            
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary )
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
            
        } else {
            view.endEditing(true)        // скрываем клавиатуру по тапу на экран вне клавиатуры, кроме первой ячейки
        }
    }

    func saveNewPlace() {
        
        let image: UIImage?
        
        if imageIsChanged {
            image = placeImage.image
        } else {
            image =  #imageLiteral(resourceName: "local")
        }
        
        newPlace = Place(name: placeName.text!,
                         location: placeLocation.text,
                         type: placeType.text,
                         image: image,
                         placeImage: nil)
    }

    @IBAction func cancelAction(_ sender: UIBarButtonItem) { 
        dismiss(animated: true)
    }
    
    
}


// MARK: Text Field delegate

extension NewPlaceViewController: UITextFieldDelegate, UINavigationControllerDelegate {
    
    // скрываем клавиатуру по нажатию на done
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged(){
        if placeName.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    
}


// MARK: Work with image

extension NewPlaceViewController: UIImagePickerControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType){
        
        if UIImagePickerController.isSourceTypeAvailable(source) {   // проверка на доступность источника изображения
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self                             // делегируем выполнение imagePickerController() классу NewPlaceViewController
            imagePicker.allowsEditing = true                        // позволяет редактировать изображ. перед использ.
            imagePicker.sourceType = source                         // определяем тип источника
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        placeImage.image = info[.editedImage] as? UIImage        // берем значение по ключу editedImage и кастуем до UIImage
        placeImage.contentMode = .scaleAspectFill                // масштабируем фото по размерам UIImage
        placeImage.clipsToBounds = true                          // обрезаем края за пределами UIImage
        
        imageIsChanged = true
        
        dismiss(animated: true)                                    // закрываем  imagePickerController
        
    }
    
}
