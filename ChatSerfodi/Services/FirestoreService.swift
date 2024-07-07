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
    
    var currentUser: SUser!
    
    private var usersRef: CollectionReference {
        db.collection("users")
    }
    
    private var waitingChatsRef: CollectionReference {
        db.collection(["users", currentUser.id, "waitingChats"].joined(separator: "/"))
    }
    
    private var activeChatsRef: CollectionReference {
        db.collection(["users", currentUser.id, "activeChats"].joined(separator: "/"))
    }
    
    
    // MARK: Save Profile in Firebase
    
    /// Сохранения данных в бд
    func saveProfileWith(id: String,
                         email: String,
                         username: String?,
                         avatarImage: UIImage?,
                         description: String?,
                         sex: String,
                         completion: @escaping (Result<SUser, Error>) -> Void) {
        guard Validators.ifFilled(username: username, description: description, sex: sex) else {
            completion(.failure(UserError.notFilled))
            return
        }
        guard avatarImage != UIImage(systemName: "person.circle") else {
            completion(.failure(UserError.photoNotExist))
            return
        }
        
        var suser = SUser(username: username!, email: email, avatarStringURL: "Not exist", description: description!, sex: sex, id: id)
        
        StorageService.shared.upload(photo: avatarImage!) { result in
            switch result {
            case .success(let url):
                suser.avatarStringURL = url.absoluteString
                self.usersRef.document(suser.id).setData(suser.representation) { (error) in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(suser))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: Update Profile in Firebase
    
    func updateProfile(sUser: SUser,
                       username: String,
                       avatarImage: UIImage?,
                       description: String,
                       completion: @escaping (Result<SUser, Error>) -> Void) {
        
        guard Validators.ifFilled(username: username, description: description, sex: "sex") else {
            completion(.failure(UserError.notFilled))
            return
        }
        
        StorageService.shared.upload(photo: avatarImage!) { result in
            switch result {
            case .success(let url):
                self.usersRef.document(self.currentUser.id).updateData(["avatarStringURL": url.absoluteString, "username": username, "description": description]) { (error) in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(self.currentUser))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Get User Data in Firebase
    
    func getUserData(user: User, completion: @escaping (Result<SUser, Error>) -> Void) {
        let docRef = usersRef.document(user.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let suser = SUser(document: document) else {
                    completion(.failure(UserError.cannotGetUserInfo))
                    return
                }
                self.currentUser = suser
                completion(.success(suser))
            } else {
                completion(.failure(UserError.cannotGetUserInfo))
            }
        }
    }
    
    
    // MARK: - Waiting Chat
    
    func createWaitingChat(message: String, receiver: SUser, completion: @escaping (Result<Void, Error>) -> Void) {
        let reference = db.collection(["users", receiver.id, "waitingChats"].joined(separator: "/"))
        let messageRef = reference.document(self.currentUser.id).collection("messages")
        
        let message = SMessage(user: currentUser, content: message)
        
        let chat = SChat(friendUsername: currentUser.username, friendUserImageString: currentUser.avatarStringURL, lastMessage: message.content , friendId: currentUser.id)
        
        reference.document(currentUser.id).setData(chat.representation) { error in
            if let error = error {
                completion(.failure(error))
            }
            messageRef.addDocument(data: message.representation) { error in
                if let error = error {
                    completion(.failure(error))
                }
                completion(.success(Void()))
            }
        }
    }
    
    func getWaitingChatMessages(chat: SChat, completion: @escaping (Result<[SMessage], Error>) -> Void) {
        var messages = [SMessage]()
        let reference = waitingChatsRef.document(chat.friendId).collection("messages")
        reference.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            for document in querySnapshot!.documents {
                guard let message = SMessage(document: document) else { return }
                messages.append(message)
            }
            completion(.success(messages))
        }
    }
    
    
    // MARK: Delete Waiting Chat
    
    func deleteWaitingChat(chat: SChat, completion: @escaping (Result<Void, Error>) -> Void) {
        waitingChatsRef.document(chat.friendId).delete { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            self.deleteMassages(chat: chat, completion: completion)
        }
    }
        
 
    // MARK: - Active Chats
    
    func changeToActive(chat: SChat, completion: @escaping (Result<Void, Error>) -> Void) {
        getWaitingChatMessages(chat: chat) { result in
            switch result {
            case .success(let messages):
                self.deleteWaitingChat(chat: chat) { result in
                    switch result {
                    case .success():
                        self.createActiveChat(chat: chat, messages: messages) { result in
                            switch result {
                            case .success():
                                completion(.success(Void()))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    func createActiveChat(chat: SChat, messages: [SMessage], completion: @escaping (Result<Void, Error>) -> Void) {
        let messageRef = activeChatsRef.document(chat.friendId).collection("messages")
        activeChatsRef.document(chat.friendId).setData(chat.representation) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            for message in messages {
                messageRef.addDocument(data: message.representation) { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(Void()))
                }
            }
        }
    }
    
    // MARK: Delete Active Chat
    
    func deleteActiveChat(chat: SChat, completion: @escaping (Result<Void, Error>) -> Void) {
        activeChatsRef.document(chat.friendId).delete { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            self.deleteMassages(chat: chat, completion: completion)
        }
    }
    
    
    // MARK: - Delete All Massages Chat
    
    func deleteMassages(chat: SChat, completion: @escaping (Result<Void, Error>) -> Void) {
        let reference = waitingChatsRef.document(chat.friendId).collection("messages")
        
        getWaitingChatMessages(chat: chat) { result in
            switch result {
            case .success(let messages):
                for message in messages {
                    guard let documentId = message.id else { return }
                    let messageRef = reference.document(documentId)
                    messageRef.delete { error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        completion(.success(Void()))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: Send Message
    
    func sendMessage(chat: SChat, message: SMessage, completion: @escaping (Result<Void, Error>) -> Void) {
        let friendRef = usersRef.document(chat.friendId).collection("activeChats").document(currentUser.id)
        let friendMessageRef = friendRef.collection ("messages")
        let myMessageRef = usersRef.document(currentUser.id).collection("activeChats").document(chat.friendId).collection ("messages")
        
        let chatForFriend = SChat(friendUsername: currentUser.username,
                                  friendUserImageString: currentUser.avatarStringURL,
                                  lastMessage: currentUser.description,
                                  friendId: currentUser.id)
        
        friendRef.setData(chatForFriend.representation) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            friendMessageRef.addDocument(data: message.representation) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                myMessageRef.addDocument(data: message.representation) { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(Void()))
                }
            }
        }
    }
    
    
}
