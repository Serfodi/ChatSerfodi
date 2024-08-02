//
//  AuthError.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 03.12.2023.
//

import Foundation

enum AuthError {
    case notFilled
    case invaluableEmail
    case passwordNotMatched
    case unownedError
    case serverError
    case googleError
}

extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .notFilled:
            return NSLocalizedString("Заполните все поля", comment: "")
        case .invaluableEmail:
            return NSLocalizedString("Формат почты не является допустимым", comment: "")
        case .passwordNotMatched:
            return NSLocalizedString("Пароли не совпадают", comment: "")
        case .unownedError:
            return NSLocalizedString("Неизвестная ошибка", comment: "")
        case .serverError:
            return NSLocalizedString("Ошибка сервера", comment: "")
        case .googleError:
            return NSLocalizedString("GoogleError", comment: "")
        }
    }
    
}
