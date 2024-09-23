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
import FirebaseAuth

final class AuthViewController: UIViewController {
        
    private lazy var privateVC = WebViewController(page: .privacyHTML)
    private lazy var termVC = WebViewController(page: .termsHTML)
    private lazy var licenseVC = WebViewController(page: .licenseHTML)
    
    private let gradientView = GradientView(from: .topTrailing, to: .bottomLeading , startColor: ColorAppearance.white.color(), endColor: ColorAppearance.blue.color())
    private let logoLabel = UILabel(text: "Щебетарь", fount: FontAppearance.logoTitle, color: ColorAppearance.black.color())
    private let welcomeLabel = UILabel(text: "Welcome", alignment: .center, fount: FontAppearance.firstTitle, color: ColorAppearance.black.color())
    private let appleButton = ASAuthorizationAppleIDButton.init(authorizationButtonType: .default, authorizationButtonStyle: .white)
    private let googleButton = UIButton(title: " " + "Sign in with Google".localized(),
                                        titleColor: ColorAppearance.clearBlack.color(),
                                        backgroundColor: ColorAppearance.clearWhite.color(), 
                                        fount: FontAppearance.loginFont,
                                        cornerRadius: 10, image: UIImage(named: "google"))
    private let birdView = BirdView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
        NotificationCenter.default.addObserver(self, selector: #selector(handleModalClosed), name: NSNotification.Name("PrivacyViewControllerModalClosed"), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        birdView.play()
    }
    
    @objc func handleModalClosed() {
        showAlertAgree()
    }
    
    @objc func signWithGoogle() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            AuthService.shared.googleLogin(user: result?.user, error: error) { result in
                switch result {
                case .success(let user):
                    self.asyncLoginUser(user)
                case .failure(let error):
                    print(#function + error.localizedDescription)
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
    
    func asyncLoginUser(_ user: User) {
        Task {
            do {
                let sUser = try await FirestoreService.shared.getUserData(user: user)
                self.showAlertAgree {
                    let mainTabBar = MainTabBarController(sUser: sUser)
                    mainTabBar.modalPresentationStyle = .fullScreen
                    self.present(mainTabBar, animated: true)
                }
            } catch {
                self.showAlertAgree {
                    self.present(SetupProfileViewController(currentUser: user), animated: true)
                }
            }
        }
    }
    
    func showAlertAgree(completion: @escaping () -> Void = {} ) {
        let alertController = UIAlertController(title: "Usage Agreement".localized(), message: "Please review".localized(), preferredStyle: .alert)
        let privacyPolicy = UIAlertAction(title: "Privacy".localized(), style: .default) { (_) in
            self.present(self.privateVC, animated: true)
        }
        let EULOAction = UIAlertAction(title: "EULO".localized(), style: .default) { (_) in
            self.present(self.licenseVC, animated: true)
        }
        let tersmAction = UIAlertAction(title: "Terms".localized(), style: .default) { (_) in
            self.present(self.termVC, animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .destructive) { (_) in
            Task {
                await FirestoreService.shared.deleteUser()
            }
        }
        let okAction = UIAlertAction(title: "Yes, agree".localized(), style: .default) { (_) in
            completion()
        }
        alertController.addAction(privacyPolicy)
        alertController.addAction(EULOAction)
        alertController.addAction(tersmAction)
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
}

extension AuthViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        self.showAlert(with: "Error", and: "Authorization error")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredentials = authorization.credential as? ASAuthorizationAppleIDCredential else {
            print("AppleAuthorization failed: AppleID credential not available")
            return
        }
        Task {
            do {
                let user = try await AuthService.shared.appleAuth(appleIDCredentials, nonce: AppleSignInManager.nonce)
                self.asyncLoginUser(user)
            } catch {
                print(error.localizedDescription)
//                self.showAlert(with: "Error", and: error.localizedDescription)
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
