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
    
    func contains(filtr: String?) -> Bool {
        guard let filtr = filtr else { return true }
        if filtr.isEmpty { return true }
        let lowercasedFiltr = filtr.lowercased()
        return userName.lowercased().contains(lowercasedFiltr)
    }
}
