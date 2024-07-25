//
//  ProfileViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 22.11.2023.
//

import UIKit
import SDWebImage

class ProfileViewController: UIViewController {
    
    let containerView: UIView = {
        let view = UIView()
        view.addBlur(blur: .init(style: .regular))
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    let imageView = UIImageView(image: UIImage(named: "human1"))
    let nameLabel = UILabel(text: "Name", fount: FontAppearance.defaultBoldText)
    let aboutLabel = UILabel(text: "You have the opportunity to chat with the best man in the world!")
    
    let myTextField = InsertableTextField()
    
    var stackView: UIStackView!
    
    private let user: SUser
    
    init(user: SUser) {
        self.user = user
        self.nameLabel.text = user.username
        self.aboutLabel.text = user.description
        self.imageView.sd_setImage(with: URL(string: user.avatarStringURL))
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorAppearance.white.color()
        setupConstraints()
        configuration()
        NotificationCenter.default.addObserver(self, selector: #selector(moveContentUp), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc private func sendMessage() {
        print(#function)
        guard let message = myTextField.text, message != "" else { return }
        self.dismiss(animated: true) {
            do {
                try FirestoreService.shared.createWaitingChat(receiver: self.user, message: message)
                UIApplication.shared.getTopVC.showAlert(with: "Successfully", and: [NSLocalizedString("MessageFor", comment: ""), self.user.username, NSLocalizedString("sent", comment: "")].joined(separator: " "))
            } catch {
                UIApplication.shared.getTopVC.showAlert(with: "Error!", and: error.localizedDescription)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = 0
                self.view.endEditing(true)
            }
        }
        super.touchesBegan(touches, with: event)
    }
    
    @objc func moveContentUp(notification: NSNotification) {
        let userInfo = notification.userInfo
        let keyboardFrame = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        let keyboardHeight = keyboardFrame!.size.height
//        let emptySpaceHeight = view.frame.size.height - stackView.frame.maxY
//        let converdContentHeight = keyboardHeight - emptySpaceHeight
        view.frame.origin.y = -keyboardHeight
    }
}

private extension ProfileViewController {
    
    func configuration() {
        aboutLabel.numberOfLines = 0
        if let button = myTextField.rightView as? UIButton  {
            button.addTarget(self, action:  #selector(sendMessage), for: .touchUpInside)
        }
    }
    
    func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        myTextField.translatesAutoresizingMaskIntoConstraints = false
        
        stackView = UIStackView(arrangedSubviews: [
            nameLabel,
            aboutLabel,
            myTextField
        ], axis: .vertical, spacing: 20)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        view.addSubview(containerView)
        view.addSubview(stackView)
        
        myTextField.heightAnchor.constraint(equalToConstant: 42).isActive = true
                
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: -20),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -140)
        ])
        
    }
    
}
