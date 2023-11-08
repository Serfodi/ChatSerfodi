//
//  Label + Extension.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 21.10.2023.
//

import UIKit

extension UILabel {
    
    convenience init(text: String, fount: UIFont? = .avenir20()) {
        self .init()
        
        self.font = fount
        self.text = text
    }
    
}
