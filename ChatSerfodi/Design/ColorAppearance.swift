//
//  ColorAppearance.swift
//  SerfodiCalculator
//
//  Created by Сергей Насыбуллин on 30.03.2024.
//

import UIKit

enum ColorAppearance {
    
    static let clearWhite = SchemeColor(light: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
    static let black = SchemeColor(light: #colorLiteral(red: 0.3450980392, green: 0.3450980392, blue: 0.3450980392, alpha: 1))
    static let white = SchemeColor(light: #colorLiteral(red: 0.9882352941, green: 0.9803921569, blue: 0.9490196078, alpha: 1))
    static let blue = SchemeColor(light: #colorLiteral(red: 0.6588235294, green: 0.8196078431, blue: 0.9058823529, alpha: 1))
    
    static let headerTable = SchemeColor(light: ColorAppearance.black.color().withAlphaComponent(0.5))
    
    static let gray = SchemeColor(light: #colorLiteral(red: 0.8810922503, green: 0.8810922503, blue: 0.8810922503, alpha: 1))
    
    enum Sun {
        static let one = SchemeColor(light: #colorLiteral(red: 1, green: 0.7764705882, blue: 0, alpha: 1))
        static let two = SchemeColor(light: #colorLiteral(red: 1, green: 0.8666666667, blue: 0.5058823529, alpha: 1))
        static let three = SchemeColor(light: #colorLiteral(red: 1, green: 0.9568627451, blue: 0.8392156863, alpha: 1))
    }
    
}

