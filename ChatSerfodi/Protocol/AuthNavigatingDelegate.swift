//
//  AuthNavigatingDelegate.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 03.12.2023.
//

import Foundation

protocol AuthNavigatingDelegate: AnyObject {
    func toLoginVC()
    func toSignUPVC()
}
