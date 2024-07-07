//
//  LoginViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 08.11.2023.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController {

    let welcomeLabel = UILabel(text: "Добро пожаловать назад!", alignment: .center, fount: FontAppearance.firstTitle)
//    let loginWithLabel = UILabel(text: "Войти через")
    let orLabel = UILabel(text: "или", alignment: .center)
    let passwordLabel = UILabel(text: "Пароль")
    let needAnAccountLabel = UILabel(text: "Нужен акаунт?")
    let emailLabel = UILabel(text: "Email")
    
    
    let googleButton = UIButton(title: "Google", titleColor: ColorAppearance.black.color(), backgroundColor: .white, isShodow: true)
    let emailTextField = OneLineTextField(font: FontAppearance.defaultText)
    let passwordTextField = OneLineTextField(font: FontAppearance.defaultText)
    
    let loginButton = UIButton(title: "Войти", titleColor: ColorAppearance.white.color(), backgroundColor: ColorAppearance.black.color())
    
    let signUpButton: UIButton = {
        let loginButton = UIButton()
        loginButton.setTitle("Регистрация", for: .normal)
        loginButton.setTitleColor(ColorAppearance.blue.color(), for: .normal)
        loginButton.titleLabel?.font = FontAppearance.defaultBoldText
        return loginButton
    }()
    
    var stackView: UIStackView!
    
    weak var delegate: AuthNavigatingDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorAppearance.white.color()
        googleButton.customizeGoogleButton()
        setUpConstraints()
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signButtonTapped), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(signWithGoogle), for: .touchUpInside)
    }
    
    // MARK: Action
    
    @objc private func loginButtonTapped() {
        AuthService.shared.login(email: emailTextField.text, password: passwordTextField.text) { result in
            switch result {
            case .success(let user):
                self.showAlert(with: "Успешно", and: "Вы авторизованы! ") {
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
                self.showAlert(with: "Ошибка!", and: error.localizedDescription)
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
                            self.showAlert(with: "Успешно", and: "Вы вошли") {
                                let mainTabBar = MainTabBarController(currentUser: suser)
                                mainTabBar.modalPresentationStyle = .fullScreen
                                self.present(mainTabBar, animated: true)
                            }
                        case .failure(_):
                            self.showAlert(with: "Успешно", and: "Вы зарегестрированы") {
                                self.present(SetupProfileViewController(currentUser: user), animated: true)
                            }
                        }
                    }
                case .failure(let error):
                    self.showAlert(with: "Ошибка", and: error.localizedDescription)
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
        
        stackView = UIStackView(arrangedSubviews: [emailStackView, passwordStackView, buttonStack], axis: .vertical, spacing: 40)
        
        signUpButton.contentHorizontalAlignment = .leading
        let bottomStackView = UIStackView(arrangedSubviews: [
            needAnAccountLabel, signUpButton
        ], axis: .horizontal, spacing: 5)
        bottomStackView.alignment = .firstBaseline
        
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(welcomeLabel)
        view.addSubview(stackView)
        view.addSubview(bottomStackView)
        
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 60),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        NSLayoutConstraint.activate([
            bottomStackView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 30),
            bottomStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            bottomStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
    }
    
}
