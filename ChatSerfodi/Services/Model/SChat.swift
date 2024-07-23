//
//  SChat.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 22.11.2023.
//

import UIKit
import FirebaseFirestore

struct SChat {
    var friendUsername: String
    var friendUserImageString: String
    var lastMessage: String
    var friendId: String
    var lastDate: Date
    var isOnline: Bool
    var typing: String
    
    var representation: [String: Any] {
        var rep: [String: Any] = ["friendUsername": friendUsername]
        rep["friendUserImageString"] = friendUserImageString
        rep["lastMessage"] = lastMessage
        rep["friendId"] = friendId
        rep["lastDate"] = lastDate
        rep["isOnline"] = isOnline
        rep["typing"] = typing
        return rep
    }
    
    // MARK: init
    
    init(friendUsername: String, friendUserImageString: String, lastMessage: String, friendId: String, lastDate: Date, isOnline: Bool, typing: String) {
        self.friendUsername = friendUsername
        self.friendUserImageString = friendUserImageString
        self.lastMessage = lastMessage
        self.friendId = friendId
        self.lastDate = lastDate
        self.isOnline = isOnline
        self.typing = typing
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard
            let friendUsername = data["friendUsername"] as? String,
            let friendUserImageString = data["friendUserImageString"] as? String,
            let lastMessage = data["lastMessage"] as? String,
            let friendId = data["friendId"] as? String,
            let lastDate = data["lastDate"] as? Timestamp,
            let isOnline = data["isOnline"] as? Bool,
            let typing = data["typing"] as? String
        else {
            return nil
        }
        self.friendUsername = friendUsername
        self.friendUserImageString = friendUserImageString
        self.lastMessage = lastMessage
        self.friendId = friendId
        self.lastDate = lastDate.dateValue()
        self.isOnline = isOnline
        self.typing = typing
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        guard
            let friendUsername = data["friendUsername"] as? String,
            let friendUserImageString = data["friendUserImageString"] as? String,
            let lastMessage = data["lastMessage"] as? String,
            let friendId = data["friendId"] as? String,
            let lastDate = data["lastDate"] as? Timestamp,
            let isOnline = data["isOnline"] as? Bool,
            let typing = data["typing"] as? String
        else { return nil }
        self.friendUsername = friendUsername
        self.friendUserImageString = friendUserImageString
        self.lastMessage = lastMessage
        self.friendId = friendId
        self.lastDate = lastDate.dateValue()
        self.isOnline = isOnline
        self.typing = typing
    }
    
    // Equality
//    static func == (lhs: SChat, rhs: SChat) -> Bool {
//        lhs.friendId == rhs.friendId
//    }
    
//    static func == (lhs: SChat, rhs: SChat) -> Bool {
//        lhs.friendId == rhs.friendId && lhs.lastMessage == rhs.lastMessage && (lhs.isOnline == rhs.isOnline)
//    }
    
    static func == (lhs: SChat, rhs: SChat) -> Bool {
        (lhs.isOnline == rhs.isOnline) && lhs.typing == rhs.typing && lhs.lastMessage == rhs.lastMessage && lhs.friendId == rhs.friendId
    }
    
    
    /// Check contains `friendUsername` on filter.
    func contains(filter: String?) -> Bool {
        guard let filter = filter else { return true }
        if filter.isEmpty { return true }
        let lowercasedFilter = filter.lowercased()
        return friendUsername.lowercased().contains(lowercasedFilter)
    }
}

extension SChat: Hashable, Decodable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(friendId)
    }
}
