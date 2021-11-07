//
//  RoutesControl.swift
//  MyPlaces
//
//  Created by Илья on 20.10.2021.
//

import UIKit
import SwiftUI
import Network
import MapKit

@IBDesignable class RoutesControl: UIStackView {

    // MARK: Properties
    
    private var routeButtons = [UIButton]()
    var routesCount: Int = 3
    var routeInfo: String = "test time"
    
    
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
    
    @objc func routeButtonTapped(button: UIButton) {
        resetButtons()
        guard let index = routeButtons.firstIndex(of: button) else { return }
        print("Button \(index) pressed")
        button.backgroundColor = #colorLiteral(red: 0.3411764706, green: 0.4078431373, blue: 0.5803921569, alpha: 1)
    }

    
    // MARK: Private methods
    
    private func resetButtons() {
        for button in routeButtons {
            button.backgroundColor = .darkGray
        }
    }
    
    private func setupButtons() {
        
        for button in routeButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        routeButtons.removeAll()
        
        for _ in 0..<routesCount {
            
            // Create the button
            let button = UIButton()
            button.layer.cornerRadius = 10
            
            // Set the button title
            button.setTitle(routeInfo, for: .normal)
            
            // Set the button background
            button.backgroundColor = .darkGray
            
            // Add constraints:
//            button.translatesAutoresizingMaskIntoConstraints = false          // откл. автоматические констрейнты
//            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
//            button.widthAnchor.constraint(equalToConstant: 44).isActive = true
            
            // Setup the button action
            button.addTarget(self, action: #selector(routeButtonTapped(button:)), for: .touchUpInside)
            
            // Add button to the stack
            addArrangedSubview(button)
            
            // Add the new button to the button array
            routeButtons.append(button)
            
            routeButtons.first?.backgroundColor = #colorLiteral(red: 0.3411764706, green: 0.4078431373, blue: 0.5803921569, alpha: 1)
        }
        
    }
    
}
