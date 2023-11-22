//
//  SelfConfiguringCell.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 17.11.2023.
//

import Foundation

protocol SelfConfiguringCell {
    static var reuseId: String { get }
    func configure<U: Hashable>(with value: U)
}
