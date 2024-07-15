//
//  ViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 21.10.2023.
//

import UIKit
import Lottie

class AuthViewController: UIViewController {
    
    enum Padding {
        static let first: CGFloat = 50
        static let second: CGFloat = 25
        static let fixedAnimationView: CGFloat = 35
        static let top: CGFloat = 10
    }
    
    let gradientView = GradientView(from: .topTrailing, to: .bottomLeading , startColor: ColorAppearance.white.color(), endColor: ColorAppearance.blue.color())
    let logoLabel = UILabel(text: "Щебетарь", fount: FontAppearance.logoTitle, color: ColorAppearance.black.color())
    let welcomeLabel = UILabel(text: "Welcome", fount: FontAppearance.firstTitle, color: ColorAppearance.black.color())
    let signButton = UIButton(title: "Registration", titleColor: ColorAppearance.white.color(), backgroundColor: ColorAppearance.black.color())
    let loginButton = UIButton(title: "Login", titleColor: ColorAppearance.black.color(), backgroundColor: ColorAppearance.white.color())
    let birdView = LottieAnimationView(name: "Bird", contentMode: .scaleAspectFill)
    var sunView = SunView()
    
    // MARK: ViewController
    
    let loginVC = LoginViewController()
    let signVC = SignUpViewController()
    
    // MARK: Live Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorAppearance.blue.color()
        view.addSubview(gradientView)
        setupConstraints()
        signVC.delegate = self
        loginVC.delegate = self
        signButton.addTarget(self, action: #selector(emailButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        birdView.play()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.gradientView.frame = self.view.frame
        self.sunView.frame = birdView.frame
    }
    
    // MARK: Action
    
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


// MARK: Constraints
private extension AuthViewController {
    func setupConstraints() {
        self.view.addSubview(sunView)
        self.view.addSubview(logoLabel)
        self.view.addSubview(birdView)
        
        logoLabel.translatesAutoresizingMaskIntoConstraints = false
        birdView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            logoLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            logoLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: Padding.top)
        ])
        NSLayoutConstraint.activate([
            birdView.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: -Padding.fixedAnimationView),
            birdView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            birdView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: Padding.fixedAnimationView),
        ])
        let aspectRatioConstraint = NSLayoutConstraint(item: birdView, attribute: .width, relatedBy: .equal, toItem: birdView, attribute: .height, multiplier: 1.0, constant: 0)
        birdView.addConstraint(aspectRatioConstraint)
        
        let stackView = UIStackView(arrangedSubviews: [welcomeLabel, signButton, loginButton], axis: .vertical, spacing: Padding.second)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(stackView)
        
        welcomeLabel.centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
        welcomeLabel.textAlignment = .center
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: birdView.bottomAnchor, constant: -Padding.second),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Padding.first),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Padding.first)
        ])
    }
}
