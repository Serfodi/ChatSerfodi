//
//  MainTabBarController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 10.11.2023.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    private let currentUser: SUser
    
    init(currentUser: SUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let listViewController = ListViewController(currentUser: currentUser)
        let peopleViewController = PeopleViewController(currentUser: currentUser)
        
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
