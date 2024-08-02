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
    
    func formateDate() -> String {
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current
        let componentsDifference = calendar.dateComponents([.year, .month, .day, .hour], from: self, to: Date())
        
        if componentsDifference.year! > 0 {
            dateFormatter.dateFormat = "d MMM yyyy"
            return dateFormatter.string(from: self)
        } else if componentsDifference.day! > 0 {
            dateFormatter.dateFormat = "d MMM"
            return dateFormatter.string(from: self)
        } else {
            if !self.compareDay(Date()) {
                return NSLocalizedString("yesterday", comment: "")
            }
            return NSLocalizedString("today", comment: "")
        }
    }
    
    func representationDate(sex: SUser.Sex) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self, to: Date())
        
        if components.day! > 1 {
            return NSLocalizedString("long ago", comment: "")
        } else if components.day! > 0 {
            return NSLocalizedString("yesterday", comment: "")
        } else if components.hour! > 0 {
            if !self.compareDay(Date()) {
                return NSLocalizedString("yesterday", comment: "")
            }
            return NSLocalizedString("today", comment: "")
        } else {
            return NSLocalizedString("recently", comment: "")
        }
    }
    
}

extension SUser.Sex {
    
    func representationData() -> String {
        switch self {
        case .man:
            return NSLocalizedString("was", comment: "")
        case .wom:
            return NSLocalizedString("wasW", comment: "")
        }
    }
    
}

