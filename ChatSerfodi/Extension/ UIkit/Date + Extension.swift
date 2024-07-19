//
//  Date + Extension.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 17.07.2024.
//

import Foundation

extension Date {
    
    func compareDay(_ other: Date) -> Bool {
        let selfComponents = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let otherComponents = Calendar.current.dateComponents([.year, .month, .day], from: other)
        return selfComponents.day == otherComponents.day
    }
    
}


