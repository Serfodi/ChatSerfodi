//
//  UIView + Extension.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 22.11.2023.
//

import UIKit

extension UIView {
    
    var snapshot: UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let capturedImage = renderer.image { context in
            layer.render(in: context.cgContext)
        }
        return capturedImage
    }
    
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
    
    func addBlur(blur: UIBlurEffect) {
        backgroundColor = .clear
        let effect = UIVisualEffectView(effect: blur)
        effect.frame = self.bounds
        effect.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        insertSubview(effect, at: 1)
    }
    
    
    
    
}
