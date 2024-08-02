//
//  ViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 21.10.2023.
//

import UIKit
import TinyConstraints
import GoogleSignIn

final class AuthViewController: UIViewController {
        
    private let gradientView = GradientView(from: .topTrailing, to: .bottomLeading , startColor: ColorAppearance.white.color(), endColor: ColorAppearance.blue.color())
    private let logoLabel = UILabel(text: "Щебетарь", fount: FontAppearance.logoTitle, color: ColorAppearance.black.color())
    private let welcomeLabel = UILabel(text: "Welcome", alignment: .center, fount: FontAppearance.firstTitle, color: ColorAppearance.black.color())
    private let loginButton = UIButton(title: "Login", titleColor: ColorAppearance.white.color(), backgroundColor: ColorAppearance.black.color())
    private let googleButton = UIButton(title: "Google", titleColor: ColorAppearance.white.color(), backgroundColor: ColorAppearance.black.color())
    private let birdView = BirdView()
    
    // MARK: ViewController
    
    let loginVC = LoginViewController()
    
    // MARK: Live Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        birdView.play()
    }
    
    // MARK: Action
    
    @objc private func loginButtonTapped() {
        present(loginVC, animated: true)
    }
    
    @objc func signWithGoogle() {
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
    
}


// MARK: - Configuration

private extension AuthViewController {
    
    func configuration() {
        configurationButton()
        configurationConstraints()
    }
    
    func configurationButton() {
        googleButton.customizeGoogleButton()
        googleButton.addTarget(self, action: #selector(signWithGoogle), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    func configurationConstraints() {
        view.addSubview(gradientView)
        gradientView.edgesToSuperview()
        
        view.addSubview(logoLabel)
        view.addSubview(birdView)
        
        logoLabel.centerXToSuperview()
        logoLabel.topToSuperview(offset: 10, usingSafeArea: true)
        
        birdView.topToBottom(of: logoLabel, offset: -35)
        birdView.leftToSuperview()
        birdView.rightToSuperview()
        
        let stackView = UIStackView(arrangedSubviews: [welcomeLabel, loginButton, googleButton], axis: .vertical, spacing: 25)
        view.addSubview(stackView)
        googleButton.height(54)
        loginButton.height(54)
        
        stackView.topToBottom(of: birdView, offset: -25)
        stackView.leftToSuperview(offset: 50)
        stackView.rightToSuperview(offset: -50)
    }
}
