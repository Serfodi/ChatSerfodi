//
//  ViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 25.07.2024.
//

import UIKit
import TinyConstraints

class BaseProfileViewController: UIViewController {

    public let scrollView = UIScrollView()
    public let imageView = UIImageView()
    private let nameLabel = UILabel(text: "nil", fount: FontAppearance.Profile.name)
    private let aboutLabel = UILabel(text: "nil", fount: FontAppearance.Profile.about)
        
    private var menuButton: MenuButton!
    
    // helper
    
    private var fullScreenTransitionManager: FullScreenTransitionManager?
    
    private let baseLabelView: UIVisualEffectView = {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        return visualEffectView
    }()
    
    // MARK: init
    
    private let user: SUser
    
    init(user: SUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        imageView.sd_setImage(with: URL(string: user.avatarStringURL))
        nameLabel.text = user.username
        aboutLabel.text = user.description
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Live circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let aspectRatio = imageView.intrinsicContentSize.width / imageView.intrinsicContentSize.height
        imageView.aspectRatio(aspectRatio)
    }
    
    
    // MARK: Action
    
    @objc func imageTap() {
        view.endEditing(true)
        let fullScreenTransitionManager = FullScreenTransitionManager(anchorViewTag: 1)
        let fullScreenImageViewController = FullScreenImageViewController(image: imageView.image!, tag: 1)
        fullScreenImageViewController.modalPresentationStyle = .custom
        fullScreenImageViewController.transitioningDelegate = fullScreenTransitionManager
        self.present(fullScreenImageViewController, animated: true)
        self.fullScreenTransitionManager = fullScreenTransitionManager
    }
}

// MARK: Configuration
private extension BaseProfileViewController {
    
    func configuration() {
        configurationView()
        configurationScrollView()
        configurationImageViewView()
        configurationLabel()
        configurationMenuButon()
        configurationConstraints()
    }
    
    func configurationView() {
        view.backgroundColor = ColorAppearance.white.color()
    }
    
    func configurationScrollView() {
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
    }
    
    func configurationImageViewView() {
        imageView.backgroundColor = ColorAppearance.gray.color()
        imageView.tag = 1
        imageView.contentMode = .scaleAspectFit
        imageView.setHugging(.defaultHigh, for: .horizontal)
        imageView.setCompressionResistance(.defaultHigh, for: .horizontal)
        imageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTap))
        imageView.addGestureRecognizer(tap)
    }
    
    func configurationLabel() {
        aboutLabel.numberOfLines = 0
    }
    
    func configurationMenuButon() {
        let action = UIAction(title: NSLocalizedString("Blocking", comment: ""), image: .init(systemName: "nosign"), attributes: .destructive) { action in
            Task(priority: .userInitiated) {
                await FirestoreService.shared.blockedUser(user: self.user)
                self.dismiss(animated: true) {
                    NotificationCenter.default.post(name: Notification.Name("DeleteUser"), object: nil, userInfo: ["User" : self.user])
                }
            }
            FirestoreService.shared.blockedClear(user: self.user)
        }
        menuButton = MenuButton(menuActions: [action])
    }
    
    func configurationConstraints() {
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        baseLabelView.contentView.addSubview(nameLabel)
        baseLabelView.contentView.addSubview(menuButton)
        scrollView.addSubview(baseLabelView)
        scrollView.addSubview(aboutLabel)
        
        scrollView.edgesToSuperview()
        
        imageView.topToSuperview()
        imageView.leadingToSuperview()
        imageView.trailingToSuperview()
        imageView.width(to: scrollView)
        
        baseLabelView.centerY(to: imageView, imageView.bottomAnchor)
        baseLabelView.leftToSuperview()
        baseLabelView.rightToSuperview()
        
        nameLabel.topToSuperview(offset: 10)
        nameLabel.bottomToSuperview(offset: -10)
        nameLabel.leftToSuperview(offset: 20)
        nameLabel.rightToLeft(of: menuButton)
        
        menuButton.topToSuperview()
        menuButton.rightToSuperview()
        menuButton.bottomToSuperview()
        menuButton.aspectRatio(1)
        
        aboutLabel.top(to: baseLabelView, baseLabelView.bottomAnchor, offset: 15)
        aboutLabel.leftToSuperview(offset: 20)
        aboutLabel.rightToSuperview(offset: -20)
        aboutLabel.bottomToSuperview(offset: -15)
    }
}
