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
        do {
            try FirestoreService.shared.updateProfile(username: settingProfileViewController.fullNameText,
                                                  avatarImage: settingProfileViewController.image,
                                                      description: settingProfileViewController.aboutMeText)
            self.showAlert(with: "Successfully", and: "TheChangesAreSaved")
        } catch {
            self.showAlert(with: "Error", and: error.localizedDescription)
        }
    }
    
    @objc private func signOut() {
        view.endEditing(true)
        let ac = UIAlertController(title: nil, message: NSLocalizedString("GetOut", comment: ""), preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
        ac.addAction(UIAlertAction(title: NSLocalizedString("Exit", comment: ""), style: .destructive, handler: { _ in
            do {
                try Auth.auth().signOut()
                UIApplication.shared.firstKeyWindow?.rootViewController = AuthViewController()
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }))
        present(ac, animated: true)
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
    }
    
    func configurationNavigationBar() {
        navigationItem.title = NSLocalizedString("MyProfile", comment: "")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Exit", comment: ""), style: .done, target: self, action: #selector(signOut))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Save", comment: ""), style: .done, target: self, action: #selector(saveProfile))
        navigationController?.navigationBar.addBGBlur()
        navigationController?.navigationBar.standardAppearance.titleTextAttributes = [.font: FontAppearance.buttonText, .foregroundColor: ColorAppearance.black.color()]
        navigationController?.navigationBar.scrollEdgeAppearance?.titleTextAttributes = [.font: FontAppearance.buttonText, .foregroundColor: ColorAppearance.black.color()]
    }
    
    func configurationConstraints() {
        settingProfileViewController.view.topToSuperview()
        settingProfileViewController.view.leftToSuperview()
        settingProfileViewController.view.rightToSuperview()
        settingProfileViewController.view.bottom(to: view, view.keyboardLayoutGuide.topAnchor)
    }
    
}
