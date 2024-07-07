//
//  SChat.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 22.11.2023.
//

import UIKit
import FirebaseFirestore

struct SChat: Hashable, Decodable {
    var friendUsername: String
    var friendUserImageString: String
    var lastMessage: String
    var friendId: String
    
    var representation: [String: Any] {
        var rep = ["friendUsername": friendUsername]
        rep["friendUserImageString"] = friendUserImageString
        rep["lastMessage"] = lastMessage
        rep["friendId"] = friendId
        return rep
    }
    
    init(friendUsername: String, friendUserImageString: String, lastMessage: String, friendId: String) {
        self.friendUsername = friendUsername
        self.friendUserImageString = friendUserImageString
        self.lastMessage = lastMessage
        self.friendId = friendId
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard
            let friendUsername = data["friendUsername"] as? String,
            let friendUserImageString = data["friendUserImageString"] as? String,
            let lastMessage = data["lastMessage"] as? String,
            let friendId = data["friendId"] as? String
        else {
            return nil
        }
        
        self.friendUsername = friendUsername
        self.friendUserImageString = friendUserImageString
        self.lastMessage = lastMessage
        self.friendId = friendId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(friendId)
    }
    
    static func == (lhs: SChat, rhs: SChat) -> Bool {
        lhs.friendId == rhs.friendId
    }
}
