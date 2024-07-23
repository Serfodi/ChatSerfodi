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
    
    let friendImageView = UIImageView()
    let friendName = UILabel(text: "User name", fount:  FontAppearance.defaultBoldText)
    let lastMassage = UILabel(text: "How a you", fount:  FontAppearance.secondDefault, color: ColorAppearance.black.color().withAlphaComponent(0.5))
    
    var onlineRound: UIView = {
        var view = UIView(frame: CGRect(origin: .zero,
                                        size: CGSize(width: 10, height: 10)))
        view.layer.cornerRadius = 5
        return view
    }()
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter
    }()
    
    var menuButton: MenuButton!
    
    var chat: SChat!
    
    
    // MARK: init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 20
        backgroundColor = .white
        
        setupConfiguration()
        setupConstraints()
        
        
        friendImageView.clipsToBounds = true
        friendImageView.layer.cornerRadius = 30
        friendImageView.contentMode = .scaleAspectFill
        
        self.layer.shadowColor = UIColor(white: 0.2, alpha: 0.5).cgColor
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure<U>(with value: U) where U : Hashable {
        guard let value: SChat = value as? SChat else { return }
        chat = value
        friendName.text = value.friendUsername
        let timeString = dateFormatter.string(from: value.lastDate)
        if value.typing != "nil" {
            lastMassage.text = value.typing
        } else {
            lastMassage.text = timeString + ": " + value.lastMessage
        }
        friendImageView.sd_setImage(with: URL(string: value.friendUserImageString))
        self.onlineRound.backgroundColor = value.isOnline ? .green : .clear
    }
        
}
 

// MARK: - Setup constraints

private extension ActiveChatCell {
    
    func setupConfiguration() {
        let action = UIAction(title: NSLocalizedString("Delete", comment: ""), image: .init(systemName: "trash.fill"), attributes: .destructive) { action in
            NotificationCenter.default.post(name: Notification.Name("DeleteChat"), object: nil, userInfo: ["Chat" : self.chat!])
        }
        menuButton = MenuButton(menuActions: [action])
    }
    
    func setupConstraints() {
        friendImageView.translatesAutoresizingMaskIntoConstraints = false
        friendName.translatesAutoresizingMaskIntoConstraints = false
        lastMassage.translatesAutoresizingMaskIntoConstraints = false
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        onlineRound.translatesAutoresizingMaskIntoConstraints = false
        
        friendImageView.backgroundColor = .red
        
        addSubview(friendImageView)
        addSubview(lastMassage)
        addSubview(friendName)
        addSubview(menuButton)
        addSubview(onlineRound)
        
        NSLayoutConstraint.activate([
            friendImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 9),
            friendImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            friendImageView.heightAnchor.constraint(equalToConstant: 60),
            friendImageView.widthAnchor.constraint(equalToConstant: 60)
        ])
        
        NSLayoutConstraint.activate([
            friendName.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            friendName.leadingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 16),
            friendName.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16)
        ])
     
        NSLayoutConstraint.activate([
            lastMassage.topAnchor.constraint(equalTo: self.friendName.bottomAnchor, constant: 2),
            lastMassage.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor),
            lastMassage.leadingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 16),
            lastMassage.trailingAnchor.constraint(equalTo: menuButton.leadingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            menuButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -9),
            menuButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            menuButton.heightAnchor.constraint(equalToConstant: 60),
            menuButton.widthAnchor.constraint(equalToConstant: 60)
        ])
        NSLayoutConstraint.activate([
            onlineRound.bottomAnchor.constraint(equalTo: friendImageView.bottomAnchor, constant: 2),
            onlineRound.trailingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 2),
            onlineRound.heightAnchor.constraint(equalToConstant: 10),
            onlineRound.widthAnchor.constraint(equalToConstant: 10)
        ])
    }
    
}

final class MenuButton: UIButton {
        
    let generator = UIImpactFeedbackGenerator(style: .medium)
    
    init(menuActions: [UIAction]) {
        super.init(frame: .zero)
        setup(action: menuActions)
        generator.prepare()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        generator.impactOccurred()
        return true
    }

    private func setup(action: [UIAction]) {
        let moreImage = UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20))
        menu = UIMenu(title: "", image: moreImage, identifier: nil, options: .destructive, children: action)
        if #available(iOS 16.0, *) {
            menu?.preferredElementSize = .large
        }
        setImage(moreImage, for: .normal)
        tintColor = ColorAppearance.black.color()
        showsMenuAsPrimaryAction = true
    }
    
}
