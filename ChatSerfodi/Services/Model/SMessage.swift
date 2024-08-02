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
    
    var messageId: String {
        id ?? UUID().uuidString
    }
    let id: String?
    
    var sender: MessageKit.SenderType
    var sentDate: Date
    
    // content
    
    let content: String
    var image: UIImage?
    var downloadURL: URL?
    var height: Int?
    var width: Int?
    
    var isRead: Bool
    
    var kind: MessageKind {
        if let image = image {
            let mediaItem = ImageItem(url: downloadURL, image: image, placeholderImage: image, size: CGSize(width: CGFloat(width!), height: CGFloat(height!)))
            return .photo(mediaItem)
        } else {
            return .text(content)
        }
    }
    
    var representation: [String: Any] {
        var rep: [String : Any] = [
            "created": sentDate,
            "senderID": sender.senderId,
            "senderName": sender.displayName,
            "isRead" : isRead
        ]
        if let url = downloadURL {
            rep["url"] = url.absoluteString
            rep["height"] = height
            rep["width"] = width
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
        isRead = false
        id = nil
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let senderId = data["senderID"] as? String,
              let senderUserName = data["senderName"] as? String,
              let sentDate = data["created"] as? Timestamp,
              let isRead = data["isRead"] as? Bool
        else { return nil }
        
        sender = Sender(senderId: senderId, displayName: senderUserName)
        self.sentDate = sentDate.dateValue()
        self.isRead = isRead
        self.id = document.documentID
        
        if let content = data["content"] as? String {
            self.content = content
            downloadURL = nil
        } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
            self.height = data["height"] as? Int
            self.width = data["width"] as? Int
            downloadURL = url
            self.content = ""
            self.image = UIImage(imageLiteralResourceName: "image_message_placeholder")
        } else {
            return nil
        }
    }
    
    init(user: SUser, image: UIImage) {
        sender = Sender(senderId: user.id, displayName: user.username)
        self.image = image
        self.height = Int(image.size.height)
        self.width = Int(image.size.width)
        content = ""
        sentDate = Date()
        id = nil
        isRead = false
    }
    
    // Equality
    
    static func == (lhs: SMessage, rhs: SMessage) -> Bool {
        lhs.messageId == rhs.messageId && lhs.sentDate == rhs.sentDate
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
