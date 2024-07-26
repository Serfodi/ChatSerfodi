//
//  RequestViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 26.07.2024.
//

import UIKit
import TinyConstraints

final class RequestViewController: UIViewController {
    
    weak var delegate: WaitingChatsNavigation?
    
    private lazy var profileViewController = BaseProfileViewController(user: user)
    private let acceptButton = UIButton(title: "Accept", titleColor: ColorAppearance.white.color(), backgroundColor: ColorAppearance.black.color())
//    private let denyButton = UIButton(title: "Reject", titleColor: .red, backgroundColor: ColorAppearance.white.color())
    private let messageLabel = UILabel(text: "nil", fount: FontAppearance.Chat.text)
    
    // helpers
    
    private lazy var labelContainer: UIView = {
        let view = UIView()
        view.addSubview(messageLabel)
        messageLabel.edgesToSuperview(insets: .top(15) + .bottom(15) + .left(15) + .right(15))
        view.layer.cornerRadius = 24
        view.backgroundColor = ColorAppearance.gray.color()
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var container: UIVisualEffectView = {
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        blurEffectView.layer.cornerRadius = 24
        blurEffectView.clipsToBounds = true
        return blurEffectView
    }()
    
    private let denyButton : UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.backgroundColor = .clear
        button.tintColor = .red
        return button
    }()
    
    // MARK: init
    
    private let chat: SChat
    private let user: SUser
    
    init(user: SUser, chat: SChat) {
        self.user = user
        self.chat = chat
        super.init(nibName: nil, bundle: nil)
        messageLabel.text = chat.lastMessage
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Live circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
    }
    
    // MARK: Action
    
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
    
}

// MARK: Configuration
private extension RequestViewController {
    
    func configuration() {
        configurationView()
        configurationButton()
        configurationProfileViewController()
        configurationConstraints()
    }
    
    func configurationView() {
        view.backgroundColor = ColorAppearance.clearWhite.color()
        
        messageLabel.numberOfLines = 0
        
    }
    
    func configurationProfileViewController() {
        addChild(profileViewController)
        view.addSubview(profileViewController.view)
        profileViewController.didMove(toParent: self)
        
        profileViewController.scrollView.contentInset.bottom = 40
    }
    
    func configurationButton() {
        denyButton.addTarget(self, action: #selector(denyTapped), for: .touchUpInside)
        acceptButton.addTarget(self, action: #selector(acceptTapped), for: .touchUpInside)
    }
    
    func configurationConstraints() {
        
//        profileViewController.view.edgesToSuperview()
        
        profileViewController.view.topToSuperview()
        profileViewController.view.leftToSuperview()
        profileViewController.view.rightToSuperview()
        
        view.addSubview(container)
        
//        container.height(<#T##height: CGFloat##CGFloat#>)
        
        let buttonStackView = UIStackView(arrangedSubviews: [acceptButton, denyButton], axis: .horizontal, spacing: 10)
        buttonStackView.distribution = .fill
        let stack = UIStackView(arrangedSubviews: [labelContainer, buttonStackView], axis: .vertical, spacing: 10)
        
        container.contentView.addSubview(stack)
        
        denyButton.size(CGSize(width: 48, height: 48))
        acceptButton.height(48)
        acceptButton.layer.cornerRadius = 24
        
        stack.edgesToSuperview(insets: .top(15) + .bottom(15) + .left(15) + .right(15))
        
//        stack.rightToSuperview(offset: -20)
//        stack.leftToSuperview(offset: 20)
//        stack.bottomToSuperview(offset: -15, usingSafeArea: true)
        
        container.top(to: profileViewController.view, profileViewController.view.bottomAnchor, offset: -40)
        
        container.rightToSuperview()
        container.leftToSuperview()
        container.bottomToSuperview()
        
    }
    
}
