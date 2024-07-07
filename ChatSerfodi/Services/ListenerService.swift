//
//  ListenerService.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 13.12.2023.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class ListenerService {
    
    static let shared = ListenerService()
    
    private let db = Firestore.firestore()
    
    private var userRef: CollectionReference {
        db.collection("users")
    }
    
    private var currentUserId: String {
        Auth.auth().currentUser!.uid
    }
    
    func usersObserve(users: [SUser], completion: @escaping (Result<[SUser], Error>)-> Void) -> ListenerRegistration? {
        var users = users
        let userListener = userRef.addSnapshotListener { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            querySnapshot.documentChanges.forEach { (diff) in
                guard let user = SUser(document: diff.document) else { return }
                switch diff.type {
                case .added:
                    guard !users.contains(user) else { return }
                    guard user.id != self.currentUserId else { return }
                    users.append(user)
                case .modified:
                    guard let index = users.firstIndex(of: user) else { return }
                    users[index] = user
                case .removed:
                    guard let index = users.firstIndex(of: user) else { return }
                    users.remove(at: index)
                }
            }
            completion(.success(users))
        }
        return userListener
    }
    
    
    func waitingChatObserve(chats: [SChat], completion: @escaping (Result<[SChat], Error>)-> Void) -> ListenerRegistration? {
        var chats = chats
        let chatsRef = db.collection(["users", currentUserId, "waitingChats"].joined(separator: "/"))
        let chatsListener = chatsRef.addSnapshotListener { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            querySnapshot.documentChanges.forEach { (diff) in
                guard let chat = SChat(document: diff.document) else { return }
                switch diff.type {
                case .added:
                    guard !chats.contains(chat) else { return }
                    chats.append(chat)
                case .modified:
                    guard let index = chats.firstIndex(of: chat) else { return }
                    chats[index] = chat
                case .removed:
                    guard let index = chats.firstIndex(of: chat) else { return }
                    chats.remove(at: index)
                }
            }
            completion(.success(chats))
        }
        return chatsListener
    }
    
    
    func activityChatObserve(chats: [SChat], completion: @escaping (Result<[SChat], Error>)-> Void) -> ListenerRegistration? {
        var chats = chats
        let chatsRef = db.collection(["users", currentUserId, "activeChats"].joined(separator: "/"))
        let chatsListener = chatsRef.addSnapshotListener { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            querySnapshot.documentChanges.forEach { (diff) in
                guard let chat = SChat(document: diff.document) else { return }
                switch diff.type {
                case .added:
                    guard !chats.contains(chat) else { return }
                    chats.append(chat)
                case .modified:
                    guard let index = chats.firstIndex(of: chat) else { return }
                    chats[index] = chat
                case .removed:
                    guard let index = chats.firstIndex(of: chat) else { return }
                    chats.remove(at: index)
                }
            }
            completion(.success(chats))
        }
        return chatsListener
    }
    
    
    // Наблюдатель для сообщений
    
    func messagesObserve(chat: SChat, completion: @escaping (Result<SMessage, Error>) -> Void) -> ListenerRegistration? {
        let ref = userRef.document(currentUserId).collection("activeChats").document(chat.friendId).collection("messages")
        let messagesListener = ref.addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                completion(.failure(error!))
                return
            }
            snapshot.documentChanges.forEach { diff in
                guard let message = SMessage(document: diff.document) else { return }
                switch diff.type {
                case .added:
                    completion(.success(message))
                case .modified:
                    break
                case .removed:
                    break
                }
            }
        }
        return messagesListener
    }
    
    
}
