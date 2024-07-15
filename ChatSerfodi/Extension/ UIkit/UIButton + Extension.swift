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
                     cornerRadius: CornerRadiusType = .round) {
        
        self.init(type: .system)
        self.setTitle(NSLocalizedString(title, comment: ""), for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = fount
        self.backgroundColor = backgroundColor
        
        if cornerRadius == .round {
            self.layer.cornerRadius = 27
        }
        if isShadow {
            self.layer.shadowColor = UIColor(white: 0.2, alpha: 0.5).cgColor
            self.layer.shadowRadius = 4
            self.layer.shadowOpacity = 0.5
            self.layer.shadowOffset = CGSize(width: 0, height: 2)
        }
        self.heightAnchor.constraint(equalToConstant: 54).isActive = true
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
    
}
