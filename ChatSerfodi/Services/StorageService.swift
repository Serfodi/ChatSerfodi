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
    
    private var chatsRef: StorageReference {
        return storageRef.child("chat")
    }
    
    private var currentUserId: String {
        Auth.auth().currentUser!.uid
    }
    
    private func chatRef(to: String, from: String) -> StorageReference {
        chatsRef.child(to + from)
    }
    
}

// MARK: - Image

extension StorageService {
    
    /// Загружает фото для профиля
        func upload(photo: UIImage, completion: @escaping (Result<URL, Error>)-> Void) {
            guard let scaleImage = photo.scaledToSafeUploadSize, let imageData = scaleImage.jpegData(compressionQuality: 0.4) else { return }
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            avatarRef.child(currentUserId).putData(imageData, metadata: metadata) { result in
                switch result {
                case .success(_):
                    self.avatarRef.child(self.currentUserId).downloadURL { url, error in
                        guard let downloadURL = url else {
                            completion(.failure(error!))
                            return
                        }
                        completion(.success(downloadURL))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    
    /// Upload image data in Firestorage for avatars
    public func upload(photo: UIImage) async throws -> URL {
        guard let scaleImage = photo.scaledToSafeUploadSize, let imageData = scaleImage.jpegData(compressionQuality: 0.4) else { throw ImageError.uploadImageError }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let storeMetadata = try await avatarRef.child(currentUserId).putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await avatarRef.child(self.currentUserId).downloadURL()
        return downloadURL
    }
    
    /// Upload image data in Firestorage for messages
    public func uploadImageMessage(photo: UIImage, to chat: SChat) async throws -> URL {
        guard let scaleImage = photo.scaledToSafeUploadSize, let imageData = scaleImage.jpegData(compressionQuality: 0.4) else { throw ImageError.uploadImageError }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let imageName = [UUID().uuidString, String( Date().timeIntervalSince1970) ].joined()
        let _ = try await chatRef(to: currentUserId, from: chat.friendId).child(imageName).putDataAsync(imageData, metadata: metadata)
        let url = try await chatRef(to: currentUserId, from: chat.friendId).child(imageName).downloadURL()
        return url
    }
    
    /// Delete all image in chat
    public func deleteImageMessages(to id: String, from friendId: String) async throws {
        let ref = try await chatRef(to: id, from: friendId).listAll()
        await withTaskGroup(of: Void.self, body: { taskGroup in
            ref.items.forEach { itemRef in
                taskGroup.addTask {
                    do {
                        try await itemRef.delete()
                    } catch {
                        print("Error deleteImageMessages: \(error)")
                    }
                }
            }
        })
    }
    
    public func downloadImage(url: URL, completion: @escaping (Result<UIImage?, Error>)-> Void) {
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
