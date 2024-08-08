//
//  SettingViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 30.07.2024.
//

import UIKit
import FirebaseAuth
import TinyConstraints
import Lottie

class SettingViewController: UIViewController {

    private let gradientView = GradientView(from: .top, to: .bottom, startColor: ColorAppearance.blue.color(), endColor: ColorAppearance.white.color())
    private let logoLabel = UILabel(text: "Щебетарь", alignment: .center, fount: FontAppearance.logoTitle, color: ColorAppearance.black.color())
    private let birdView = BirdView()
    
    private let signOutButton = UIButton(title: "Exit", titleColor: .red, backgroundColor: .clear)
    private let docsButton = UIButton(title: "Privacy", titleColor: ColorAppearance.white.color(), backgroundColor: ColorAppearance.black.color())
    private let hideUserButton = UIButton(title: "Hide", titleColor: ColorAppearance.white.color(), backgroundColor: ColorAppearance.black.color(), image: UIImage(systemName: "eye.slash.fill"))
    
    private let labelCreate = UILabel(text: "Sergei Nasybullin", alignment: .center, fount: FontAppearance.buttonText, color: ColorAppearance.black.color())
    private let bundleLabel = UILabel(text: "", alignment: .center, fount: FontAppearance.small, color: ColorAppearance.black.color())
    
    
    // MARK: Live circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        birdView.play()
    }
    
    // MARK: Action
    
    @objc private func signOut() {
        view.endEditing(true)
        let ac = UIAlertController(title: nil, message: NSLocalizedString("GetOut", comment: ""), preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
        ac.addAction(UIAlertAction(title: NSLocalizedString("Exit", comment: ""), style: .destructive, handler: { _ in
            UIApplication.shared.firstKeyWindow?.rootViewController = AuthViewController()
            Task {
                do {
                    FirestoreService.shared.updateEntryTime()
                    await FirestoreService.shared.updateIsOnline(is: false)
                    try Auth.auth().signOut()
                } catch {
                    print("Error signing out: \(error.localizedDescription)")
                }
            }
        }))
        present(ac, animated: true)
    }
    
    @objc private func openDocs() {
        let privacyVC = PrivacyViewController()
        present(privacyVC, animated: true)
    }
    
    @objc private func hideUser() {
        Task(priority: .userInitiated) {
            do {
                let user = try await FirestoreService.shared.getCurrentUserData()
                let isHide = !user.isHide
                try await FirestoreService.shared.updateIsHide(hide: isHide)
                
                if isHide {
                    self.showAlert(with: "Successfully", and: "AccountHidden")
                    self.hideUserButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
                } else {
                    self.showAlert(with: "Successfully", and: "AccountShow")
                    self.hideUserButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
                }
            } catch {
                self.showAlert(with: "Error", and: #function + error.localizedDescription)
            }
        }
    }
    
}

// MARK: Configuration
private extension SettingViewController {
    
    func configuration() {
        configurationView()
        configurationButtons()
        configurationLabel()
        configurationLayout()
    }
    
    func configurationView() {
        view.backgroundColor = ColorAppearance.white.color()
    }
    
    func configurationLabel() {
        let bundle = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
        let systemVersion = UIDevice.current.systemVersion
        let text = "iOS \(systemVersion) Version \(version) Bundle \(bundle)"
        bundleLabel.text = text
    }
    
    func configurationButtons() {
        signOutButton.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        docsButton.addTarget(self, action: #selector(openDocs), for: .touchUpInside)
        hideUserButton.addTarget(self, action: #selector(hideUser), for: .touchUpInside)
        
        // Переделать)))
        Task(priority: .userInitiated) {
            do {
                let user = try await FirestoreService.shared.getCurrentUserData()
                if !user.isHide {
                    self.hideUserButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
                } else {
                    self.hideUserButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
                }
            } catch {
                self.showAlert(with: "Error", and: #function + error.localizedDescription)
            }
        }
    }
    
    func configurationLayout() {
        view.addSubview(gradientView)
        gradientView.edgesToSuperview()
        view.addSubview(logoLabel)
        
        logoLabel.topToSuperview(offset: 10, relation: .equalOrGreater, usingSafeArea: true)
        logoLabel.topToSuperview(offset: 40, relation: .equalOrLess, usingSafeArea: true)
        logoLabel.leftToSuperview()
        logoLabel.rightToSuperview()
        
        view.addSubview(birdView)
        birdView.topToBottom(of: logoLabel, offset: -60)
        birdView.leftToSuperview()
        birdView.rightToSuperview()
        
        let stack = UIStackView(arrangedSubviews: [labelCreate, bundleLabel, hideUserButton, docsButton, signOutButton], axis: .vertical, spacing: 15)
        view.addSubview(stack)
        
        hideUserButton.height(54)
        signOutButton.height(54)
        docsButton.height(54)
        
        stack.leftToSuperview(offset: 40)
        stack.rightToSuperview(offset: -40)
        stack.bottomToSuperview(offset: -10, usingSafeArea: true)
    }
    
}
