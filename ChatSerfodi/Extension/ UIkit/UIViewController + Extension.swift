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

extension UIViewController {
    
    /// Показывать обычное уведомление
    func showAlert(with title: String, and message: String, completion: @escaping () -> Void = {} ) {
        let alertController = UIAlertController(title: NSLocalizedString(title, comment: ""), message: NSLocalizedString(message, comment: ""), preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            completion()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
}
