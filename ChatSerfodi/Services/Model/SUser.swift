//
//  SUser.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 22.11.2023.
//

import UIKit
import FirebaseFirestore

struct SUser: Hashable, Decodable {
    
    var username: String
    var email: String
    var avatarStringURL: String
    var description: String
    var sex: String
    var id: String
    
    
    init(username: String, email: String, avatarStringURL: String, description: String, sex: String, id: String) {
        self.username = username
        self.email = email
        self.avatarStringURL = avatarStringURL
        self.description = description
        self.sex = sex
        self.id = id
    }
    
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        
        guard
            let username = data["username"] as? String,
            let email = data["email"] as? String,
            let avatarStringURL = data["avatarStringURL"] as? String,
            let description = data["description"] as? String,
            let sex = data["sex"] as? String,
            let uid = data["uid"] as? String
        else { return nil }
        
        self.username = username
        self.email = email
        self.avatarStringURL = avatarStringURL
        self.description = description
        self.sex = sex
        self.id = uid
        
    }
    
    var representation: [String: Any] {
        var rep = ["username": username]
        rep["email"] = email
        rep["avatarStringURL"] = avatarStringURL
        rep["description"] = description
        rep["sex"] = sex
        rep["email"] = email
        rep["uid"] = id
        return rep
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: SUser, rhs: SUser) -> Bool {
        lhs.id == rhs.id
    }
    
    func contains(filtr: String?) -> Bool {
        guard let filtr = filtr else { return true }
        if filtr.isEmpty { return true }
        let lowercasedFiltr = filtr.lowercased()
        return username.lowercased().contains(lowercasedFiltr)
    }
    
    
    
}
