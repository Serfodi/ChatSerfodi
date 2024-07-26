//
//  SendProfileViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 26.07.2024.
//

import UIKit
import TinyConstraints

final class SendProfileViewController: UIViewController {

    private lazy var profileViewController = BaseProfileViewController(user: user)
    private let textView = InputTextView(frame: .zero, textContainer: nil)
    private let button = UIButton(type: .system)
    
    private lazy var height = textView.height(48)
    
    private lazy var container: UIVisualEffectView = {
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        blurEffectView.layer.cornerRadius = 24
        blurEffectView.clipsToBounds = true
        return blurEffectView
    }()
    
    
    // MARK: init
    
    private let user: SUser
    
    init(user: SUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Live circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
        NotificationCenter.default.addObserver(self, selector: #selector(moveContentUp), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    // MARK: Action
    
    @objc private func sendMessage() {
        print(#function)
        guard let message = textView.text, message != "" else { return }
        self.dismiss(animated: true) {
            do {
                try FirestoreService.shared.createWaitingChat(receiver: self.user, message: message)
                UIApplication.shared.getTopVC.showAlert(with: "Successfully", and: [NSLocalizedString("MessageFor", comment: ""), self.user.username, NSLocalizedString("sent", comment: "")].joined(separator: " "))
            } catch {
                UIApplication.shared.getTopVC.showAlert(with: "Error!", and: error.localizedDescription)
            }
        }
    }
    
    @objc func moveContentUp(notification: NSNotification) {
        let userInfo = notification.userInfo
        let keyboardFrame = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        let keyboardHeight = keyboardFrame!.size.height
        self.view.frame.origin.y = -keyboardHeight
    }
}

// MARK: UIScrollViewDelegate

extension SendProfileViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
            self.view.endEditing(true)
        }
    }
}

// MARK: Configuration
private extension SendProfileViewController {
    
    func configuration() {
        configurationView()
        configurationProfileViewController()
        configurationSendTextField()
        configurationConstraints()
    }
    
    func configurationView() {
        view.backgroundColor = ColorAppearance.clearWhite.color()
    }
    
    func configurationProfileViewController() {
        addChild(profileViewController)
        view.addSubview(profileViewController.view)
        profileViewController.didMove(toParent: self)
        profileViewController.scrollView.delegate = self
        profileViewController.scrollView.contentInset.bottom = 40
    }
 
    func configurationSendTextField() {
        textView.placeholder = NSLocalizedString("FirstMessage", comment: "")
        textView.isScrollEnabled = false
        textView.delegate = self
        
        textView.layer.cornerRadius = 18
        
        let image = UIImage(systemName: "arrow.up.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40))
        button.setBackgroundImage(image, for: .normal)
        button.tintColor = ColorAppearance.blue.color()
        button.addTarget(self, action:  #selector(sendMessage), for: .touchUpInside)
        button.size(CGSize(width: 40, height: 40))
        button.aspectRatio(1)
    }
    
    func configurationConstraints() {
        view.addSubview(container)
        
        container.contentView.addSubview(textView)
        container.contentView.addSubview(button)
        
        container.bottomToSuperview()
        container.leftToSuperview()
        container.rightToSuperview()
        
        button.topToSuperview(offset: 11)
        button.rightToSuperview(offset: -11)
        
        textView.right(to: button, button.leftAnchor, offset: -4)
        textView.topToSuperview(offset: 12)
        textView.bottomToSuperview(offset: -12)
        textView.leftToSuperview(offset: 12)
        
        profileViewController.view.topToSuperview()
        profileViewController.view.leftToSuperview()
        profileViewController.view.rightToSuperview()
        profileViewController.view.bottom(to: container, container.topAnchor, offset: 40)
    }
}

// MARK: UITextViewDelegate

extension SendProfileViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        textView.text = textView.text.trimmingCharacters(in: .newlines)
        
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
        
        if size.height != newSize.height {
            height.constant = newSize.height
            UIView.animate(withDuration: 0.2) {
                textView.layoutIfNeeded()
            }
        }
    }
}
