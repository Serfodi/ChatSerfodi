//
//  Label + Extension.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 21.10.2023.
//

import UIKit

extension UILabel {
    
    convenience init(text: String, alignment: NSTextAlignment = .left,  fount: UIFont? = FontAppearance.defaultText, color: UIColor = ColorAppearance.black.color()) {
        self .init()
        self.font = fount
        self.text = NSLocalizedString(text, comment: "")
        self.textColor = color
        self.textAlignment = alignment
    }
}
