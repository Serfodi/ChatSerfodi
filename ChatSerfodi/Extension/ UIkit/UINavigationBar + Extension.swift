//
//  UINavigationBar.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 05.07.2024.
//

import UIKit

extension UINavigationBar {
    
    func configuration() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundImage = UIImage()
        appearance.shadowImage = UIImage()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .clear
        appearance.backgroundEffect = UIBlurEffect(style: .light)
        appearance.titleTextAttributes = [.font: FontAppearance.buttonText, .foregroundColor: ColorAppearance.black.color()]
        standardAppearance = appearance
        scrollEdgeAppearance = appearance
    }
    
}
