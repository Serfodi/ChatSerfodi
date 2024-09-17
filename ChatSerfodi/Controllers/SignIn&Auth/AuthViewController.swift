//
//  ViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 21.10.2023.
//

import UIKit
import TinyConstraints
import GoogleSignIn
import AuthenticationServices

final class AuthViewController: UIViewController {
        
    private let gradientView = GradientView(from: .topTrailing, to: .bottomLeading , startColor: ColorAppearance.white.color(), endColor: ColorAppearance.blue.color())
    private let logoLabel = UILabel(text: "Щебетарь", fount: FontAppearance.logoTitle, color: ColorAppearance.black.color())
    private let welcomeLabel = UILabel(text: "Welcome", alignment: .center, fount: FontAppearance.firstTitle, color: ColorAppearance.black.color())
    private let appleButton = ASAuthorizationAppleIDButton.init(authorizationButtonType: .default, authorizationButtonStyle: .white)
    private let googleButton = UIButton(title: " " + "Sign in with Google",
                                        titleColor: ColorAppearance.clearBlack.color(),
                                        backgroundColor: ColorAppearance.clearWhite.color(), 
                                        fount: FontAppearance.loginFont,
                                        cornerRadius: 10, image: UIImage(named: "google"))
    private let birdView = BirdView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        birdView.play()
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
    
    @objc func signWithAppleId() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        AppleSignInManager.shared.requestAppleAuthorization(request)
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
}

extension AuthViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        self.showAlert(with: "Error", and: error.localizedDescription)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredentials = authorization.credential as? ASAuthorizationAppleIDCredential else {
            print("AppleAuthorization failed: AppleID credential not available")
            return
        }
        Task {
            do {
                let user = try await AuthService.shared.appleAuth(appleIDCredentials, nonce: AppleSignInManager.nonce)
                
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
                
            } catch {
                print("AppleAuthorization failed: \(error)")
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        }
    }
    
}

private extension AuthViewController {
    
    func configuration() {
        configurationButton()
        configurationView()
        configurationConstraints()
    }
    
    func configurationButton() {
        googleButton.addTarget(self, action: #selector(signWithGoogle), for: .touchUpInside)
        appleButton.addTarget(self, action: #selector(signWithAppleId), for: .touchUpInside)
    }
    
    func configurationView() {
        appleButton.cornerRadius = 10
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
        
        let stackView = UIStackView(arrangedSubviews: [welcomeLabel, appleButton, googleButton], axis: .vertical, spacing: 25)
        view.addSubview(stackView)
        googleButton.height(54)
        appleButton.height(54)
        
        stackView.topToBottom(of: birdView, offset: -25)
        stackView.leftToSuperview(offset: 50)
        stackView.rightToSuperview(offset: -50)
    }
}
