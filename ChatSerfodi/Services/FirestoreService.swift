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
    
    public func saveProfileWith(id: String,
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
        
        var suser = SUser(username: username!, email: email, avatarStringURL: "Not exist", description: description!, sex: sex, id: id, isHide: false, entryTime: Date(), isOnline: true)
        
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
    
    public func updateProfile(username: String,
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
                        self.currentUser = SUser(username: username,
                                            email: self.currentUser.email,
                                            avatarStringURL: url.absoluteString,
                                            description: description,
                                            sex: self.currentUser.sex,
                                            id: self.currentUser.id,
                                            isHide: self.currentUser.isHide,
                                            entryTime: self.currentUser.exitTime,
                                            isOnline: self.currentUser.isOnline)
                        completion(.success(self.currentUser))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Обновляет дату входа текущего пользователя
    public func updateEntryTime(date: Date = Date()) {
        guard let currentUser = currentUser else { return }
        let currentSUser = usersRef.document(currentUser.id)
        currentSUser.updateData([SUser.repreExitTime : date]) { error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    public func updateIsOnline(is online: Bool) {
        guard let currentUser = currentUser else { return }
        let user = usersRef.document(currentUser.id)
        
        user.updateData([SUser.repreIsOnline : online]) { error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
            
            self.activeChatsRef.getDocuments { querySnapshot, error in
                guard let querySnapshot = querySnapshot else {
                    return
                }
                querySnapshot.documents.forEach { doc in
                    guard let chat = SChat(document: doc) else { return }
                    let friend = self.usersRef.document(chat.friendId).collection("activeChats").document(currentUser.id)
                    friend.updateData([SUser.repreIsOnline : online])
                }
            }
            
        }
    }
    
    // MARK: Get User Data in Firebase
    
    /// - Warning: Присваивает `currentUser`
    public func getUserData(user: User, completion: @escaping (Result<SUser, Error>) -> Void) {
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
    
    public func getUserData(userId: String, completion: @escaping (Result<SUser, Error>) -> Void) {
        let docRef = usersRef.document(userId)
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
    
//    public func hideUser(userId: String, is hide: Bool = true, completion: @escaping (Error?) -> Void) {
//        let friendRef = usersRef.document(userId)
//        friendRef.updateData(["isHide": hide]) { error in
//            if let error = error {
//                completion(error)
//            }
//        }
//    }
    
    // MARK: - Waiting Chat
    
    public func createWaitingChat(message: String, receiver: SUser, completion: @escaping (Result<Void, Error>) -> Void) {
//        let friendRef = usersRef.document(receiver.id)
        let referenceFrom = db.collection(["users", receiver.id, "waitingChats"].joined(separator: "/"))
        let messageRef = referenceFrom.document(self.currentUser.id).collection("messages")
        
        let message = SMessage(user: currentUser, content: message)
        let chat = SChat(friendUsername: currentUser.username, friendUserImageString: currentUser.avatarStringURL, lastMessage: message.content , friendId: currentUser.id, lastDate: Date(), isOnline: currentUser.isOnline)
        
        referenceFrom.document(currentUser.id).setData(chat.representation) { error in
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
    
    private func getWaitingChatMessages(chat: SChat, completion: @escaping (Result<[SMessage], Error>) -> Void) {
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
    
    
    
    // MARK: - Delete Waiting Chat
    
    public func deleteWaitingChat(chat: SChat, completion: @escaping (Result<Void, Error>) -> Void) {
        waitingChatsRef.document(chat.friendId).delete { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            self.deleteWaitingMessage(chat: chat, completion: completion)
        }
    }
    
    /// Delete First message in WaitingChat
    private func deleteWaitingMessage(chat: SChat, completion: @escaping (Result<Void, Error>) -> Void) {
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
 
    
    
    // MARK: - Active Chats
    
    /// Изменят чат из чата ожидающего в активный чат
    public func changeToActive(chat: SChat, completion: @escaping (Result<Void, Error>) -> Void) {
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
    
    /// Создает активный чат
    private func createActiveChat(chat: SChat, messages: [SMessage], completion: @escaping (Result<Void, Error>) -> Void) {
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
    
    /// Delete Active Chat
    public func deleteActiveChat(chat: SChat, completion: @escaping (Result<Void, Error>) -> Void) {
        
        activeChatsRef.document(chat.friendId).delete { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            self.deleteActiveMessage(chat: chat, completion: completion)
        }
    }
    
    ///  Удаляет все сообщения из бд
    private func deleteActiveMessage(chat: SChat, completion: @escaping (Result<Void, Error>) -> Void) {
        let reference = activeChatsRef.document(chat.friendId).collection("messages")
        getActiveChatMessages(chat: chat) { result in
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
                        if message.downloadURL != nil {
                            StorageService.shared.deleteImageMessage(chat: chat, message: message) { result in
                                switch result {
                                case .success():
                                    completion(.success(Void()))
                                case .failure(let error):
                                    completion(.failure(error))
                                }
                            }
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Получает все сообщения из бд
    private func getActiveChatMessages(chat: SChat, completion: @escaping (Result<[SMessage], Error>) -> Void) {
        var messages = [SMessage]()
        let reference = activeChatsRef.document(chat.friendId).collection("messages")
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
    
    
    // MARK: - Send Message
    
    public func sendMessage(chat: SChat, message: SMessage, completion: @escaping (Result<Void, Error>) -> Void) {
        let friendRef = usersRef.document(chat.friendId).collection("activeChats").document(currentUser.id)
        let friendMessageRef = friendRef.collection ("messages")
        let myMessageRef = usersRef.document(currentUser.id).collection("activeChats").document(chat.friendId).collection ("messages")
        
        let chatForFriend = SChat(friendUsername: currentUser.username,
                                  friendUserImageString: currentUser.avatarStringURL,
                                  lastMessage: message.descriptor,
                                  friendId: currentUser.id, lastDate: Date(), isOnline: currentUser.isOnline)
        
        let chatForMe = SChat(friendUsername: chat.friendUsername,
                              friendUserImageString: chat.friendUserImageString,
                              lastMessage: message.descriptor,
                              friendId: chat.friendId, lastDate: Date(), isOnline: chat.isOnline)
        
        
        friendRef.setData(chatForFriend.representation) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            myMessageRef.parent?.setData(chatForMe.representation) { error in
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
    
    /// Удаляет сообщение
    public func deleteMessage(chat: SChat, message: SMessage, completion: @escaping (Result<Void, Error>) -> Void) {
        let friendRef = usersRef.document(chat.friendId).collection("activeChats").document(currentUser.id)
        let friendMessageRef = friendRef.collection("messages")
        let myMessageRef = usersRef.document(currentUser.id).collection("activeChats").document(chat.friendId).collection ("messages")
        
        friendMessageRef.document(message.messageId).delete { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            myMessageRef.document(message.messageId).delete { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
            }
            completion(.success(Void()))
        }
    }
    
    
    
}
