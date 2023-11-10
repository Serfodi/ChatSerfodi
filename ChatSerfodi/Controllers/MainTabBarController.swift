//
//  MainTabBarController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 10.11.2023.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let listViewController = ListViewController()
        let peopleViewController = PeopleViewController()
        
        let boldConfig = UIImage.SymbolConfiguration(weight: .medium)
        let peopleImage = UIImage(systemName: "person.2", withConfiguration: boldConfig)!
        let messageImage = UIImage(systemName: "message", withConfiguration: boldConfig)!
        
        viewControllers = [
            generateNavigationViewController(rootViewController: listViewController, titile: "", image: peopleImage),
            generateNavigationViewController(rootViewController: peopleViewController, titile: "", image: messageImage)
        ]
    }
 
    
    private func generateNavigationViewController(rootViewController: UIViewController, titile: String, image: UIImage) -> UIViewController {
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        navigationVC.tabBarItem.title = titile
        navigationVC.tabBarItem.image = image
        return navigationVC
    }
    
}
