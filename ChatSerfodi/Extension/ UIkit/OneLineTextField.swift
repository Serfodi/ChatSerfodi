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
        
        var bottomView =  UIView()
        bottomView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        bottomView.backgroundColor = ColorAppearance.black.color()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(bottomView)
        
        NSLayoutConstraint.activate([
            bottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: self.trailingAnchor), 
            bottomView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        
    }
    
}
