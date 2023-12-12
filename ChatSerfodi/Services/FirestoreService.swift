//
//  FirestoreService.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 03.12.2023.
//

import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class FirestoreService {
    
    static let shared = FirestoreService()
    
    let db = Firestore.firestore()
    
    private var usersRef: CollectionReference {
        return db.collection("users")
    }
    
    /// Сохранения данных в бд
    func saveProfileWith(id: String, email: String, username: String?, avatarImageString: String?, description: String?, sex: String, completion: @escaping (Result<SUser, Error>) -> Void) {
        
        guard Validators.ifFilled(username: username, description: description, sex: sex) else {
            completion(.failure(UserError.notFilled))
            return
        }
        
        let suser = SUser(username: username!, email: email, avatarStringURL: "Not exist", description: description!, sex: sex, id: id)
        
        self.usersRef.document(suser.id).setData(suser.representation) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(suser))
            }
        }
    }
    
    
    func getUserData(user: User, completion: @escaping (Result<SUser, Error>) -> Void) {
        let docRef = usersRef.document(user.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let suser = SUser(document: document) else {
                    completion(.failure(UserError.cannotGetUserInfo))
                    return
                }
                completion(.success(suser))
            } else {
                completion(.failure(UserError.cannotGetUserInfo))
            }
        }
    }
    
    
    
    
}
