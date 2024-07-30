//
//  CGPoint + Extension.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 29.07.2024.
//

import UIKit

extension CGPoint {
    
    func distance(to point2: CGPoint) -> CGFloat {
        let dx = point2.x - x
        let dy = point2.y - y
        return sqrt(dx * dx + dy * dy)
    }
}
