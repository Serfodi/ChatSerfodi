//
//  ActiveChatCell.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 17.11.2023.
//

import UIKit
import SDWebImage

class ActiveChatCell: UICollectionViewCell, SelfConfiguringCell {
    
    
    static var reuseId: String = "ActiveChatCell"
    
    let frendImageView = UIImageView()
    let frindName = UILabel(text: "User name", fount:  .laoSangamMN20())
    let lastMassege = UILabel(text: "How a you", fount:  .laoSangamMN18())
    let gradientView = GradientView(from: .topTrailing, to: .bottomLeading , startColor: .purple, endColor: .blue)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupConstraints()
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure<U>(with value: U) where U : Hashable {
        guard let value: SChat = value as? SChat else { return }
        frindName.text = value.friendUsername
        lastMassege.text = value.lastMessage
        frendImageView.sd_setImage(with: URL(string: value.friendUserImageString))
    }
    
}
 

// MARK: - Setup constraints

extension ActiveChatCell {
    
    private func setupConstraints() {
        frendImageView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        frindName.translatesAutoresizingMaskIntoConstraints = false
        lastMassege.translatesAutoresizingMaskIntoConstraints = false
        
        frendImageView.backgroundColor = .red
        gradientView.backgroundColor = .blue
        
        addSubview(frendImageView)
        addSubview(gradientView)
        addSubview(lastMassege)
        addSubview(frindName)
        
        NSLayoutConstraint.activate([
            frendImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            frendImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            frendImageView.heightAnchor.constraint(equalToConstant: 78),
            frendImageView.widthAnchor.constraint(equalToConstant: 78)
        ])
        
        NSLayoutConstraint.activate([
            gradientView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            gradientView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 78),
            gradientView.widthAnchor.constraint(equalToConstant: 8)
        ])
        
        NSLayoutConstraint.activate([
            frindName.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            frindName.leadingAnchor.constraint(equalTo: frendImageView.trailingAnchor, constant: 16),
            frindName.trailingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 16)
        ])
     
        NSLayoutConstraint.activate([
            lastMassege.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16),
            lastMassege.leadingAnchor.constraint(equalTo: frendImageView.trailingAnchor, constant: 16),
            lastMassege.trailingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 16)
        ])
    }
    
}
