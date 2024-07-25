//
//  WaitingChatCell.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 17.11.2023.
//

import UIKit
import SDWebImage

class WaitingChatCell: UICollectionViewCell, SelfConfiguringCell {
    
    static var reuseId: String = "WaitingChatCell"
    
    let friendImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = ColorAppearance.gray.color()
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
        self.addSubview(friendImageView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        friendImageView.frame = self.bounds
    }
    
    func configure<U>(with value: U) where U : Hashable {
        guard let value: SChat = value as? SChat else { return }
        friendImageView.sd_setImage(with: URL(string: value.friendUserImageString))
    }
    
}
