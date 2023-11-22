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
        placeholder = "White something here ..."
        font = UIFont.systemFont(ofSize: 14)
        clearButtonMode = .whileEditing
        borderStyle = .none
        layer.cornerRadius = 18
        layer.masksToBounds = true
        
        let imageView = UIImageView(image: UIImage(systemName: "face.smiling")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal))
        leftView = imageView
        leftView?.frame = CGRect(x: 0, y: 0, width: 19, height: 19)
        leftViewMode = .always
        
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "paperplane.fill")?.withRenderingMode(.alwaysOriginal)
        button.setImage(image, for: .normal)
        button.applyGradients(cornerRadius: 10)
        rightView = button
        rightView?.frame = CGRect(x: 0, y: 0, width: 19, height: 19)
        rightViewMode = .always
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 36, dy: 0)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 36, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 36, dy: 0)
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        rect.origin.x += 12
        return rect
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        rect.origin.x -= 12
        return rect
    }
    
    
}
