//
//  String + localized.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 18.09.2024.
//

import Foundation

extension String {
    
    func localized() -> String {
        return NSLocalizedString(self, comment: self)
    }
}
