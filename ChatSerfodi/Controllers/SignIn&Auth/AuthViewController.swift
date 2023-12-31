//
//  ViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 21.10.2023.
//

import UIKit

class AuthViewController: UIViewController {

    let googleLabel = UILabel(text: "Get started with")
    let emailLabel = UILabel(text: "Or sign up with")
    let alreadyOnboardLabel = UILabel(text: "Alerady onboard?")
    
    let emailButton = UIButton(title: "Email", titleColor: .white, backgroundColor: .buttonDark(), isShodow: false)
    let loginButton = UIButton(title: "Login", titleColor: .bottonRed(), backgroundColor: .white, isShodow: true)
    let googleButton = UIButton(title: "Google", titleColor: .black, backgroundColor: .white, isShodow: true)
    
    let loginVC = LoginViewController()
    let signVC = SignUpViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        googleButton.customizeGoogleButton()
        setupConstraints()
        
        signVC.delegate = self
        loginVC.delegate = self
        
        emailButton.addTarget(self, action: #selector(emailButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }

    @objc private func emailButtonTapped() {
        present(signVC, animated: true)
    }
    
    @objc private func loginButtonTapped() {
        present(loginVC, animated: true)
    }
}


// MARK: AuthNavigatingDelegate

extension AuthViewController: AuthNavigatingDelegate {
    func toLoginVC() {
        present(loginVC, animated: true)
    }
    
    func toSignUPVC() {
        present(signVC, animated: true)
    }
}




// MARK: Set Up Constraints

extension AuthViewController {
    
    private func setupConstraints() {
        let googleView = ButtonFormView(label: googleLabel, button: googleButton)
        let emailView = ButtonFormView(label: emailLabel, button: emailButton)
        let loginView = ButtonFormView(label: alreadyOnboardLabel, button: loginButton)
        
        let stackView = UIStackView(arrangedSubviews: [googleView, emailView, loginView], axis: .vertical, spacing: 40)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
}



// MARK: SwiftUI

import SwiftUI

struct AuthVeiwControllerProvider: PreviewProvider {
    
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        let viewController = AuthViewController()
        
        func makeUIViewController(context: Context) -> some UIViewController {
            viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
        
    }
    
}
