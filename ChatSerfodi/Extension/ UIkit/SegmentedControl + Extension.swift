//
//  SegmentedControl + Extension.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 08.11.2023.
//

import UIKit

extension UISegmentedControl {
    
    convenience init(first: String, second: String) {
        self.init()
        self.insertSegment(withTitle: NSLocalizedString(first, comment: ""), at: 0, animated: true)
        self.insertSegment(withTitle: NSLocalizedString(second, comment: ""), at: 1, animated: true)
        self.selectedSegmentIndex = 0
    }
    
}
