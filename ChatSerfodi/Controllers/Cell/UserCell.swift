//
//  UserCell.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 22.11.2023.
//

import UIKit

class UserCell: UICollectionViewCell, SelfConfiguringCell {
    
    static var reuseId: String = "user"
    
    let userImageVeiw = UIImageView()
    let userName = UILabel(text: "text", fount: .laoSangamMN20())
    let containerVeiw = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        setupConstraints()
        
        self.layer.shadowColor = UIColor(white: 0.78, alpha: 1).cgColor
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 4)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerVeiw.layer.cornerRadius =  6
        containerVeiw.clipsToBounds = true
    }
    
    
    func configure<U>(with value: U) where U : Hashable {
        guard let user: SUser = value as? SUser else { return }
        userImageVeiw.image = UIImage(named: user.avatarStringURL)
        userName.text = user.userName
    }
    
    private func setupConstraints() {
        userImageVeiw.translatesAutoresizingMaskIntoConstraints = false
        userName.translatesAutoresizingMaskIntoConstraints = false
        containerVeiw.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerVeiw)
        containerVeiw.addSubview(userImageVeiw)
        containerVeiw.addSubview(userName)
        
        NSLayoutConstraint.activate([
            containerVeiw.topAnchor.constraint(equalTo: self.topAnchor),
            containerVeiw.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerVeiw.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerVeiw.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            userImageVeiw.topAnchor.constraint(equalTo: containerVeiw.topAnchor),
            userImageVeiw.leadingAnchor.constraint(equalTo: containerVeiw.leadingAnchor),
            userImageVeiw.trailingAnchor.constraint(equalTo: containerVeiw.trailingAnchor),
            userImageVeiw.heightAnchor.constraint(equalTo: containerVeiw.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            userName.topAnchor.constraint(equalTo: userImageVeiw.bottomAnchor),
            userName.leadingAnchor.constraint(equalTo: containerVeiw.leadingAnchor, constant: 10),
            userName.trailingAnchor.constraint(equalTo: containerVeiw.trailingAnchor, constant: -10),
            userName.bottomAnchor.constraint(equalTo: containerVeiw.bottomAnchor)
        ])
        
    }
    
}
