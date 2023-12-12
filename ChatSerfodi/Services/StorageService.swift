//
//  StorageService.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 13.12.2023.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class StorageService {
    
    static let shared = StorageService()
    
    let storageRef = Storage.storage().reference()
    
    private var avatarRef: StorageReference {
        return storageRef.child("avatars")
    }
    
    private var currentUserID: String {
        Auth.auth().currentUser!.uid
    }
    
    func upload(photo: UIImage, completion: @escaping (Result<URL, Error>)-> Void) {
        guard let scaleImage = photo.scaledToSafeUploadSize, let imageData = scaleImage.jpegData(compressionQuality: 0.4) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        avatarRef.child(currentUserID).putData(imageData, metadata: metadata) { (metadata, error) in
            guard let _ = metadata else {
                completion(.failure(error!))
                return
            }
            self.avatarRef.child(self.currentUserID).downloadURL { url, error in
                guard let downloadURL = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(downloadURL))
            }
        }
    }
    
}
