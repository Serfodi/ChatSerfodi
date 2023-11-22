//
//  StackView + Extension.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 28.10.2023.
//

import UIKit

extension UIStackView {
    
    convenience init (arrangedSubviews: [UIView], axis: NSLayoutConstraint.Axis, spacing: CGFloat) {
        self.init(arrangedSubviews: arrangedSubviews)
        self.axis = axis
        self.spacing = spacing
    }
    
}
