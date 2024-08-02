//
//  LoginViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 08.11.2023.
//

import UIKit
import GoogleSignIn
import TinyConstraints

final class LoginViewController: UIViewController {
    
    private let welcomeLabel = UILabel(text: "WelcomeBack", alignment: .center, fount: FontAppearance.firstTitle)
    private let orLabel = UILabel(text: "or", alignment: .center)
    private let passwordLabel = UILabel(text: "Password")
    private let emailLabel = UILabel(text: "Email")
    private let googleButton = UIButton(title: "Google", titleColor: ColorAppearance.black.color(), backgroundColor: .white, isShadow: true)
    private let emailTextField = OneLineTextField(font: FontAppearance.defaultText)
    private let passwordTextField = OneLineTextField(font: FontAppearance.defaultText)
    private let loginButton = UIButton(title: "Login", titleColor: ColorAppearance.white.color(), backgroundColor: ColorAppearance.black.color())
    
    weak var delegate: AuthNavigatingDelegate?
    
    // MARK: Live Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorAppearance.white.color()
        configurationConstraints()
        googleButton.customizeGoogleButton()
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(signWithGoogle), for: .touchUpInside)
    }
    
    // MARK: Action
    
    @objc private func loginButtonTapped() {
        AuthService.shared.login(email: emailTextField.text, password: passwordTextField.text) { result in
            switch result {
            case .success(let user):
                self.showAlert(with: "Successfully", and: "YouAreLoggedIn") {
                    Task(priority: .userInitiated) {
                        do {
                            let suser = try await FirestoreService.shared.getUserData(user: user)
                            let mainTabBar = MainTabBarController(sUser: suser)
                            mainTabBar.modalPresentationStyle = .fullScreen
                            self.present(mainTabBar, animated: true)
                        } catch {
                            self.present(SetupProfileViewController(currentUser: user), animated: true)
                        }
                    }
                }
            case .failure(let error):
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        }
    }
    
    @objc private func signButtonTapped() {
        dismiss(animated: true) {
            self.delegate?.toSignUPVC()
        }
    }
    
    @objc private func signWithGoogle() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            AuthService.shared.googleLogin(user: result?.user, error: error) { result in
                switch result {
                case .success(let user):
                    Task(priority: .userInitiated) {
                        do {
                            let suser = try await FirestoreService.shared.getUserData(user: user)
                            self.showAlert(with: "Successfully", and: "YouAreLoggedIn") {
                                let mainTabBar = MainTabBarController(sUser: suser)
                                mainTabBar.modalPresentationStyle = .fullScreen
                                self.present(mainTabBar, animated: true)
                            }
                        } catch {
                            self.showAlert(with: "Successfully", and: "YouAreRegistered") {
                                self.present(SetupProfileViewController(currentUser: user), animated: true)
                            }
                        }
                    }
                case .failure(let error):
                    self.showAlert(with: "Error", and: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}

// MARK: - Configuration

private extension LoginViewController {
    
    enum Padding {
        static let first: CGFloat = 60
        static let second: CGFloat = 40
        static let third: CGFloat = 30
    }
    
    func configurationConstraints() {
        let emailStackView = UIStackView(arrangedSubviews: [emailLabel, emailTextField], axis: .vertical, spacing: 5)
        let passwordStackView = UIStackView(arrangedSubviews: [passwordLabel, passwordTextField], axis: .vertical, spacing: 5)
        let buttonStack = UIStackView(arrangedSubviews: [loginButton, orLabel, googleButton], axis: .vertical, spacing: 10)
        let stackView = UIStackView(arrangedSubviews: [emailStackView, passwordStackView, buttonStack], axis: .vertical, spacing: Padding.second)
        view.addSubview(welcomeLabel)
        view.addSubview(stackView)
        googleButton.height(54)
        loginButton.height(54)
        welcomeLabel.topToSuperview(offset: Padding.second)
        welcomeLabel.centerXToSuperview()
        stackView.topToBottom(of: welcomeLabel, offset: Padding.first)
        stackView.leadingToSuperview(offset: Padding.second)
        stackView.trailingToSuperview(offset: Padding.second)
    }
}
