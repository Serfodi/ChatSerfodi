//
//  SignUpViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 08.11.2023.
//

import UIKit
import GoogleSignIn

class SignUpViewController: UIViewController {

    enum Padding {
        static let first: CGFloat = 60
        static let second: CGFloat = 40
        static let third: CGFloat = 30
    }
    
    let welcomeLabel = UILabel(text: "GoodToSeeYou", alignment: .center, fount: FontAppearance.firstTitle)
    let emailLabel = UILabel(text: "Email")
    let passwordLabel = UILabel(text: "Password")
    let confirmPasswordLabel = UILabel(text: "PasswordConfirmation")
    let alreadyOnboardLabel = UILabel(text: "AlreadyRegistered")
    let emailTextField = OneLineTextField(font: FontAppearance.defaultText)
    let passwordTextField = OneLineTextField(font: FontAppearance.defaultText)
    let confirmPasswordTextField = OneLineTextField(font: FontAppearance.defaultText)
    let signUpButton = UIButton(title: "Registration", titleColor: ColorAppearance.white.color(), backgroundColor: ColorAppearance.black.color())
    let googleButton = UIButton(title: "Google", titleColor: ColorAppearance.black.color(), backgroundColor: .white, isShadow: true)
    let loginButton = UIButton(title: "Login", titleColor: ColorAppearance.blue.color(), fount: FontAppearance.defaultBoldText)
    
    weak var delegate: AuthNavigatingDelegate?
    
    // MARK: Live Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorAppearance.white.color()
        setupConstraints()
        googleButton.customizeGoogleButton()
        googleButton.addTarget(self, action: #selector(signWithGoogle), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
    }
    
    // MARK: Action
    
    @objc private func signUpTapped() {
        AuthService.shared.register(email: emailTextField.text, password: passwordTextField.text, confirmPassword:  confirmPasswordTextField.text) { result in
            switch result {
            case .success(let user):
                self.showAlert(with: "Successfully", and: "YouAreRegistered") {
                    self.present(SetupProfileViewController(currentUser: user), animated: true)
                }
            case .failure(let error):
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        }
    }
 
    @objc private func loginTapped() {
        self.dismiss(animated: true) {
            self.delegate?.toLoginVC()
        }
    }
    
    @objc func signWithGoogle() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            AuthService.shared.googleLogin(user: result?.user, error: error) { result in
                switch result {
                case .success(let user):
                    FirestoreService.shared.getUserData(user: user) { result in
                        switch result {
                        case .success(let suser):
                            self.showAlert(with: "Successfully", and: "YouAreLoggedIn") {
                                let mainTabBar = MainTabBarController(currentUser: suser)
                                mainTabBar.modalPresentationStyle = .fullScreen
                                self.present(mainTabBar, animated: true)
                            }
                        case .failure(_):
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
        if let _ = touches.first {
            self.view.endEditing(true)
        }
        super.touchesBegan(touches, with: event)
    }
}

// MARK: Set Up Constraints
extension SignUpViewController {
    
    private func setupConstraints() {
        let emailStackView = UIStackView(arrangedSubviews: [emailLabel, emailTextField], axis: .vertical, spacing: 0)
        let passwordStackView = UIStackView(arrangedSubviews: [passwordLabel, passwordTextField], axis: .vertical, spacing: 0)
        let confirmPasswordStackView = UIStackView(arrangedSubviews: [confirmPasswordLabel, confirmPasswordTextField], axis: .vertical, spacing: 0)
                
        let stackView = UIStackView(arrangedSubviews: [
            emailStackView,
            passwordStackView,
            confirmPasswordStackView,
            signUpButton,
            googleButton
        ], axis: .vertical, spacing: Padding.second)
        
        loginButton.contentHorizontalAlignment = .leading
        let bottomStackView = UIStackView(arrangedSubviews: [alreadyOnboardLabel, loginButton], axis: .horizontal, spacing: 5)
        bottomStackView.alignment = .firstBaseline
        
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(welcomeLabel)
        view.addSubview(stackView)
        view.addSubview(bottomStackView)
        
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: Padding.second),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: Padding.first),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Padding.second),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Padding.second)
        ])
        NSLayoutConstraint.activate([
            bottomStackView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: Padding.third),
            bottomStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Padding.second),
            bottomStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Padding.second)
        ])
    }
}
