//
//  OneLineTextField.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 08.11.2023.
//

import UIKit

class OneLineTextField: UITextField {

    
    convenience init (font: UIFont? = FontAppearance.defaultText) {
        self.init()
        
        self.font = font
        self.borderStyle = .none
        self.textColor = ColorAppearance.black.color()
        self.translatesAutoresizingMaskIntoConstraints = false
        
        var bottomView =  UIView(frame: .zero)
        bottomView.backgroundColor = ColorAppearance.black.color()
        self.addSubview(bottomView)
        bottomView.height(1)
        bottomView.bottomToSuperview()
        bottomView.leftToSuperview()
        bottomView.rightToSuperview()
    }
    
}
