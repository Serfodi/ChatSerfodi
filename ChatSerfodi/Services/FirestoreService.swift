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
                                sex: Int) async throws -> SUser {
        guard Validators.ifFilled(username: username, description: description) else { throw UserError.notFilled }
        guard avatarImage != UIImage(imageLiteralResourceName: "image_message_placeholder") else { throw UserError.photoNotExist }
        var suser = SUser(username: username!,
                          email: email,
                          avatarStringURL: "Not exist",
                          description: description!,
                          sex: sex,
                          id: id,
                          isHide: false,
                          entryTime: Date(),
                          isOnline: true,
                          blocked: [],
                          activeChats: [])
        let url = try await StorageService.shared.upload(photo: avatarImage!)
        suser.avatarStringURL = url.absoluteString
        try await usersRef.document(suser.id).setData(suser.representation)
        self.currentUser = suser
        return suser
    }
    
    // MARK: Update Profile in Firebase
    
    public func updateProfile(username: String, avatarImage: UIImage?,description: String) async throws {
        guard Validators.ifFilled(username: username, description: description) else { throw UserError.notFilled }
        guard let avatarImage = avatarImage else { throw UserError.photoNotExist }
        let url = try await StorageService.shared.upload(photo: avatarImage)
        try await usersRef.document(currentUser.id).updateData([SUser.repreAvatarStringURL: url.absoluteString, "username": username, "description": description])
        currentUser.avatarStringURL = url.absoluteString
        currentUser.username = username
        currentUser.description = description
    }
    
    /// Обновляет дату выхода пользователя
    public func updateEntryTime(date: Date = Date()) {
        guard let currentUser = currentUser else { return }
        let currentSUser = usersRef.document(currentUser.id)
        currentSUser.updateData([SUser.repreExitTime : date]) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    /// Обновляет состояния у пользователя и у связных с ним активных чатов.
    public func asyncUpdateIsOnline(is online: Bool) {
        guard let currentUser = currentUser else { return }
        let user = usersRef.document(currentUser.id)
        Task(priority: .high) {
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
                                print(#function + error.localizedDescription)
                            }
                        }
                    }
                })
            } catch {
                print(#function + error.localizedDescription)
            }
        }
    }
    
    public func updateIsOnline(is online: Bool) async {
        guard let currentUser = currentUser else { return }
        let user = usersRef.document(currentUser.id)
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
                            print(#function + error.localizedDescription)
                        }
                    }
                }
            })
        } catch {
            print(#function + error.localizedDescription)
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
    
    public func getCurrentUserData() async throws -> SUser {
        let userDocRef = usersRef.document(currentUser.id)
        let document = try await userDocRef.getDocument()
        guard document.exists, let sUser = SUser(document: document) else {
            throw UserError.cannotGetUserInfo
        }
        return sUser
    }
    
    public func updateActiveChatsArray(chat: SChat) async {
        do {
            let docs = try await activeChatsRef.getDocuments()
            let id = docs.documents.map { $0.documentID }
            try await usersRef.document(currentUser.id).updateData([SUser.repreActiveChats : id])
            let fdocs = try await activeChatsRef(id: chat.friendId).getDocuments()
            let fId = fdocs.documents.map { $0.documentID }
            try await usersRef.document(chat.friendId).updateData([SUser.repreActiveChats : fId])
        } catch {
            print(#function + error.localizedDescription)
        }
    }
    
    private func updateBlockedUser(friendId: String) async throws {
        let currentUser = try await getUserData(id: currentUser.id)
        let friendUser = try await getUserData(id: friendId)
        
        var blocked = currentUser.blocked
        blocked.append(friendId)
        
        var friendBlocked = friendUser.blocked
        friendBlocked.append(currentUser.id)
        
        try await usersRef.document(friendId).updateData([SUser.repreBlocked : friendBlocked])
        try await usersRef.document(currentUser.id).updateData([SUser.repreBlocked : blocked])
    }
    
    /// Обновляет дату входа текущего пользователя
    public func updateIsHide(hide: Bool) async throws {
        let currentSUser = usersRef.document(currentUser.id)
        try await currentSUser.updateData([SUser.repreIsHide: hide])
    }
    
}


// MARK: - Waiting Chat

extension FirestoreService {
    
    /// Создает ожидающий чат с сообщением от другого пользователя
    public func asyncCreateWaitingChat(receiver: SUser, message: String) throws {
        let receiverWaitingChatsRef = waitingChatsRef(id: receiver.id)
        let receiverWaitingChatMessagesRef = waitingChatMessagesRef(to: receiver.id, from: currentUser.id)
        let message = SMessage(user: currentUser, content: message)
        let chat = SChat(friendUsername: currentUser.username, friendUserImageString: currentUser.avatarStringURL, lastMessage: message.content , friendId: currentUser.id, lastDate: Date(), isOnline: currentUser.isOnline)
        Task(priority: .userInitiated) {
            do {
                try await receiverWaitingChatsRef.document(currentUser.id).setData(chat.representation)
                try await receiverWaitingChatMessagesRef.addDocument(data: message.representation)
            }
        }
    }
    
    /// Удаляет ожидающий чат и всю связную информацию
    public func deleteWaitingChat(from friendId: String) async throws {
        async let deleteWaitingChatMessages: () =  try deleteWaitingChatMessages(form: friendId)
        async let deleteWaitingChat: () = try waitingChatsRef.document(friendId).delete()
        let _ = try await [deleteWaitingChatMessages, deleteWaitingChat]
    }
    
    
    public func isWaitingChats(friendId: String, completion: @escaping (Result<WaitingChatState, Error>)-> Void) {
        waitingChatsRef.document(friendId).getDocument(completion: { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let document = document, document.exists {
                completion(.success(.accept))
            } else {
                self.waitingChatsRef(id: friendId).document(self.currentUser.id).getDocument { (document, error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    if let document = document, document.exists {
                        completion(.success(.waiting))
                    } else {
                        completion(.success(.non))
                    }
                }
            }
        })
        
    }
    
}


// MARK: - Active Chats

extension FirestoreService {
    
    /// Функция переносит чат из ожидающего в активный.
    /// Переносит сообщения из ожидающего чата в созданый активный чат.
    public func changeToActive(chat: SChat) async throws {
        let waitingChatMessages = try await getWaitingChatMessages(from: chat.friendId)
        try await deleteWaitingChat(from: chat.friendId)
        
        let forFriendChat = SChat(friendUsername: currentUser.username,
                                  friendUserImageString: currentUser.avatarStringURL,
                                  lastMessage: chat.lastMessage,
                                  friendId: currentUser.id,
                                  lastDate: Date(),
                                  isOnline: currentUser.isOnline,
                                  typing: TypingType.none.rawValue)
        
        let forMeChat = SChat(friendUsername: chat.friendUsername,
                           friendUserImageString: chat.friendUserImageString,
                           lastMessage: chat.lastMessage,
                           friendId: chat.friendId,
                           lastDate: Date(),
                              isOnline: chat.isOnline,
                           typing: TypingType.none.rawValue)
        
        async let meChat: Void = try createActiveChat(to: currentUser.id, from: chat.friendId, chat: forMeChat, messages: waitingChatMessages)
        async let friendChat: Void = try createActiveChat(to: chat.friendId, from: currentUser.id, chat: forFriendChat, messages: waitingChatMessages)
        let _ = try await [meChat, friendChat]
    }
    
    /// Создает активный чат для текущего пользователя и для друга.
    /// Так же добавляет сообщения.
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
                        print(#function + error.localizedDescription)
                    }
                }
            }
        })
    }
    
    /// Удаляет активный чат у текущего пользователя и у друга.
    public func deleteActiveChat(friendId: String) async throws {
        async let deleteMeChat: Void = try activeChatsRef(id: currentUser.id).document(friendId).delete()
        async let deleteFriendChat: Void = try activeChatsRef(id: friendId).document(currentUser.id).delete()
        let _ = try await [deleteMeChat, deleteFriendChat]
    }
    
    /// Удаляет активный чат и всю связную информацию у текущего пользователя и у друга.
    public func clearActiveChat(friendId: String) async throws {
        async let deleteMeMessages: () = try deleteActiveChatMessages(to: currentUser.id, from: friendId)
        async let deleteFriendMessages: () = try deleteActiveChatMessages(to: friendId, from: currentUser.id)
        async let deleteMePhoto: () = try StorageService.shared.deleteImageMessages(to: currentUser.id, from: friendId)
        async let deleteFriendPhoto: () = try StorageService.shared.deleteImageMessages(to: friendId, from: currentUser.id)
        let _ = try await [deleteMePhoto, deleteFriendPhoto, deleteMeMessages, deleteFriendMessages]
    }
    
    
    public func asyncUpdateChatTyping(for chat: SChat, typing: TypingType) {
        let friendActiveChatRef = activeChatsRef(id: chat.friendId).document(currentUser.id)
        Task(priority: .userInitiated) {
            do {
                try await friendActiveChatRef.updateData(["typing" : typing.rawValue])
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
    public func asyncSendMessage(from chat: SChat, message: SMessage) throws {
        let forFriendChat = SChat(friendUsername: currentUser.username,
                                  friendUserImageString: currentUser.avatarStringURL,
                                  lastMessage: message.descriptor,
                                  friendId: currentUser.id,
                                  lastDate: Date(),
                                  isOnline: currentUser.isOnline,
                                  typing: TypingType.none.rawValue)
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
    
    private func getWaitingChatMessages(from friendId: String) async throws -> [SMessage] {
        let messagesWaitingChatRef = waitingChatMessagesRef(to: currentUser.id, from: friendId)
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
                        print(#function + error.localizedDescription)
                    }
                }
            }
        })
    }
    
    /// Удаляет все сообщения ожидающего чата у текущего пользователя
    private func deleteWaitingChatMessages(form friendId: String) async throws {
        let messagesWaitingChatRef = waitingChatMessagesRef(to: currentUser.id, from: friendId)
        let messages = try await getWaitingChatMessages(from: friendId )
        await withTaskGroup(of: Void.self, body: { taskGroup in
            messages.forEach { message in
                taskGroup.addTask {
                    do {
                        guard let documentId = message.id else { return }
                        let messageRef = messagesWaitingChatRef.document(documentId)
                        try await messageRef.delete()
                    } catch {
                        print(#function + error.localizedDescription)
                    }
                }
            }
        })
    }
}


// MARK: - Other

extension FirestoreService {
    
    /// Блокирует и удаляет всю связную информацию из текущего юзера
    ///  - Parameter: user Пользователь которого нужно заблокировать
    public func blockedUser(user: SUser) async {
        do {
            try await updateBlockedUser(friendId: user.id)
        } catch {
            print(#function + error.localizedDescription)
        }
    }
    
    /// Блокирует и удаляет всю связную информацию из текущего юзера
    ///  - Parameter: user Пользователь которого нужно заблокировать
    public func asyncBlockedClear(user: SUser) {
        Task(priority: .userInitiated) {
            do {
                async let deleteWaiting: () = try deleteWaitingChat(from: user.id)
                async let deleteActive: () = try deleteActiveChat(friendId: user.id)
                let _ = try await [deleteWaiting, deleteActive]
            } catch {
                print(#function + error.localizedDescription)
            }
        }
        Task(priority: .background) {
            do {
                try await clearActiveChat(friendId: user.id)
            } catch {
                print(#function + error.localizedDescription)
            }
        }
    }
    
}
