//
//  Font.swift
//  SerfodiCalculator
//
//  Created by Сергей Насыбуллин on 15.03.2024.
//

import UIKit

public struct Font {
    
    public enum Design {
        case regular
        case rounded
        case logo
        
        var key: String {
            switch self {
            case .regular:
                return "SFPro"
            case .rounded:
                return "SFProRounded"
            case .logo:
                return "TimesNewRomanPSMT"
            }
        }
    }
    
    public enum Weight {
        case light
        case regular
        case medium
        case semibold
        case bold
        case heavy
        case none
        
        var key: String {
            switch self {
            case .light:
                return "Light"
            case .regular:
                return "Regular"
            case .medium:
                return "Medium"
            case .semibold:
                return "Semibold"
            case .bold:
                return "Bold"
            case .heavy:
                return "Heavy"
            case .none:
                return ""
            }
        }
    }
    
    static func att(size: CGFloat, design: Design = .regular,  weight: Weight = .regular) -> UIFont {
        var descriptor = design.key
        if weight != .none {
            descriptor += "-" + weight.key
        }
        return UIFont(name: descriptor, size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
}

public extension NSAttributedString {
    
    convenience init(string: String, font: UIFont? = nil, textColor: UIColor? = nil) {
        var attributes: [NSAttributedString.Key: AnyObject] = [:]
        if let font = font {
            attributes[NSAttributedString.Key.font] = font
        }
        if textColor == nil {
            attributes[NSAttributedString.Key.foregroundColor] = ColorAppearance.black.color()
        } else {
            attributes[NSAttributedString.Key.foregroundColor] = textColor
        }
        self.init(string: string, attributes: attributes)
    }
    
}

extension Font {
    static func print() {
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            Swift.print("------------------------------")
            Swift.print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNames(forFamilyName: familyName )
            Swift.print("Font Names = [\(names)]")
        }
    }
}
