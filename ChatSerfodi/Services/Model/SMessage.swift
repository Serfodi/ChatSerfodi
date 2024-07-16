//
//  SMessage.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 13.12.2023.
//

import UIKit
import FirebaseFirestore
import MessageKit


// MARK: ImageItem
struct ImageItem: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}


// MARK: - SMessage

struct SMessage: MessageType  {
    
    var sender: MessageKit.SenderType
    var sentDate: Date
    let id: String?
    
    let content: String
    var image: UIImage?
    var downloadURL: URL?
    
    var messageId: String {
        id ?? UUID().uuidString
    }
    
    var kind: MessageKit.MessageKind {
        if let image = image {
            let mediaItem = ImageItem(placeholderImage: image, size: image.size)
            return .photo(mediaItem)
        } else {
            return .text(content)
        }
    }
    
    var representation: [String: Any] {
        var rep: [String : Any] = [
            "created": sentDate,
            "senderID": sender.senderId,
            "senderName": sender.displayName
        ]
        if let url = downloadURL {
            rep["url"] = url.absoluteString
        } else {
            rep["content"] = content
        }
        return rep
    }
    
    var descriptor: String {
        switch kind {
        case .text(let content):
            return content
        case .photo(_):
            return NSLocalizedString("Photo", comment: "")
        default:
            return "Сообщение"
        }
    }
    
    // MARK: init
    
    init(user: SUser, content: String) {
        sender = Sender(senderId: user.id, displayName: user.username)
        self.content = content
        sentDate = Date()
        id = nil
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let senderId = data["senderID"] as? String,
              let senderUserName = data["senderName"] as? String,
              let sentDate = data["created"] as? Timestamp
        else { return nil }
        
        sender = Sender(senderId: senderId, displayName: senderUserName)
        self.sentDate = sentDate.dateValue()
        self.id = document.documentID
        
        if let content = data["content"] as? String {
            self.content = content
            downloadURL = nil
        } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
            downloadURL = url
            self.content = ""
        } else {
            return nil
        }
    }
    
    init(user: SUser, image: UIImage) {
        sender = Sender(senderId: user.id, displayName: user.username)
        self.image = image
        content = ""
        sentDate = Date()
        id = nil
    }
    
    // Equality
    
    static func == (lhs: SMessage, rhs: SMessage) -> Bool {
        lhs.messageId == rhs.messageId
    }
    
}

// MARK: Hashable
extension SMessage: Hashable {
 
    func hash(into hasher: inout Hasher) {
        hasher.combine(messageId)
    }
}

// MARK: Comparable
extension SMessage: Comparable {
    
    /// Comparable for `sentDate`
    static func < (lhs: SMessage, rhs: SMessage) -> Bool {
        lhs.sentDate < rhs.sentDate
    }
}
