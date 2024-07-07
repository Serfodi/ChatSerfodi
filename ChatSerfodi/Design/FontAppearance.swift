//
//  FontAppearance.swift
//  SerfodiCalculator
//
//  Created by Сергей Насыбуллин on 03.04.2024.
//

import UIKit

enum FontAppearance {
        
    static let logoTitle = Font.att(size: 50, design: .logo, weight: .none)
    
    static let secondLogo = Font.att(size: 24, design: .logo, weight: .none)
    
    
    static let firstTitle = Font.att(size: 26, design: .rounded, weight: .medium)
    
    static let buttonText = Font.att(size: 20, design: .rounded, weight: .medium)
    
    static let defaultText = Font.att(size: 20, design: .rounded, weight: .regular)
    static let defaultMediumText = Font.att(size: 20, design: .rounded, weight: .medium)
    static let defaultBoldText = Font.att(size: 20, design: .rounded, weight: .bold)
    
    static let secondDefault = Font.att(size: 16, design: .rounded, weight: .regular)
    
    static let small = Font.att(size: 14, design: .regular, weight: .regular)
    
    
    
}
