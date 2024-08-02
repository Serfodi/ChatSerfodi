//
//  OneLineTextField.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 08.11.2023.
//

import UIKit
import TinyConstraints

final class OneLineTextField: UITextField {

    convenience init (font: UIFont = FontAppearance.defaultText) {
        self.init()
        
        self.font = font
        self.borderStyle = .none
        self.textColor = ColorAppearance.black.color()
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomView =  UIView(frame: .zero)
        bottomView.backgroundColor = ColorAppearance.black.color()
        self.addSubview(bottomView)
        bottomView.height(1)
        bottomView.bottomToSuperview()
        bottomView.leftToSuperview()
        bottomView.rightToSuperview()
    }
    
}

final class OneLineTextView: InputTextView {
    
    convenience init (font: UIFont = FontAppearance.defaultText) {
        self.init(font: font, textColor: ColorAppearance.black.color(), backgroundColor: .clear)
        
        let bottomView =  UIView(frame: .zero)
        bottomView.backgroundColor = ColorAppearance.black.color()
        
        self.textInputView.addSubview(bottomView)
        
        bottomView.height(1)
        bottomView.bottomToSuperview()
        bottomView.leftToSuperview()
        bottomView.rightToSuperview()
        
    }
    
}
