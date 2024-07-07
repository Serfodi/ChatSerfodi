//
//  ChatRequestViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 28.11.2023.
//

import UIKit

class ChatRequestViewController: UIViewController {
    
    let containerView: UIView = {
        let view = UIView()
        view.addBlur(blur: .init(style: .regular))
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    let imageView = UIImageView(image: UIImage(named: "human1"))
    let nameLabel = UILabel(text: "Сергей", fount: FontAppearance.defaultBoldText)
    let aboutLabel = UILabel(text: "У вас есть возможность пообщаться с самым лучшим человеком в мире!")
    
    let acceptButton = UIButton(title: "Принять", titleColor: ColorAppearance.white.color(), backgroundColor: ColorAppearance.black.color())
    let denyButton = UIButton(title: "Отклонить", titleColor: .red, backgroundColor: ColorAppearance.white.color())
    
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
        
        view.backgroundColor = ColorAppearance.white.color()
        
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
            imageView.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: 20)
        ])
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 195)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
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
        ])
        
        
    }
}
