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
        configuration()
        let listViewController = ListViewController(currentUser: currentUser)
        let peopleViewController = PeopleViewController(currentUser: currentUser)
        let setupViewController = ProfileViewController(user: currentUser)
//        let setupViewController = SettingProfileViewController(user: currentUser)
        
        let boldConfig = UIImage.SymbolConfiguration(weight: .medium)
        let peopleImage = UIImage(systemName: "person.2.fill", withConfiguration: boldConfig)!
        let messageImage = UIImage(systemName: "message.fill", withConfiguration: boldConfig)!
        let personImage = UIImage(systemName: "person.fill", withConfiguration: boldConfig)!
        viewControllers = [
            generateNavigationViewController(rootViewController: peopleViewController, title: "People", image: peopleImage),
            generateNavigationViewController(rootViewController: listViewController, title: "Chats", image: messageImage),
            generateNavigationViewController(rootViewController: setupViewController, title: "Profile", image: personImage)
        ]
    }
    
    private func generateNavigationViewController(rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        navigationVC.tabBarItem.title = NSLocalizedString(title, comment: "")
        navigationVC.tabBarItem.image = image
        return navigationVC
    }
}

private extension MainTabBarController {
    
    func configuration() {
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        tabBar.isTranslucent = true
        tabBar.backgroundColor = ColorAppearance.clearWhite.color()
        tabBar.addBlur(blur: UIBlurEffect(style: .regular))
    }
}
