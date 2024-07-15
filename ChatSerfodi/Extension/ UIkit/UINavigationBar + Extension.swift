//
//  UINavigationBar.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 05.07.2024.
//

import UIKit

extension UINavigationBar {
    
    func addBGBlur() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundImage = UIImage()
        appearance.shadowImage = UIImage()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .clear
        appearance.backgroundEffect = UIBlurEffect(style: .regular)
        standardAppearance = appearance
        scrollEdgeAppearance = appearance
    }
    
}
