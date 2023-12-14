//
//  ChatsViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 14.12.2023.
//

import UIKit
import MessageKit

class ChatsViewController: MessagesViewController {
    
    private var messages = [SMessage]()
    
    private let user: SUser
    private let chat: SChat
    
    init(user: SUser, chat: SChat) {
        self.user = user
        self.chat = chat
        super.init(nibName: nil, bundle: nil)
        
        title = chat.friendUsername
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMessageInputBar()
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func configureMessageInputBar() {
        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.backgroundView.backgroundColor = .mainWhite()
        messageInputBar.inputTextView.backgroundColor = .white
        
        messageInputBar.inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 14, left: 30, bottom: 14, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 14, left: 36, bottom: 14, right: 36)
        
        messageInputBar.inputTextView.layer.borderColor = UIColor(red: 200 / 255, green: 200 / 255, blue: 200 / 255, alpha: 1).cgColor
        messageInputBar.inputTextView.layer.borderWidth = 0.2
        messageInputBar.inputTextView.layer.cornerRadius = 18.0
   
        messageInputBar.inputTextView.tintColor = .mainWhite()
        messageInputBar.inputTextView.backgroundColor = .mainWhite()
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)
        
        messageInputBar.layer.shadowColor = UIColor.black.cgColor
        messageInputBar.layer.shadowRadius = 5
        messageInputBar.layer.shadowOpacity = 0.3
        messageInputBar.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        configureButton()
    }
    
    
    func configureButton() {
        messageInputBar.sendButton.image = UIImage(systemName: "paperplane.fill")
        messageInputBar.setRightStackViewWidthConstant(to: 56, animated: false)
        messageInputBar.sendButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 6, trailing: 38)
        messageInputBar.sendButton.setSize(CGSize(width: 48, height: 48), animated: false)
        messageInputBar.sendButton.title = ""
//        messageInputBar.middleContentViewPadding.right =
    }
    
}


// MARK: MessagesDataSource

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

extension ChatsViewController: MessagesDataSource {
    
    var currentSender: MessageKit.SenderType {
        Sender(senderId: user.id, displayName: user.username)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        messages[indexPath.item]
    }
    
    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return 1
    }
    
}
