//
//  UIView + Extension.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 22.11.2023.
//

import UIKit

extension UIView {
    
    func applyGradients (cornerRadius: CGFloat) {
        self.backgroundColor = nil
        self.layoutIfNeeded()
        let gradientView = GradientView(from: .topTrailing, to: .bottomLeading, startColor: .purple, endColor: .blue)
        if let gradientLayer = gradientView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = self.bounds
            gradientLayer.cornerRadius = cornerRadius
            self.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
    
}
