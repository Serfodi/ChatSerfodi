//
//  UIViewController + Extension.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 22.11.2023.
//

import UIKit

extension UIViewController {
    
    func configure<T: SelfConfiguringCell, U: Hashable>(collectionView: UICollectionView, cellType: T.Type, with value: U, for indexPatch: IndexPath) -> T {
        guard let cell = collectionView .dequeueReusableCell(withReuseIdentifier: cellType.reuseId, for: indexPatch) as? T else { fatalError("Unable to dequeue \(cellType)") }
        cell.configure(with: value)
        return cell
    }
    
}
