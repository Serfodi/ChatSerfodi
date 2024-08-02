//
//  BirdView.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 03.07.2024.
//

import UIKit
import Lottie
import TinyConstraints

final class BirdView: UIView {
    
    private var birdAnimationView: LottieAnimationView! = {
        let duckView = LottieAnimationView(name: "Bird")
        duckView.loopMode = .loop
        duckView.contentMode = .scaleAspectFill
        return duckView
    }()
    
    private var sunView = SunView()
    
    // MARK: init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configuration()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configuration()
    }
    
    public func play() {
        birdAnimationView.play()
    }
    
    private func configuration() {
        self.clipsToBounds = true
        layout()
    }
    
    private func layout() {
        aspectRatio(1)
        
        addSubview(birdAnimationView)
        birdAnimationView.topToSuperview()
        birdAnimationView.leftToSuperview()
        birdAnimationView.rightToSuperview(offset: 35)
        birdAnimationView.bottomToSuperview()
        
        birdAnimationView.insertSubview(sunView, at: 0)
        sunView.centerInSuperview()
        sunView.aspectRatio(1)
        sunView.heightToSuperview(multiplier: 0.9)
    }
}

