//
//  SMessage.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 13.12.2023.
//

import UIKit
import FirebaseFirestore

struct SMessage: Hashable {
    let content: String
    let senderId: String
    let senderUserName: String
    var sentDate: Date
    let id: String?
    
    init(user: SUser, content: String) {
        senderId = user.id
        senderUserName = user.username
        self.content = content
        sentDate = Date()
        id = nil
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let content = data["content"] as? String,
            let senderId = data["senderID"] as? String,
            let senderUserName = data["senderName"] as? String,
            let sentDate = data["created"] as? Timestamp
        else { return nil }
        
        self.content = content
        self.senderId = senderId
        self.senderUserName = senderUserName
        self.sentDate = sentDate.dateValue()
        self.id = document.documentID
    }
    
    var representation: [String: Any] { [
            "created": sentDate,
            "senderID": senderId,
            "senderName": senderUserName,
            "content": content
        ]
    }
    
}
