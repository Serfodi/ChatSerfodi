//
//  SUser.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 22.11.2023.
//

import UIKit

struct SUser: Hashable, Decodable {
    
    var userName: String
    var avatarStringURL: String
    var id: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: SUser, rhs: SUser) -> Bool {
        lhs.id == rhs.id
    }
}
