//
//  RatingControl.swift
//  MyPlaces
//
//  Created by Илья on 10.10.2021.
//

import UIKit


@IBDesignable class RatingControl: UIStackView {    // @IBDesignable - позволяет отображать изменения в сториборде
    
    // MARK: Properties
    
    var rating = 0 {
        didSet {
            updateButtonSelectionState()
        }
    }
    
    private var ratingButtons = [UIButton]()
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0){
        didSet {
            setupButtons()
        }
    }
    
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    
    
    // MARK: Button action
    
    @objc func ratingButtonTapped(button: UIButton){
        
        guard let index = ratingButtons.firstIndex(of: button) else { return }  // firstIndex(of - индекс первого выбранного элемента
        
        // Calculate the rating of the selected button
        let selectedRating = index + 1
        
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }
    
    
    
    
    // MARK: Private methods:
    
    private func setupButtons() {
        
        for button in ratingButtons {                       // цикл удаления всех кнопок перед добавлением новых
            removeArrangedSubview(button)                   // удаляем из списка subview
            button.removeFromSuperview()                    // из stack view
        }
        ratingButtons.removeAll()                           // отчищаем массив кнопок

        
        // Load button image
        // для передачи изображений в интерфейс билдер необходимо явно указать их месторасположение
        let bundle = Bundle(for: type(of: self))            // класс Bundle определяет положение ресурсов в assets
        
        
        let filledStar = UIImage(systemName: "star.fill")
//        let filledStar = UIImage(named: "filledStar",                   // имя файла
//                                 in: bundle,                            // местоположение файла
//                                 compatibleWith: self.traitCollection)  // свойство traitCollection нужно для того,                                         чтобы убедиться что загружен правильный                                             вариант изображения

        let emptyStar = UIImage(systemName: "star")
        
//        let emptyStar = UIImage(named: "emptyStar",
//                                in: bundle,
//                                compatibleWith: self.traitCollection)
        
        let highlightedStar = UIImage(named: "highlightedStar",
                                      in: bundle,
                                      compatibleWith: self.traitCollection)
        
        for _ in 0..<starCount {
            
            // Create the button
            let button = UIButton()
            
            // Set the button image
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
            
            // Add constraints
            button.translatesAutoresizingMaskIntoConstraints = false            // отключение всех автоматически сгенерированных констрейнтов для кнопки
                                                                                // по умолчанию true. Но при размещении в stackView меняется на false
                                                                                // то есть тут оно в качестве привычки, чтобы не забыть если будем исп.  объект вне stack View
            
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true   // размер по высоте (еквивалентно размеру констрейта) + активация
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true    // размер по ширине аналогично
            
            // Setup button action
            button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)
            
            // Add button to stack
            addArrangedSubview(button)
            
            // Add new button to the rating button array
            ratingButtons.append(button)
        }
        
        updateButtonSelectionState()
        
    }
    
    private func updateButtonSelectionState() {
        for (index, button) in ratingButtons.enumerated() {  // enumerated возвращает из массива пару объект-индекс (получаем индекс каждой кнопки)
            button.isSelected = index < rating               //
        }
        
    }
     
}
