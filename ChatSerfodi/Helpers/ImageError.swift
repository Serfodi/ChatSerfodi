//
//  ImageError.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 24.07.2024.
//

import Foundation


enum ImageError {
    case uploadImageError
}

extension ImageError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .uploadImageError:
            return NSLocalizedString("uploadImageError", comment: "")
        }
    }
    
}
