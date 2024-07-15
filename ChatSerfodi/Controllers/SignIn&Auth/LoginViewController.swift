//
//  LoginViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 08.11.2023.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController {

    enum Padding {
        static let first: CGFloat = 60
        static let second: CGFloat = 40
        static let third: CGFloat = 30
    }
    
    let welcomeLabel = UILabel(text: "WelcomeBack", alignment: .center, fount: FontAppearance.firstTitle)
    let orLabel = UILabel(text: "or", alignment: .center)
    let passwordLabel = UILabel(text: "Password")
    let needAnAccountLabel = UILabel(text: "DoYouNeedAnAccount")
    let emailLabel = UILabel(text: "Email")
    let googleButton = UIButton(title: "Google", titleColor: ColorAppearance.black.color(), backgroundColor: .white, isShadow: true)
    let emailTextField = OneLineTextField(font: FontAppearance.defaultText)
    let passwordTextField = OneLineTextField(font: FontAppearance.defaultText)
    let loginButton = UIButton(title: "Login", titleColor: ColorAppearance.white.color(), backgroundColor: ColorAppearance.black.color())
    let signUpButton = UIButton(title: "Registration", titleColor: ColorAppearance.blue.color(), fount: FontAppearance.defaultBoldText)
    
    weak var delegate: AuthNavigatingDelegate?
    
    // MARK: Live Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorAppearance.white.color()
        setUpConstraints()
        googleButton.customizeGoogleButton()
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signButtonTapped), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(signWithGoogle), for: .touchUpInside)
    }
    
    // MARK: Action
    
    @objc private func loginButtonTapped() {
        AuthService.shared.login(email: emailTextField.text, password: passwordTextField.text) { result in
            switch result {
            case .success(let user):
                self.showAlert(with: "Successfully", and: "YouAreLoggedIn") {
                    FirestoreService.shared.getUserData(user: user) { result in
                        switch result {
                        case .success(let suser):
                            let mainTabBar = MainTabBarController(currentUser: suser)
                            mainTabBar.modalPresentationStyle = .fullScreen
                            self.present(mainTabBar, animated: true)
                        case .failure(_):
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
    
    @objc func signWithGoogle() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            AuthService.shared.googleLogin(user: result?.user, error: error) { result in
                switch result {
                case .success(let user):
                    FirestoreService.shared.getUserData(user: user) { result in
                        switch result {
                        case .success(let suser):
                            self.view.endEditing(true)
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
private extension LoginViewController {
    
    func setUpConstraints() {
        let emailStackView = UIStackView(arrangedSubviews: [emailLabel, emailTextField], axis: .vertical, spacing: 5)
        let passwordStackView = UIStackView(arrangedSubviews: [passwordLabel, passwordTextField], axis: .vertical, spacing: 5)
        let buttonStack = UIStackView(arrangedSubviews: [loginButton, orLabel, googleButton], axis: .vertical, spacing: 10)
        
        let stackView = UIStackView(arrangedSubviews: [emailStackView, passwordStackView, buttonStack], axis: .vertical, spacing: Padding.second)
        
        signUpButton.contentHorizontalAlignment = .leading
        let bottomStackView = UIStackView(arrangedSubviews: [needAnAccountLabel, signUpButton], axis: .horizontal, spacing: 5)
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
