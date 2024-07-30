//
//  UIButton + Extension.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 21.10.2023.
//

import Foundation
import UIKit
import Lottie

extension UIButton {
    
    /// Текстовая кнопка
    convenience init(title: String, titleColor: UIColor, fount: UIFont) {
        self.init(type: .system)
        self.setTitle(NSLocalizedString(title, comment: ""), for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = fount
    }
    
    enum CornerRadiusType {
        case not
        case round
    }
    
    convenience init(title: String,
                     titleColor: UIColor,
                     backgroundColor: UIColor,
                     fount: UIFont? = FontAppearance.buttonText,
                     isShadow: Bool = false,
                     cornerRadius: CGFloat = 27) {
        
        self.init(type: .system)
        self.setTitle(NSLocalizedString(title, comment: ""), for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = fount
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = cornerRadius
        
        if isShadow {
            self.layer.shadowColor = UIColor(white: 0.2, alpha: 0.5).cgColor
            self.layer.shadowRadius = 4
            self.layer.shadowOpacity = 0.5
            self.layer.shadowOffset = CGSize(width: 0, height: 2)
        }
    }
    
    convenience init(title: String,
                     titleColor: UIColor,
                     backgroundEffect: UIVisualEffect,
                     fount: UIFont? = FontAppearance.buttonText,
                     cornerRadius: CornerRadiusType = .round) {
        self.init(type: .system)
        self.setTitle(NSLocalizedString(title, comment: ""), for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = fount
        self.backgroundColor = .clear
        
        if cornerRadius == .round {
            self.layer.cornerRadius = 27
        }
    }
    
    
    func customizeGoogleButton() {
        let googleAnimationLogo = LottieAnimationView(name: "google")
        googleAnimationLogo.loopMode = .loop
        googleAnimationLogo.contentMode = .scaleAspectFit
        googleAnimationLogo.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(googleAnimationLogo)
        googleAnimationLogo.play()
        googleAnimationLogo.addConstraint(.init(item: googleAnimationLogo, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 64))
        let aspectRatioConstraint = NSLayoutConstraint(item: googleAnimationLogo, attribute: .width, relatedBy: .equal, toItem: googleAnimationLogo, attribute: .height, multiplier: 1.0, constant: 0)
        googleAnimationLogo.addConstraint(aspectRatioConstraint)
        googleAnimationLogo.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
 
    func addShine() {
        let gradientBaseLayer = CAGradientLayer()
        let gradientBorderBLayer = CAGradientLayer()
        
        clipsToBounds = true
        
        setupGradient(gradientBaseLayer)
        setupGradient(gradientBorderBLayer)
        
        gradientBorderBLayer.frame = bounds
        gradientBaseLayer.frame = bounds
        
        self.layer.addSublayer(gradientBaseLayer)
        
        let pacth = UIBezierPath(roundedRect: bounds, cornerRadius: self.layer.cornerRadius)
        let rectClip = CGRect(origin: CGPoint(x: 2, y: 2), size: CGSize(width: bounds.width, height: bounds.height - 2 * 2))
        let pachtClip = UIBezierPath(roundedRect: rectClip, cornerRadius: self.layer.cornerRadius)
        pacth.append(pachtClip)
        
        let mask = CAShapeLayer()
        mask.fillRule = .evenOdd
        gradientBorderBLayer.mask = mask
        
        (gradientBorderBLayer.mask as? CAShapeLayer)?.frame = bounds
        (gradientBorderBLayer.mask as? CAShapeLayer)?.path = pacth.cgPath
        
        self.layer.addSublayer(gradientBorderBLayer)
        
        func setupGradient(_ GradientBaseLayer: CAGradientLayer) {
            GradientBaseLayer.colors = [
                UIColor(red: 1, green: 1, blue: 1, alpha: 0).cgColor,
                UIColor(red: 1, green: 1, blue: 1, alpha: 0.85).cgColor,
                UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor,
                UIColor(red: 1, green: 1, blue: 1, alpha: 0.85).cgColor,
                UIColor(red: 1, green: 1, blue: 1, alpha: 0).cgColor
            ]
            GradientBaseLayer.locations = [0, 0.4, 0.52, 0.65, 1]
            GradientBaseLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
            GradientBaseLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
            GradientBaseLayer.compositingFilter = "softLightBlendMode"
        }
        
        func animationLayer() {
            let theAnimation = CABasicAnimation(keyPath: "position")
            theAnimation.fromValue = [-self.frame.width * 2, self.frame.height / 2]
            theAnimation.toValue = [self.frame.width * 3, self.frame.height / 2]
            theAnimation.duration = 5
            theAnimation.autoreverses = true
            theAnimation.repeatCount = .infinity
            
            gradientBaseLayer.add(theAnimation, forKey: "animatePosition")
            gradientBorderBLayer.add(theAnimation, forKey: "animatePosition")
        }
        
        animationLayer()
    }
    
}
