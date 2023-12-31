//
//  AuthService.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 03.12.2023.
//

import UIKit
import FirebaseAuth
import FirebaseCore

class AuthService {
    
    static let shared = AuthService()
    
    private let auth = Auth.auth()
    
    
    func login(email: String?, password: String?, completion: @escaping (Result<User, Error>) -> Void)  {
        
        guard let email = email, let password = password else {
            completion(.failure(AuthError.notFilled))
            return
        }
        
        auth.signIn(withEmail: email, password: password) { (result, error) in
            guard let result = result else {
                completion(.failure(error!))
                return
            }
            completion(.success(result.user))
        }
    }
    
    func register(email: String?, password: String?, confirmPassword: String?, completion: @escaping (Result<User, Error>) -> Void) {
        auth.createUser(withEmail: email!, password: password!) { (result, error) in
            
            guard Validators.validatorsEmail(email: email, password: password, confirmPassword: confirmPassword) else {
                completion(.failure(AuthError.notFilled))
                return
            }
            
            guard password!.lowercased() == confirmPassword!.lowercased() else {
                completion(.failure(AuthError.passwordNotMatched))
                return
            }
            
            guard Validators.isSimpleEmail(email!) else {
                completion(.failure(AuthError.invaluableEmail))
                return
            }
            
            guard let result = result else {
                completion(.failure(error!))
                return
            }
            completion(.success(result.user))
        }
    }
    
}


