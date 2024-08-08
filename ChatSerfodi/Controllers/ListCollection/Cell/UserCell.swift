//
//  UserCell.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 22.11.2023.
//

import UIKit
import SDWebImage

class UserCell: UICollectionViewCell, SelfConfiguringCell {
    
    static var reuseId: String = "user"
    
    let userImageView = UIImageView()
    let containerView = UIView()
    
    let nameContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    let blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .extraLight)
        let blurView = UIVisualEffectView(effect: effect)
//        blurView.alpha = 0.4
        return blurView
    }()
    
    let textView = UIView()
    
    let userName = UILabel(text: "text", alignment: .center, fount: FontAppearance.defaultText)
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = ColorAppearance.clearWhite.color()
        
        textView.backgroundColor = .clear
        textView.layer.cornerRadius = 20
        textView.clipsToBounds = true
        
        userName.minimumScaleFactor = 0.5
        
        setupConstraints()
        
        self.layer.cornerRadius = 24
        
        self.layer.shadowColor = UIColor(white: 0.2, alpha: 0.5).cgColor
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius =  24
        containerView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        userImageView.image = nil
        userName.text = ""
    }
    
    
    func configure<U>(with value: U) where U : Hashable {
        guard let user: SUser = value as? SUser else { return }
        userImageView.image = UIImage(named: user.avatarStringURL)
        
        guard let url = URL(string: user.avatarStringURL) else { return }
        userImageView.sd_setImage(with: url)
        userName.text = user.username
    }
    
    private func setupConstraints() {
        userName.translatesAutoresizingMaskIntoConstraints = false
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        nameContainerView.translatesAutoresizingMaskIntoConstraints = false
        blurView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        containerView.addSubview(userImageView)
        containerView.addSubview(nameContainerView)
        nameContainerView.addSubview(textView)
        textView.addSubview(blurView)
        textView.addSubview(userName)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            userImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            userImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            userImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            userImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            nameContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            nameContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            nameContainerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            nameContainerView.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: nameContainerView.topAnchor, constant: 4),
            textView.leadingAnchor.constraint(equalTo: nameContainerView.leadingAnchor, constant: 4),
            textView.trailingAnchor.constraint(equalTo: nameContainerView.trailingAnchor, constant: -4),
            textView.bottomAnchor.constraint(equalTo: nameContainerView.bottomAnchor, constant: -4)
        ])
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: textView.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: textView.bottomAnchor)
        ])
                
        NSLayoutConstraint.activate([
            userName.topAnchor.constraint(equalTo: textView.topAnchor),
            userName.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
            userName.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
            userName.bottomAnchor.constraint(equalTo: textView.bottomAnchor)
        ])
        
    }
    
}
