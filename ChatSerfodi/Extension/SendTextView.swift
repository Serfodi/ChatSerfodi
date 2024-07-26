//
//  SendTextView.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 26.07.2024.
//

import UIKit

extension UITextView {
    
    convenience init(textColor: UIColor, font: UIFont, bg: UIColor) {
        self.init(frame: .zero)
        
        backgroundColor = bg
        
//        placeholder = NSLocalizedString("FirstMessage", comment: "")
//        font = FontAppearance.secondDefault
//        clearButtonMode = .whileEditing
//        borderStyle = .none
        
//        layer.cornerRadius = 21
        layer.masksToBounds = true
        
        layer.borderWidth = 0.3
        layer.borderColor = ColorAppearance.black.color().withAlphaComponent(0.5).cgColor
        
        
        
        
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "arrow.up.message.fill")?.withRenderingMode(.alwaysOriginal)
        button.setImage(image, for: .normal)
        button.tintColor = ColorAppearance.blue.color()

        
    }
    
}
