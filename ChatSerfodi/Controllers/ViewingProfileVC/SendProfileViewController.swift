//
//  SendProfileViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 26.07.2024.
//

import UIKit
import TinyConstraints

enum WaitingChatState: String {
    case waiting
    case accept
    case non
}

protocol GoToAccept: AnyObject {
    func GoToAccept(user: SUser)
}


final class SendProfileViewController: UIViewController {

    private lazy var profileViewController = BaseProfileViewController(user: user)
    private let textView = InputTextView(font: FontAppearance.Chat.text,
                                         textColor: ColorAppearance.black.color(),
                                         backgroundColor: ColorAppearance.clearWhite.color(),
                                         textContainerInset: UIEdgeInsets(top: 8, left: 6, bottom: 8, right: 6))
    
    private let button = UIButton(type: .system)
    private var acceptButton: UIButton?
    
    private lazy var height = textView.height(48)
    
    private lazy var container: UIVisualEffectView = {
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
        blurEffectView.layer.cornerRadius = 24
        blurEffectView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        blurEffectView.clipsToBounds = true
        return blurEffectView
    }()
    
    private var stack: UIStackView!
    private lazy var currentLengthLabel = UILabel(text: String(currentLength), alignment: .center, fount: FontAppearance.small, color: ColorAppearance.black.color())
    
    private let maxLength = 400
    
    private var currentLength: Int {
        textView.text.count
    }
    
    weak var delegate: GoToAccept?
    
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
    }
     
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        acceptButton?.addShine()
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
    
    @objc private func goToAccepct() {
        dismiss(animated: true) {
            self.delegate?.GoToAccept(user: self.user)
        }
    }
    
}

// MARK: UIScrollViewDelegate

extension SendProfileViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
        
}

// MARK: Configuration
private extension SendProfileViewController {
    
    func configuration() {
        configurationView()
        configurationProfileViewController()
        configurationScrollView()
        configurationConstraints()
        configurationSendTextField()
        
        FirestoreService.shared.isWaitingChats(friendId: user.id) { result in
            switch result {
            case .success(let state):
                self.addLabelResponse(state: state)
            case .failure(let error):
                self.showAlert(with: "Error!", and: error.localizedDescription)
            }
        }
        
        //        configurationSendTextField()
    }
    
    func configurationView() {
        view.backgroundColor = ColorAppearance.white.color()
    }
    
    func configurationProfileViewController() {
        addChild(profileViewController)
        view.addSubview(profileViewController.view)
        profileViewController.didMove(toParent: self)
    }
 
    func configurationScrollView() {
        profileViewController.scrollView.delegate = self
        profileViewController.scrollView.contentInset.bottom = 40
    }
    
    
    func configurationSendTextField() {
        textView.placeholder = NSLocalizedString("FirstMessage", comment: "")
        textView.isScrollEnabled = false
        textView.delegate = self
        
        textView.layer.cornerRadius = 18
        textView.layer.borderWidth = 0.4
        
        let image = UIImage(systemName: "arrow.up", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
        button.setImage(image, for: .normal)
        button.tintColor = ColorAppearance.clearWhite.color()
        button.backgroundColor = ColorAppearance.blue.color()
        button.addTarget(self, action:  #selector(sendMessage), for: .touchUpInside)
        button.layer.cornerRadius = 18
        
        container.contentView.addSubview(textView)
        container.contentView.addSubview(button)
        
        textView.topToSuperview(offset: 12)
        textView.leftToSuperview(offset: 12)
        textView.rightToLeft(of: button, offset: -4)
        textView.bottom(to: view, view.keyboardLayoutGuide.topAnchor, offset: -12)
        
        button.topToSuperview(offset: 12)
        button.rightToSuperview(offset: -12)
        button.size(CGSize(width: 37, height: 37))
        button.aspectRatio(1)
        
        addCurrentCount()
    }
    
    func configurationConstraints() {
        view.addSubview(container)
        container.leftToSuperview()
        container.rightToSuperview()
        container.bottomToSuperview()
        
        profileViewController.view.topToSuperview()
        profileViewController.view.leftToSuperview()
        profileViewController.view.rightToSuperview()
        profileViewController.view.bottom(to: container, container.topAnchor, offset: 40)
    }
    
    // Helpers
    
    func addCurrentCount() {
        let label = UILabel(text: String(maxLength), alignment: .center, fount: FontAppearance.small, color: ColorAppearance.lightBlack.color())
        stack = UIStackView(arrangedSubviews: [label, currentLengthLabel], axis: .vertical, spacing: 0)
        container.contentView.addSubview(stack)
        stack.rightToSuperview(offset: -12)
        stack.leftToRight(of: textView, offset: 4)
        stack.bottomToSuperview(offset: -12)
        stack.height(min: 10, max: 40)
        stack.alpha = 0
    }
    
    func addLabelResponse(state: WaitingChatState) {
        switch state {
        case .waiting:
            self.textView.removeFromSuperview()
            self.button.removeFromSuperview()
            let label = UILabel(text: state.rawValue , alignment: .left, fount: FontAppearance.defaultText, color: ColorAppearance.black.color())
            container.contentView.addSubview(label)
            label.topToSuperview(offset: 12)
            label.leftToSuperview(offset: 12)
            label.rightToSuperview(offset: -12)
            label.bottomToSuperview(offset: -12, usingSafeArea: true)
        case .accept:
            self.textView.removeFromSuperview()
            self.button.removeFromSuperview()
            acceptButton = UIButton(title: state.rawValue, titleColor: ColorAppearance.clearWhite.color(), backgroundColor: ColorAppearance.blue.color(), cornerRadius: 19)
            acceptButton!.addTarget(self, action: #selector(goToAccepct), for: .touchUpInside)
            container.contentView.addSubview(acceptButton!)
            acceptButton!.height(38)
            acceptButton!.topToSuperview(offset: 12)
            acceptButton!.leftToSuperview(offset: 12)
            acceptButton!.rightToSuperview(offset: -12)
            acceptButton!.bottomToSuperview(offset: -12, usingSafeArea: true)
        case .non:
            break
        }
    }
    
}

// MARK: UITextViewDelegate

extension SendProfileViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        textView.text = String(textView.text.prefix(maxLength))
        currentLengthLabel.text = String(currentLength)
        textView.text = textView.text.trimmingCharacters(in: .newlines)
        
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
        
        if size.height != newSize.height {
            height.constant = newSize.height
            UIView.animate(withDuration: 0.2) {
                textView.layoutIfNeeded()
                self.stack.alpha = newSize.height > 120 ? 1 : 0
            }
        }
    }
    
}
