//
//  WaitingChatsNavigation.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 14.12.2023.
//

import Foundation

protocol WaitingChatsNavigation: AnyObject {
    func removeWaitingChats(chat: SChat)
    func chatToActive(chat: SChat)
}
