//
//  SchemeColor.swift
//  SerfodiCalculator
//
//  Created by Сергей Насыбуллин on 30.03.2024.
//


import UIKit

struct SchemeColor {
    
    let light: UIColor
    let dark: UIColor
    
    init(light: UIColor, dark: UIColor) {
        self.light = light
        self.dark = dark
    }
    
    init(light: UIColor) {
        self.light = light
        self.dark = light
    }
    
    func color() -> UIColor {
        UIColor { trainCollection in
            switch trainCollection.userInterfaceStyle {
            case .unspecified, .light:
                return light
            default:
                return dark
            }
        }
    }
}
