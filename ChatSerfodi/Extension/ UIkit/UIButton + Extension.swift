//
//  UIButton + Extension.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 21.10.2023.
//

import Foundation
import UIKit

extension UIButton {
    
    convenience init(title: String,
                     titleColor: UIColor,
                     backgroundColor: UIColor,
                     fount: UIFont? = .avenir20(),
                     isShodow: Bool = false,
                     cornorRadius: CGFloat = 4) {
        self.init(type: .system)
        
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = fount
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = cornorRadius
        
        if isShodow {
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowRadius = 4
            self.layer.shadowOpacity = 0.2
            self.layer.shadowOffset = CGSize(width: 0, height: 4)
        }
    }
     
}
