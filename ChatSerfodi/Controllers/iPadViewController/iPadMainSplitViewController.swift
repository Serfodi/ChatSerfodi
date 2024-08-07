//
//  MainSpliteViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 01.08.2024.
//

import UIKit

class iPadMainSplitViewController: UISplitViewController {

    
    // MARK: init
    
    private let user: SUser
    
    init(user: SUser) {
        self.user = user
        super.init(style: .doubleColumn)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Live Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
    }
    
    // helper
    
    func configuration() {
        let masterController = MainTabBarController(sUser: user)
        
        let detailController = UIViewController()
        let detailNavigationController = UINavigationController(rootViewController: detailController)
        
        splitViewController?.viewControllers = [
            masterController, detailNavigationController
        ]
    }
    
}

