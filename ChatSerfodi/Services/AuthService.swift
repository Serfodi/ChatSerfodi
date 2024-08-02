//
//  AuthService.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 03.12.2023.
//

import UIKit
import FirebaseCore
import GoogleSignIn
import FirebaseAuth

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
    
    func googleLogin(user: GIDGoogleUser!, error: Error!, completion: @escaping (Result<User, Error>) -> Void) {
        if let error = error {
            completion(.failure(error))
            return
        }
        guard let user = user, let idToken = user.idToken?.tokenString else { return }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
        
        auth.signIn(with: credential) { result, error in
            guard let result = result else {
                completion(.failure(error!))
                return
            }
            completion(.success(result.user))
        }
    }
    
    func googleLogin(user: GIDGoogleUser) async throws -> User {
        guard let idToken = user.idToken?.tokenString else { throw AuthError.googleError }
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
        let result = try await auth.signIn(with: credential)
        return result.user
    }
    
    
    func register(email: String?, password: String?, confirmPassword: String?, completion: @escaping (Result<User, Error>) -> Void) {
        // Создания нового акаунта.
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


