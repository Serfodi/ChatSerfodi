//
//  CGSize + Extension.swift
//  SerfodiCalculator
//
//  Created by Сергей Насыбуллин on 27.01.2024.
//

import Foundation

public extension CGSize {
    
    static func + (size: CGSize, summand: CGFloat) -> CGSize {
        return CGSize(width: size.width + summand, height: size.height + summand)
    }
    
    static func * (size: CGSize, multiplier: CGFloat) -> CGSize {
        return CGSize(width: size.width * multiplier, height: size.height * multiplier)
    }
    
    static func <= (left: CGSize, right: CGSize) -> Bool {
        return left.width <= right.width && left.height <= right.height
    }
    
    static func > (left: CGSize, right: CGSize) -> Bool {
        return left.width > right.width && left.height > right.height
    }
    
}

public extension CGSize {
    
    func centered(in rect: CGRect) -> CGRect {
        return CGRect(origin: CGPoint(x: rect.minX + floor((rect.width - self.width) / 2.0), y: rect.minY + floor((rect.height - self.height) / 2.0)), size: self)
    }
    
    func rightCentered(in rect: CGRect) -> CGRect {
            return CGRect(origin: CGPoint(x: rect.maxX - self.width, y: rect.minY + floor((rect.height - self.height) / 2.0)), size: self)
        }
    
}

