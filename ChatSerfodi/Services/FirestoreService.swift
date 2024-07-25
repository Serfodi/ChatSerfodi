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
    
    var usersRef: CollectionReference {
        db.collection("users")
    }
    
    var waitingChatsRef: CollectionReference {
        waitingChatsRef(id: currentUser.id)
    }

    var activeChatsRef: CollectionReference {
        activeChatsRef(id: currentUser.id)
    }
    
    func activeChatsRef(id: String) -> CollectionReference {
        db.collection(["users", id, "activeChats"].joined(separator: "/"))
    }
    
    func waitingChatsRef(id: String) -> CollectionReference {
        db.collection(["users", id, "waitingChats"].joined(separator: "/"))
    }
    
    func activeChatMessagesRef(to id: String, from friendId: String) -> CollectionReference {
        db.collection(["users", id, "activeChats", friendId, "messages"].joined(separator: "/"))
    }
    
    func waitingChatMessagesRef(to id: String, from friendId: String) -> CollectionReference {
        db.collection(["users", id, "waitingChats", friendId, "messages"].joined(separator: "/"))
    }
}


// MARK: - User
extension FirestoreService {
    
    // MARK: Save Profile in Firebase
    
    public func saveProfileWith(id: String,
                                email: String,
                                username: String?,
                                avatarImage: UIImage?,
                                description: String?,
                                sex: String) async throws -> SUser {
        
        guard Validators.ifFilled(username: username, description: description, sex: sex) else { throw UserError.notFilled }
        guard avatarImage != UIImage(systemName: "person.circle") else { throw UserError.photoNotExist }
        
        var suser = SUser(username: username!,
                          email: email,
                          avatarStringURL: "Not exist",
                          description: description!,
                          sex: sex,
                          id: id,
                          isHide: false,
                          entryTime: Date(),
                          isOnline: true)
        
        
        Task(priority: .low) {
            let url = try await StorageService.shared.upload(photo: avatarImage!)
            try await usersRef.document(id).updateData(["avatarStringURL" : url])
        }
        
        try await usersRef.document(suser.id).setData(suser.representation)
        
        return suser
    }
    
    // MARK: Update Profile in Firebase
    
    public func updateProfile(username: String,
                              avatarImage: UIImage?,
                              description: String) throws {
        guard Validators.ifFilled(username: username, description: description, sex: "sex") else { throw UserError.notFilled }
        guard let avatarImage = avatarImage else { throw UserError.photoNotExist }
        Task(priority: .low) {
            let url = try await StorageService.shared.upload(photo: avatarImage)
            try await usersRef.document(currentUser.id).updateData(["avatarStringURL": url.absoluteString, "username": username, "description": description])
            currentUser.avatarStringURL = url.absoluteString
        }
        currentUser.username = username
        currentUser.description = description
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
        Task(priority: .low) {
            do {
                try await user.updateData([SUser.repreIsOnline : online])
                let querySnapshot = try await activeChatsRef.getDocuments()
                await withTaskGroup(of: Void.self, body: { taskGroup in
                    querySnapshot.documents.forEach { doc in
                        taskGroup.addTask {
                            do {
                                guard let chat = SChat(document: doc) else { return }
                                let ref = self.activeChatsRef(id: chat.friendId).document(currentUser.id)
                                try await ref.updateData([SUser.repreIsOnline : online])
                            } catch {
                                print("Error updateIsOnline: \(error)")
                            }
                        }
                    }
                })
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    /// - Warning: Присваивает `currentUser`
    public func getUserData(user: User) async throws -> SUser {
        let userDocRef = usersRef.document(user.uid)
        let document = try await userDocRef.getDocument()
        guard document.exists, let sUser = SUser(document: document) else {
            throw UserError.cannotGetUserInfo
        }
        self.currentUser = sUser
        return sUser
    }
        
    public func getUserData(id: String) async throws -> SUser {
        let userDocRef = usersRef.document(id)
        let document = try await userDocRef.getDocument()
        guard document.exists, let sUser = SUser(document: document) else {
            throw UserError.cannotGetUserInfo
        }
        return sUser
    }
    
}


// MARK: - Waiting Chat
extension FirestoreService {
    
    public func createWaitingChat(receiver: SUser, message: String) throws {
        let receiverWaitingChatsRef = waitingChatsRef(id: receiver.id)
        let receiverWaitingChatMessagesRef = waitingChatMessagesRef(to: receiver.id, from: currentUser.id)
        
        let message = SMessage(user: currentUser, content: message)
        let chat = SChat(friendUsername: currentUser.username, friendUserImageString: currentUser.avatarStringURL, lastMessage: message.content , friendId: currentUser.id, lastDate: Date(), isOnline: currentUser.isOnline, typing: "nil")
        
        Task(priority: .userInitiated) {
            do {
                try await receiverWaitingChatsRef.document(currentUser.id).setData(chat.representation)
                try await receiverWaitingChatMessagesRef.addDocument(data: message.representation)
            }
        }
    }
    
    public func deleteWaitingChat(chat: SChat) throws {
        Task(priority: .userInitiated) {
            do {
                try await deleteWaitingChat(chat: chat)
            }
        }
    }
    
    private func deleteWaitingChat(chat: SChat) async throws {
        async let deleteWaitingChatMessages: () =  try deleteWaitingChatMessages(chat: chat)
        async let deleteWaitingChat: () = try waitingChatsRef.document(chat.friendId).delete()
        let _ = try await [deleteWaitingChatMessages, deleteWaitingChat]
    }
}


// MARK: - Active Chats
extension FirestoreService {
    
    public func changeToActive(chat: SChat) async throws {
        let waitingChatMessages = try await getWaitingChatMessages(chat: chat)
        try await deleteWaitingChat(chat: chat)
        
        let forFriendChat = SChat(friendUsername: currentUser.username,
                                  friendUserImageString: currentUser.avatarStringURL,
                                  lastMessage: chat.lastMessage,
                                  friendId: currentUser.id,
                                  lastDate: Date(),
                                  isOnline: currentUser.isOnline,
                                  typing: "nil")
        
        async let meChat: Void = try createActiveChat(to: currentUser.id, from: chat.friendId, chat: chat, messages: waitingChatMessages)
        async let friendChat: Void = try createActiveChat(to: chat.friendId, from: currentUser.id, chat: forFriendChat, messages: waitingChatMessages)
        let _ = try await [meChat, friendChat]
    }
    
    private func createActiveChat(to id: String, from friendId: String, chat: SChat, messages: [SMessage]) async throws {
        let meActiveChatRef = activeChatsRef(id: id).document(friendId)
        let meMessagesActiveChatRef = activeChatMessagesRef(to: id, from: friendId)
        try await meActiveChatRef.setData(chat.representation)
        await withTaskGroup(of: Void.self, body: { taskGroup in
            messages.forEach { message in
                taskGroup.addTask {
                    do {
                        try await meMessagesActiveChatRef.addDocument(data: message.representation)
                    } catch {
                        print("Error createActiveChat addDocument: \(error)")
                    }
                }
            }
        })
    }
    
    public func deleteActiveChat(chat: SChat) throws {
        Task(priority: .userInitiated) {
            do {
                async let deleteMeChat: Void = try activeChatsRef(id: currentUser.id).document(chat.friendId).delete()
                async let deleteFriendChat: Void = try activeChatsRef(id: chat.friendId).document(currentUser.id).delete()
                let _ = try await [deleteMeChat, deleteFriendChat]
            }
        }
        Task(priority: .background) {
            do {
                async let deleteMeMessages: () = try deleteActiveChatMessages(to: currentUser.id, from: chat.friendId)
                async let deleteFriendMessages: () = try deleteActiveChatMessages(to: chat.friendId, from: currentUser.id)
                async let deleteMePhoto: () = try StorageService.shared.deleteImageMessages(to: currentUser.id, from: chat.friendId)
                async let deleteFriendPhoto: () = try StorageService.shared.deleteImageMessages(to: chat.friendId, from: currentUser.id)
                let _ = try await [deleteMePhoto, deleteFriendPhoto, deleteMeMessages, deleteFriendMessages]
            }
        }
    }
    
    public func updateChatTyping(for chat: SChat, typing: String) {
        let friendActiveChatRef = activeChatsRef(id: chat.friendId).document(currentUser.id)
        Task(priority: .userInitiated) {
            do {
                try await friendActiveChatRef.updateData(["typing" : typing])
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}


// MARK: - Messages
extension FirestoreService {
    
    /// Func sending and write data message from Firestore
    /// Update chat for me and friend
    public func sendMessage(from chat: SChat, message: SMessage) throws {
        let forFriendChat = SChat(friendUsername: currentUser.username,
                                  friendUserImageString: currentUser.avatarStringURL,
                                  lastMessage: message.descriptor,
                                  friendId: currentUser.id,
                                  lastDate: Date(),
                                  isOnline: currentUser.isOnline,
                                  typing: "nil")
        let forMeChat = SChat(friendUsername: chat.friendUsername,
                              friendUserImageString: chat.friendUserImageString,
                              lastMessage: message.descriptor,
                              friendId: chat.friendId,
                              lastDate: Date(),
                              isOnline: chat.isOnline,
                              typing: chat.typing)
        
        let friendDocRef = activeChatsRef(id: chat.friendId).document(currentUser.id)
        let friendMessagesRef = activeChatMessagesRef(to: chat.friendId, from: currentUser.id)
        let meMessagesRef =  activeChatMessagesRef(to: currentUser.id, from: chat.friendId)
        
        Task(priority: .userInitiated) {
            do {
                async let taskMe1: Void? = try meMessagesRef.parent?.setData(forMeChat.representation)
                async let taskFriend1: Void = try friendDocRef.setData(forFriendChat.representation)
                let _ = try await [taskMe1, taskFriend1]
                async let taskFriend2 = try friendMessagesRef.addDocument(data: message.representation)
                async let taskMe2 = try meMessagesRef.addDocument(data: message.representation)
                let _ = try await [taskFriend2, taskMe2]
            }
        }
    }
    
    private func getWaitingChatMessages(chat: SChat) async throws -> [SMessage] {
        let messagesWaitingChatRef = waitingChatMessagesRef(to: currentUser.id, from: chat.friendId)
        let querySnapshot = try await messagesWaitingChatRef.getDocuments()
        return querySnapshot.documents.compactMap { SMessage(document: $0) }
    }
    
    private func deleteActiveChatMessages(to id: String, from friendId: String) async throws {
        let messagesActiveChatRef = activeChatMessagesRef(to: id, from: friendId)
        let querySnapshot = try await messagesActiveChatRef.getDocuments()
        await withTaskGroup(of: Void.self, body: { taskGroup in
            querySnapshot.documents.forEach { queryDocumentSnapshot in
                taskGroup.addTask {
                    do {
                        try await queryDocumentSnapshot.reference.delete()
                    } catch {
                        print("Error getActiveChatMessages delete: \(error)")
                    }
                }
            }
        })
    }
    
    private func deleteWaitingChatMessages(chat: SChat) async throws {
        let messagesWaitingChatRef = waitingChatMessagesRef(to: currentUser.id, from: chat.friendId)
        let messages = try await getWaitingChatMessages(chat: chat)
        await withTaskGroup(of: Void.self, body: { taskGroup in
            messages.forEach { message in
                taskGroup.addTask {
                    do {
                        guard let documentId = message.id else { return }
                        let messageRef = messagesWaitingChatRef.document(documentId)
                        try await messageRef.delete()
                    } catch {
                        print("Error deleteWaitingChatMessages messageRef.delete: \(error)")
                    }
                }
            }
        })
    }
}
