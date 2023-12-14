//
//  SMessage.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 13.12.2023.
//

import UIKit
import FirebaseFirestore
import MessageKit


struct SMessage: Hashable, MessageType  {
    
    var sender: MessageKit.SenderType
    let content: String
    var sentDate: Date
    let id: String?
    
    var messageId: String {
        id ?? UUID().uuidString
    }
    
    var kind: MessageKit.MessageKind {
        .text(content)
    }
    
    var representation: [String: Any] { [
            "created": sentDate,
            "senderID": sender.senderId,
            "senderName": sender.displayName,
            "content": content
        ]
    }
    
    init(user: SUser, content: String) {
        sender = Sender(senderId: user.id, displayName: user.username)
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
        sender = Sender(senderId: senderId, displayName: senderUserName)
        self.sentDate = sentDate.dateValue()
        self.id = document.documentID
    }
    
    static func == (lhs: SMessage, rhs: SMessage) -> Bool {
        lhs.messageId == rhs.messageId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(messageId)
    }
    
    
}
