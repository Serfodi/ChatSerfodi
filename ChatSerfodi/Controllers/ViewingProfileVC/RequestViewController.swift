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
    private let messageLabel = UILabel(text: "", fount: FontAppearance.Chat.text)
    
    
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
    
//    private lazy var messageLabelHeight = messageLabel.height(40)
    
    private lazy var container: UIVisualEffectView = {
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        blurEffectView.layer.cornerRadius = 24
        blurEffectView.clipsToBounds = true
        blurEffectView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
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
    
    @objc private func openFull() {
        messageLabel.numberOfLines = messageLabel.numberOfLines == 0 ? 1 : 0
    }
}

// MARK: Configuration
private extension RequestViewController {
    
    func configuration() {
        configurationView()
        configurationButton()
        configurationProfileViewController()
        configurationLabelContainer()
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
    
    func configurationLabelContainer() {
        let touch = UITapGestureRecognizer(target: self, action: #selector(openFull))
        labelContainer.addGestureRecognizer(touch)
    }
    
    func configurationButton() {
        denyButton.addTarget(self, action: #selector(denyTapped), for: .touchUpInside)
        acceptButton.addTarget(self, action: #selector(acceptTapped), for: .touchUpInside)
    }
    
    func configurationConstraints() {
        profileViewController.view.topToSuperview()
        profileViewController.view.leftToSuperview()
        profileViewController.view.rightToSuperview()
        
        view.addSubview(container)
        container.rightToSuperview()
        container.leftToSuperview()
        container.bottomToSuperview()
        container.top(to: profileViewController.view, profileViewController.view.bottomAnchor, offset: -40)
                
        container.contentView.addSubview(labelContainer)
        
        labelContainer.topToSuperview(offset: 15)
        labelContainer.leftToSuperview(offset: 15)
        labelContainer.rightToSuperview(offset: -15)
        
        let buttonStackView = UIStackView(arrangedSubviews: [acceptButton, denyButton], axis: .horizontal, spacing: 10)
        buttonStackView.distribution = .fill
        container.contentView.addSubview(buttonStackView)
        
        denyButton.size(CGSize(width: 48, height: 48))
        acceptButton.height(48)
        acceptButton.layer.cornerRadius = 24
        
        buttonStackView.topToBottom(of: labelContainer, offset: 15)
        buttonStackView.leftToSuperview(offset: 15)
        buttonStackView.rightToSuperview(offset: -15)
        buttonStackView.bottomToSuperview(offset: -15, usingSafeArea: true)
        
    }
    
}
