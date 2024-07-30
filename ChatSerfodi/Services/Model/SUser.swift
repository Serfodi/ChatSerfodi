//
//  SUser.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 22.11.2023.
//

import UIKit
import FirebaseFirestore

struct SUser {
    
    var username: String
    var email: String
    var avatarStringURL: String
    var description: String
    var sex: String
    var id: String
    var isHide: Bool
    var exitTime: Date
    var isOnline: Bool
    var blocked: [String]
    var activeChats: [String]
    
    static let repreUsername = "username"
    static let repreAvatarStringURL =  "avatarStringURL"
    static let repreDescription = "description"
    static let repreExitTime = "exitTime"
    static let repreIsOnline = "isOnline"
    static let repreActiveChats = "activeChats"
    static let repreBlocked = "blocked"
    
    var representation: [String : Any] {
        let rep: [String : Any] = [
            "username": username,
            "email": email,
            "avatarStringURL": avatarStringURL,
            "description" : description,
            "sex" : sex,
            "uid" : id,
            "isHide": isHide,
            "exitTime" : exitTime,
            "isOnline" : isOnline,
            "blocked" : blocked,
            "activeChats" : activeChats
        ]
        return rep
    }
    
    // MARK: init
    
    init(username: String,
         email: String,
         avatarStringURL: String,
         description: String,
         sex: String,
         id: String,
         isHide: Bool,
         entryTime: Date,
         isOnline: Bool,
         blocked: [String],
         activeChats: [String]
    ) {
        self.username = username
        self.email = email
        self.avatarStringURL = avatarStringURL
        self.description = description
        self.sex = sex
        self.id = id
        self.isHide = isHide
        self.exitTime = entryTime
        self.isOnline = isOnline
        self.blocked = blocked
        self.activeChats = activeChats
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        guard
            let username = data["username"] as? String,
            let email = data["email"] as? String,
            let avatarStringURL = data["avatarStringURL"] as? String,
            let description = data["description"] as? String,
            let sex = data["sex"] as? String,
            let uid = data["uid"] as? String,
            let isHide = data["isHide"] as? Bool,
            let exitTime = data["exitTime"] as? Timestamp,
            let isOnline = data["isOnline"] as? Bool,
            let blocked = data["blocked"] as? [String],
            let activeChats = data["activeChats"] as? [String]
        else { return nil }
        self.username = username
        self.email = email
        self.avatarStringURL = avatarStringURL
        self.description = description
        self.sex = sex
        self.id = uid
        self.isHide = isHide
        self.exitTime = exitTime.dateValue()
        self.isOnline = isOnline
        self.blocked = blocked
        self.activeChats = activeChats
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard
            let username = data["username"] as? String,
            let email = data["email"] as? String,
            let avatarStringURL = data["avatarStringURL"] as? String,
            let description = data["description"] as? String,
            let sex = data["sex"] as? String,
            let uid = data["uid"] as? String,
            let isHide = data["isHide"] as? Bool,
            let exitTime = data["exitTime"] as? Timestamp,
            let isOnline = data["isOnline"] as? Bool,
            let blocked = data["blocked"] as? [String],
            let activeChats = data["activeChats"] as? [String]
        else { return nil }
        self.username = username
        self.email = email
        self.avatarStringURL = avatarStringURL
        self.description = description
        self.sex = sex
        self.id = uid
        self.isHide = isHide
        self.exitTime = exitTime.dateValue()
        self.isOnline = isOnline
        self.blocked = blocked
        self.activeChats = activeChats
    }
            
    // Equality
    static func == (lhs: SUser, rhs: SUser) -> Bool {
        lhs.id == rhs.id
    }
    
    /// Check contains `username` on filter.
    func contains(filter: String?) -> Bool {
        guard let filter = filter else { return true }
        if filter.isEmpty { return true }
        let lowercasedFilter = filter.lowercased()
        return username.lowercased().contains(lowercasedFilter)
    }
    
}

// MARK: Hashable & Decodable
extension SUser: Hashable, Decodable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
