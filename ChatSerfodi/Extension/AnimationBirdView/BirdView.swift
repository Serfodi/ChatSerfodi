//
//  BirdView.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 03.07.2024.
//

import UIKit
import Lottie

class BirdView: UIView {
    
    var sunView = SunView()
    
    var birdView: LottieAnimationView! = {
        let duckView = LottieAnimationView(name: "Bird")
        duckView.loopMode = .loop
        duckView.contentMode = .scaleAspectFill
        return duckView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension BirdView {
    
    func layout() {
        sunView.translatesAutoresizingMaskIntoConstraints = false
        birdView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            birdView.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor),
            birdView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 35),
        ])
        let aspectRatioConstraint = NSLayoutConstraint(item: birdView!, attribute: .width, relatedBy: .equal, toItem: birdView!, attribute: .height, multiplier: 1.0, constant: 0)
        birdView.addConstraint(aspectRatioConstraint)
        
    }
    
}
