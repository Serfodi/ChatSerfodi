//
//  InsertableTextField.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 22.11.2023.
//

import UIKit

class InsertableTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        placeholder = NSLocalizedString("FirstMessage", comment: "")
        font = FontAppearance.secondDefault
        clearButtonMode = .whileEditing
        borderStyle = .none
//        layer.cornerRadius = 21
        layer.masksToBounds = true
        
        layer.borderWidth = 0.3
        layer.borderColor = ColorAppearance.black.color().withAlphaComponent(0.5).cgColor
        
        
        
        
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "arrow.up.message.fill")?.withRenderingMode(.alwaysOriginal)
        button.setImage(image, for: .normal)
        button.tintColor = ColorAppearance.blue.color()
        rightView = button
        rightView?.frame = CGRect(x: 0, y: 0, width: 40, height: 35)
        rightViewMode = .always
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 12, dy: 0)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 12, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 12, dy: 0)
    }
    
//    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
//        var rect = super.leftViewRect(forBounds: bounds)
//        rect.origin.x += 12
//        return rect
//    }
    
    
    // MARK: FIX
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        rect.origin.x -= 12
        return rect
    }
    
    
}
