//
//  SignUpViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 08.11.2023.
//

import UIKit
import GoogleSignIn

class SignUpViewController: UIViewController {

    let welcomeLabel = UILabel(text: "Рады Вас видеть!", alignment: .center, fount: FontAppearance.firstTitle)
    let emailLabel = UILabel(text: "Email")
    let passwordLabel = UILabel(text: "Пароль")
    let confirmPasswordLabel = UILabel(text: "Подтверждения пароля")
    let alreadyOnboardLabel = UILabel(text: "Уже зарегестрированы?")
    
    let emailTextField = OneLineTextField(font: FontAppearance.defaultText)
    let passwordTextField = OneLineTextField(font: FontAppearance.defaultText)
    let confirmPasswordTextField = OneLineTextField(font: FontAppearance.defaultText)
    
    let signUpButton = UIButton(title: "Регистрация", titleColor: ColorAppearance.white.color(), backgroundColor: ColorAppearance.black.color())
    
    let googleButton = UIButton(title: "Google", titleColor: ColorAppearance.black.color(), backgroundColor: .white, isShodow: true)
    
    let loginButton: UIButton = {
        let loginButton = UIButton()
        loginButton.setTitle("Войти", for: .normal)
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
        googleButton.addTarget(self, action: #selector(signWithGoogle), for: .touchUpInside)
        
        setUpConstraints()
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(moveContentUp), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        signUpButton.addShine()
    }
    
    @objc private func signUpTapped() {
        AuthService.shared.register(email: emailTextField.text, password: passwordTextField.text, confirmPassword:  confirmPasswordTextField.text) { result in
            switch result {
            case .success(let user):
                self.showAlert(with: "Успешно", and: "Вы зарегестрированны!") {
                    self.present(SetupProfileViewController(currentUser: user), animated: true)
                }
                
            case .failure(let error):
                self.showAlert(with: "Ошибка!", and: error.localizedDescription)
            }
        }
    }
 
    @objc private func loginTapped() {
        self.dismiss(animated: true) {
            self.delegate?.toLoginVC()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = 0
                self.view.endEditing(true)
            }
        }
        super.touchesBegan(touches, with: event)
    }
    
    @objc func moveContentUp(notification: NSNotification) {
        let userInfo = notification.userInfo
        let keyboardFrame = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        let keyboardHeight = keyboardFrame!.size.height
        let emptySpaceHeight = view.frame.size.height - stackView.frame.maxY
        let converdContentHeight = keyboardHeight - emptySpaceHeight + 10
        view.frame.origin.y = -converdContentHeight
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
    
}

// MARK: Set Up Constraints
extension SignUpViewController {
    
    private func setUpConstraints() {
        let emailStackView = UIStackView(arrangedSubviews: [emailLabel, emailTextField], axis: .vertical, spacing: 0)
        let passwordStackView = UIStackView(arrangedSubviews: [passwordLabel, passwordTextField], axis: .vertical, spacing: 0)
        let confirmPasswordStackView = UIStackView(arrangedSubviews: [confirmPasswordLabel, confirmPasswordTextField], axis: .vertical, spacing: 0)
                
        stackView = UIStackView(arrangedSubviews: [
            emailStackView,
            passwordStackView,
            confirmPasswordStackView,
            signUpButton,
            googleButton
        ], axis: .vertical, spacing: 40)
        
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

