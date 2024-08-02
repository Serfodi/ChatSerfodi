//
//  ProfileChangesDelegate.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 01.08.2024.
//

import Foundation

protocol ProfileChangesDelegate: AnyObject {
    func changeBegin()
    func changeCancel()
}
