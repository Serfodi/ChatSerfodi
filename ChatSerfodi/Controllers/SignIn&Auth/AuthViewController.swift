//
//  ViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 21.10.2023.
//

import UIKit
import Lottie

class AuthViewController: UIViewController {
    
    let gradientView = GradientView(from: .topTrailing, to: .bottomLeading , startColor: ColorAppearance.white.color(), endColor: ColorAppearance.blue.color())

    let logoLabel = UILabel(text: "Щебетарь", fount: FontAppearance.logoTitle, color: ColorAppearance.black.color())
    let welcomLabel = UILabel(text: "Добро пожаловать!", fount: FontAppearance.firstTitle, color: ColorAppearance.black.color())
    
    var birdView: LottieAnimationView! = {
        let duckView = LottieAnimationView(name: "Bird")
        duckView.loopMode = .loop
        duckView.contentMode = .scaleAspectFill
        return duckView
    }()
    var sunView = SunView()
        
    let emailButton = UIButton(title: "Регистрация", titleColor: ColorAppearance.white.color(), backgroundColor: ColorAppearance.black.color(), cornorRadius: 27)
    let loginButton = UIButton(title: "Вход", titleColor: ColorAppearance.black.color(), backgroundColor: ColorAppearance.white.color(), cornorRadius: 27)
    
    let loginVC = LoginViewController()
    let signVC = SignUpViewController()
    
    // MARK: Live Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(gradientView)
        setupConstraints()
        signVC.delegate = self
        loginVC.delegate = self
        emailButton.addTarget(self, action: #selector(emailButtonTapped), for: .touchUpInside)
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

// MARK: Set Up Constraints
extension AuthViewController {
    
    private func setupConstraints() {
        self.view.addSubview(sunView)
        self.view.addSubview(logoLabel)
        self.view.addSubview(birdView)
        
        logoLabel.translatesAutoresizingMaskIntoConstraints = false
        birdView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            logoLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            logoLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10)
        ])
        NSLayoutConstraint.activate([
            birdView.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: -35),
            birdView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            birdView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 35),
        ])
        let aspectRatioConstraint = NSLayoutConstraint(item: birdView!, attribute: .width, relatedBy: .equal, toItem: birdView!, attribute: .height, multiplier: 1.0, constant: 0)
        birdView.addConstraint(aspectRatioConstraint)
                
        let stackView = UIStackView(arrangedSubviews: [welcomLabel, emailButton, loginButton], axis: .vertical, spacing: 25)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(stackView)
        
        welcomLabel.centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
        welcomLabel.textAlignment = .center
        emailButton.addConstraint(.init(item: emailButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 54))
        loginButton.addConstraint(.init(item: loginButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 54))
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: birdView.bottomAnchor, constant: -25),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50)
        ])
    }
}
