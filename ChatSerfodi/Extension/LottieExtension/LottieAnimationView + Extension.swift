//
//  LottieAnimationView + Extension.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 15.07.2024.
//

import Lottie

extension LottieAnimationView {
    
    convenience init(name: String, contentMode: UIView.ContentMode) {
        self.init(name: name)
        self.contentMode = contentMode
        self.loopMode = .loop
    }
}
