//
//  MainTabBarController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 10.11.2023.
//

import UIKit
import FirebaseAuth

class MainTabBarController: UITabBarController {
    
    private lazy var images: [UIImage] = {
        let boldConfig = UIImage.SymbolConfiguration(weight: .medium)
        return [UIImage(systemName: "person.2.fill", withConfiguration: boldConfig)!,
                UIImage(systemName: "message.fill", withConfiguration: boldConfig)!,
                UIImage(systemName: "person.fill", withConfiguration: boldConfig)!]
    }()
    
    private lazy var loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView()
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.hidesWhenStopped = true
        loader.tintColor = ColorAppearance.black.color()
        loader.color = ColorAppearance.black.color()
        return loader
    }()
    
    // MARK: init
    
    init(user: User) {
        super.init(nibName: nil, bundle: nil)
        asyncConfiguration(user: user)
    }

    init(sUser: SUser) {
        super.init(nibName: nil, bundle: nil)
        configuration(sUser: sUser)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Live Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
    }
    
}

// MARK: Configuration

private extension MainTabBarController {
    
    func configuration(sUser: SUser) {
        viewControllers = [
            generateNavigationViewController(PeopleViewController(user: sUser), title: "People", image: images[0]),
            generateNavigationViewController(ListViewController(user: sUser), title: "Chats", image: images[1]),
            generateNavigationViewController(ProfileViewController(user: sUser), title: "Profile", image: images[2])
        ]
    }
    
    func asyncConfiguration(user: User) {
        let mocVC = UIViewController()
        self.view.isUserInteractionEnabled = false
        viewControllers = [
            generateNavigationViewController(mocVC, title: "People", image: images[0]),
            generateNavigationViewController(mocVC, title: "Chats", image: images[1]),
            generateNavigationViewController(mocVC, title: "Profile", image: images[2])
        ]
        Task(priority: .userInitiated) {
            do {
                configurationLoad()
                let sUser = try await FirestoreService.shared.getUserData(user: user)
                FirestoreService.shared.asyncUpdateIsOnline(is: true)
                viewControllers = [
                    generateNavigationViewController(PeopleViewController(user: sUser), title: "People", image: images[0]),
                    generateNavigationViewController(ListViewController(user: sUser), title: "Chats", image: images[1]),
                    generateNavigationViewController(ProfileViewController(user: sUser), title: "Profile", image: images[2])
                ]
                loader.stopAnimating()
                loader.isHidden = true
                self.view.isUserInteractionEnabled = true
            } catch {
                self.showAlert(with: "Error", and: #function + error.localizedDescription) {
                    UIApplication.shared.firstKeyWindow?.rootViewController = AuthViewController()
                }
            }
        }
    }
    
    private func generateNavigationViewController(_ rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        navigationVC.tabBarItem.title = NSLocalizedString(title, comment: "")
        navigationVC.tabBarItem.image = image
        return navigationVC
    }
}


// MARK: Configuration

private extension MainTabBarController {
    
    func configuration() {
        view.backgroundColor = ColorAppearance.white.color()
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        tabBar.isTranslucent = true
        tabBar.backgroundColor = ColorAppearance.clearWhite.color()
        tabBar.addBlur(blur: UIBlurEffect(style: .regular))
    }
    
    func configurationLoad() {
        view.addSubview(loader)
        loader.centerInSuperview()
        loader.startAnimating()
    }
}
