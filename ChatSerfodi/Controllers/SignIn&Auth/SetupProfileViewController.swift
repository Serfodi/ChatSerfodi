//
//  SetupProfileViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 08.11.2023.
//

import UIKit
import FirebaseAuth

class SetupProfileViewController: UIViewController {
    
    private var settingProfileViewController: SettingProfileViewController!
    
    private let goToChatButton = UIButton(title: "GoChats", titleColor: ColorAppearance.white.color(), backgroundColor: ColorAppearance.black.color())
    private let sexLabel = UILabel(text: "Sex")
    private let sexSegmentedController = UISegmentedControl(first: SUser.Sex.man.description(), second: SUser.Sex.wom.description())
    
    private let currentUser: User
    
    // MARK: init
    
    init(currentUser: User) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        let moc = SUser.mocUser()
        let stack = UIStackView(arrangedSubviews: [sexLabel, sexSegmentedController], axis: .vertical, spacing: 5)
        let view = [stack, goToChatButton]
        settingProfileViewController = SettingProfileViewController(user: moc, addViewToScroll: view)
        settingProfileViewController.image = UIImage(imageLiteralResourceName: "image_message_placeholder")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Live Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configuration()
        
        goToChatButton.addTarget(self, action: #selector(goToChatsButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Action
    
    @objc private func goToChatsButtonTapped() {
        view.endEditing(true)
        Task(priority: .userInitiated) {
            do {
                let user = try await FirestoreService.shared.saveProfileWith(
                    id: currentUser.uid,
                    email: currentUser.email!,
                    username: settingProfileViewController.fullNameText,
                    avatarImage: settingProfileViewController.image,
                    description: settingProfileViewController.aboutMeText,
                    sex: sexSegmentedController.selectedSegmentIndex
                )
                self.showAlert(with: "Successfully", and: "YouAreLoggedIn") {
                    let mainTabBar = MainTabBarController(sUser: user)
                    mainTabBar.modalPresentationStyle = .fullScreen
                    self.present(mainTabBar, animated: true)
                }
            } catch {
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        }
    }
    
    // MARK: Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }

}

// MARK: Configuration
private extension SetupProfileViewController {
    
    func configuration() {
        configurationView()
        configurationProfileViewController()
        configurationConstraints()
    }
    
    func configurationView() {
        view.backgroundColor = ColorAppearance.white.color()
    }
    
    func configurationProfileViewController() {
        addChild(settingProfileViewController)
        view.addSubview(settingProfileViewController.view)
        settingProfileViewController.didMove(toParent: self)
    }
    
    func configurationConstraints() {
        settingProfileViewController.view.topToSuperview()
        settingProfileViewController.view.leftToSuperview()
        settingProfileViewController.view.rightToSuperview()
        settingProfileViewController.view.bottom(to: view, view.keyboardLayoutGuide.topAnchor)
        goToChatButton.height(54)
    }
    
}
