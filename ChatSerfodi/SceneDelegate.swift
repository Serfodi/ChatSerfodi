//
//  SceneDelegate.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 21.10.2023.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        if let user = Auth.auth().currentUser {
            Task(priority: .userInitiated) {
                do {
                    let suser = try await FirestoreService.shared.getUserData(user: user)
                    let mainTabBar = MainTabBarController(currentUser: suser)
                    mainTabBar.modalPresentationStyle = .fullScreen
                    self.window?.rootViewController = mainTabBar
                    FirestoreService.shared.updateIsOnline(is: true)
                } catch {
                    self.window?.rootViewController = AuthViewController()
                }
            }
        } else {
            self.window?.rootViewController = AuthViewController()
        }
        
        window?.overrideUserInterfaceStyle = .light
        
        window?.makeKeyAndVisible()
    }
 
    func sceneDidBecomeActive(_ scene: UIScene) {
        FirestoreService.shared.updateIsOnline(is: true)
    }    
    
    func sceneWillResignActive(_ scene: UIScene) {
        FirestoreService.shared.updateIsOnline(is: false)
        FirestoreService.shared.updateEntryTime()
    }
    
}

