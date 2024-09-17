//
//  UIButton + Extension.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 21.10.2023.
//

import Foundation
import UIKit
import Lottie

// https://www.kodeco.com/27854768-uibutton-configuration-tutorial-getting-started

extension UIButton {
    
    /// Текстовая кнопка
    convenience init(title: String, titleColor: UIColor, fount: UIFont) {
        self.init(type: .system)
        self.setTitle(NSLocalizedString(title, comment: ""), for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = fount
    }
    
    
    convenience init(title: String,
                     titleColor: UIColor,
                     backgroundColor: UIColor,
                     fount: UIFont? = FontAppearance.buttonText,
                     isShadow: Bool = false,
                     cornerRadius: CGFloat = 27,
                     image: UIImage? = nil) {
        
        self.init(type: .custom)
        self.setTitle(NSLocalizedString(title, comment: ""), for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = fount
        self.backgroundColor = backgroundColor
//        self.tintColor = .clear
        self.layer.cornerRadius = cornerRadius
        self.titleLabel?.textAlignment = .center
        
        if isShadow {
            layer.shadowColor = UIColor(white: 0.2, alpha: 0.5).cgColor
            layer.shadowRadius = 4
            layer.shadowOpacity = 0.5
            layer.shadowOffset = CGSize(width: 0, height: 2)
        }
        
        if let image = image {
            setImage(image, for: .normal)
        }
    }
    
}
