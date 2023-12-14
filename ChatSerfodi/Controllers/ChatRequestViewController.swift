//
//  ChatRequestViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 28.11.2023.
//

import UIKit

class ChatRequestViewController: UIViewController {
    
    let containerView = UIView()
    let imageView = UIImageView(image: UIImage(named: "human1"))
    let nameLabel = UILabel(text: "Сергей", fount: .systemFont(ofSize: 20, weight: .light))
    let aboutLabel = UILabel(text: "You have the opportunity to chat with the best man in the world!", fount: .systemFont(ofSize: 16, weight: .light))
    
    let acceptButton = UIButton(title: "ACCEPT", titleColor: .white, backgroundColor: .black, fount: .laoSangamMN20(), isShodow: false, cornorRadius: 10)
    let denyButton = UIButton(title: "Deny", titleColor: .red, backgroundColor: .mainWhite(), fount: .laoSangamMN20(), isShodow: false, cornorRadius: 10)
    
    private var chat: SChat
    
    weak var delegate: WaitingChatsNavigation?
    
    init(chat: SChat) {
        self.chat = chat
        nameLabel.text = chat.friendUsername
        imageView.sd_setImage(with: URL(string: chat.friendUserImageString))
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeElements()
        setupConstraints()
        
        denyButton.addTarget(self, action: #selector(denyTapped), for: .touchUpInside)
        acceptButton.addTarget(self, action: #selector(acceptTapped), for: .touchUpInside)
    }
    
    @objc private func denyTapped() {
        dismiss(animated: true) {
            self.delegate?.removeWaitingChats(chat: self.chat)
        }
    }
    
    @objc private func acceptTapped() {
        dismiss(animated: true) {
            self.delegate?.chatToActive(chat: self.chat)
        }
    }
    
    
    private func customizeElements() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutLabel.translatesAutoresizingMaskIntoConstraints = false
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        denyButton.translatesAutoresizingMaskIntoConstraints = false
        
        denyButton.layer.borderWidth = 1.2
        denyButton.layer.borderColor = UIColor.red.cgColor
        
        aboutLabel.numberOfLines = 0
        
        containerView.backgroundColor = .mainWhite()
        containerView.layer.cornerRadius = 30
    }
}


// MARK: setup Constraints

extension ChatRequestViewController {
    
    private func setupConstraints() {
        
        view.addSubview(imageView)
        view.addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(aboutLabel)
        
        let buttonStackView = UIStackView(arrangedSubviews: [acceptButton, denyButton], axis: .horizontal, spacing: 7)
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.distribution = .fillEqually
        containerView.addSubview(buttonStackView)
        
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
            buttonStackView.topAnchor.constraint(equalTo: aboutLabel.bottomAnchor, constant: 24),
            buttonStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            buttonStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            buttonStackView.heightAnchor.constraint(equalToConstant:  56)
        ])
        
        
    }
}
