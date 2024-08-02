//
//  UISearchController + Extension.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 01.08.2024.
//

import UIKit

extension UISearchController {
    
    static func defaultConfiguration() -> UISearchController {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }
    
}
