//
//  ProfileSettingViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 04.07.2024.
//

import UIKit
import FirebaseAuth
import TinyConstraints

final class ProfileViewController: UIViewController {

    private var settingProfileViewController: SettingProfileViewController!
        
    // MARK: init
    
    private let user: SUser
    
    init(user: SUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        settingProfileViewController = SettingProfileViewController(user: user)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Live circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
    }

    // MARK: Action
    
    @objc func saveProfile() {
        view.endEditing(true)
        Task(priority: .userInitiated) {
            do {
                try await FirestoreService.shared.updateProfile(
                    username: settingProfileViewController.fullNameText,
                    avatarImage: settingProfileViewController.image,
                    description: settingProfileViewController.aboutMeText)
                self.showAlert(with: "Successfully", and: "TheChangesAreSaved") {
                    self.configurationBarButton(change: false)
                }
            } catch {
                self.showAlert(with: "Error", and: error.localizedDescription) {
                    self.configurationBarButton(change: false)
                }
            }
        }
    }
    
    @objc private func settingOpen() {
        let settingVC = SettingViewController()
        present(settingVC, animated: true)
    }
    
    @objc private func cancelChange() {
        cancel()
    }
    
    private func cancel() {
        view.endEditing(true)
        settingProfileViewController.changeCancel()
        configurationBarButton(change: false)
        
    }
    
}

extension ProfileViewController: ProfileChangesDelegate {
    
    func changeBegin() {
        configurationBarButton(change: true)
        
    }
    
    func changeCancel() {
        cancel()
    }

}


// MARK: Configuration
private extension ProfileViewController {
    
    func configuration() {
        configurationView()
        configurationNavigationBar()
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
        settingProfileViewController.delegate = self
    }
    
    func configurationNavigationBar() {
        navigationItem.title = NSLocalizedString("MyProfile", comment: "")
        configurationBarButton(change: false)
        navigationController?.navigationBar.configuration()
    }
    
    func configurationBarButton(change: Bool) {
        if change {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .done, target: self, action: #selector(cancelChange))
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Save", comment: ""), style: .done, target: self, action: #selector(saveProfile))
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .done, target: self, action: #selector(settingOpen))
            navigationItem.leftBarButtonItem?.tintColor = ColorAppearance.black.color()
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func configurationConstraints() {
        settingProfileViewController.view.topToSuperview()
        settingProfileViewController.view.leftToSuperview()
        settingProfileViewController.view.rightToSuperview()
        settingProfileViewController.view.bottom(to: view, view.keyboardLayoutGuide.topAnchor)
    }
    
}
