//
//  Validators.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 03.12.2023.
//

import Foundation

class Validators {
    
    static func validatorsEmail(email: String?, password: String?, confirmPassword: String?) -> Bool {
        guard let password = password,
              let confirmPassword = confirmPassword,
              let email = email,
              password != "",
              confirmPassword != "",
              email != "" else { return false }
        return true
    }
    
    static func ifFilled(username: String?, description: String?) -> Bool {
        guard let username = username,
              let description = description,
              username != "",
              description != "" else { return false }
        return true
    }
    
    
    static func isSimpleEmail(_ email: String) -> Bool {
        /*
        let emailRegEx = "^.+0.+\\..{2, }$"
        return check(text: email, regEx: emailRegEx)
         */
        true
    }
    
    private static func check(text: String, regEx: String) -> Bool {
        /*
        let predicate = NSPredicate(format: "SELF MATCHES %@", regEx)
        return predicate.evaluate(with: text)
         */
        true
    }
    
    
    
    
}
