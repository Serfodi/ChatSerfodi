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
    
    private var chatRef: StorageReference {
        return storageRef.child("chat")
    }
    
    private var currentUserID: String {
        Auth.auth().currentUser!.uid
    }
    
    
    
    /// Загружает фото для профиля
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
    
    /// Загружает фото для чата
    func uploadImageMessage(photo: UIImage, to chat: SChat, completion: @escaping (Result<URL, Error>)-> Void) {
        guard let scaleImage = photo.scaledToSafeUploadSize, let imageData = scaleImage.jpegData(compressionQuality: 0.4) else { return }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let imageName = [UUID().uuidString, String( Date().timeIntervalSince1970) ].joined()
        let chatName = [Auth.auth().currentUser!.uid, chat.friendId].joined()
        
        self.chatRef.child(chatName).child(imageName).putData(imageData, metadata: metadata) { metadata, error in
            guard let _ = metadata else {
                completion(.failure(error!))
                return
            }
            self.chatRef.child(chatName).child(imageName).downloadURL { url, error in
                guard let downloadURL = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(downloadURL))
            }
        }
    }
    
    private func deleteAllImageChat(chat: SChat, completion: @escaping (Result<Void, Error>)-> Void) {
        let chatName = [Auth.auth().currentUser!.uid, chat.friendId].joined()
        self.chatRef.child(chatName).delete { error in
            guard let error = error else {
                completion(.failure(error!))
                return
            }
            completion(.success(Void()))
        }
    }
    
    public func deleteImageMessage(chat: SChat, message: SMessage, completion: @escaping (Result<Void, Error>)-> Void) {
        let chatName = [Auth.auth().currentUser!.uid, chat.friendId].joined()
        let imageName = [ chat.friendId, String(message.sentDate.timeIntervalSince1970)].joined()
        self.chatRef.child(chatName).child(imageName).delete { error in
            guard let error = error else {
                completion(.failure(error!))
                return
            }
            completion(.success(Void()))
        }
    }
    
    
    func downloadImage(url: URL, completion: @escaping (Result<UIImage?, Error>)-> Void) {
        let ref = Storage.storage().reference(forURL: url.absoluteString)
        let megoByte = Int64(1 * 1024 * 1024)
        ref.getData(maxSize: megoByte) { data, error in
            guard let imageData = data else {
                completion(.failure(error!))
                return
            }
            completion(.success(UIImage(data: imageData)))
        }
    }
}
