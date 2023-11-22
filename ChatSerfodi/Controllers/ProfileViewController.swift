//
//  ProfileViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 22.11.2023.
//

import UIKit

class ProfileViewController: UIViewController {
    
    let containerView = UIView()
    let imageView = UIImageView(image: UIImage(named: "human1"))
    let nameLabel = UILabel(text: "Сергей", fount: .systemFont(ofSize: 20, weight: .light))
    let aboutLabel = UILabel(text: "You have the opportunity to chat with the best man in the world!", fount: .systemFont(ofSize: 16, weight: .light))
    let myTextField = InsertableTextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mainWhite()
        setupConstraints()
    }
    
    @objc private func sendMessage() {
        print(#function)
    }
}

extension ProfileViewController {
    
    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutLabel.translatesAutoresizingMaskIntoConstraints = false
        myTextField.translatesAutoresizingMaskIntoConstraints = false
        
        if let button = myTextField.rightView as? UIButton  {
            button.addTarget(self, action:  #selector(sendMessage), for: .touchUpInside)
        }
        
        aboutLabel.numberOfLines = 0
        containerView.backgroundColor = .mainWhite()
        containerView.layer.cornerRadius = 30
        
        view.addSubview(imageView)
        view.addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(aboutLabel)
        containerView.addSubview(myTextField)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: 30)
        ])
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 206)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 35),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24)
        ])
        
        NSLayoutConstraint.activate([
            aboutLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            aboutLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            aboutLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24)
        ])
        
        NSLayoutConstraint.activate([
            myTextField.topAnchor.constraint(equalTo: aboutLabel.bottomAnchor, constant: 8),
            myTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            myTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            myTextField.heightAnchor.constraint(equalToConstant:  48)
        ])
    }
    
}








// MARK: - SwiftUI


import SwiftUI

struct ProfileViewControllerProvider: PreviewProvider {
    
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        let viewController = ProfileViewController()
        
        func makeUIViewController(context: Context) -> some ProfileViewController {
            viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    }
}
