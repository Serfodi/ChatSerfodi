//
//  ChatsViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 14.12.2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore

class ChatsViewController: MessagesViewController {
    
    private var messages = [SMessage]()
    private var messageListener: ListenerRegistration?
    
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
        
        messagesCollectionView.backgroundColor = .mainWhite()
        
        
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        self.tabBarController?.tabBar.isHidden = true
        
        messageListener = ListenerService.shared.messagesObserve(chat: chat) { result in
            switch result {
            case .success(let message):
                self.insertNewMessage(message: message)
            case .failure(let error):
                self.showAlert(with: "Ошибка!", and: error.localizedDescription)
            }
        }
    }
    
    deinit {
        messageListener?.remove()
    }
    
    func configureMessageInputBar() {
        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        
        messageInputBar.backgroundView.backgroundColor = .mainWhite()
        messageInputBar.inputTextView.backgroundColor = .white
        messageInputBar.inputTextView.placeholderTextColor = ColorAppearance.black.color().withAlphaComponent(0.5)
        
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        messageInputBar.inputTextView.layer.cornerRadius = 21
   
        messageInputBar.inputTextView.layer.borderWidth = 0.3
        messageInputBar.inputTextView.layer.borderColor = ColorAppearance.black.color().withAlphaComponent(0.5).cgColor
        
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        messageInputBar.layer.shadowColor = UIColor.black.cgColor
        messageInputBar.layer.shadowRadius = 5
        messageInputBar.layer.shadowOpacity = 0.3
        messageInputBar.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        configureButton()
    }
    
    
    func configureButton() {
        
        messageInputBar.setRightStackViewWidthConstant(to: 42, animated: false)
        messageInputBar.sendButton.setSize(CGSize(width: 40, height: 35), animated: false)
//        messageInputBar.sendButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: -4, trailing: 0)
        
        messageInputBar.sendButton.contentMode = .scaleAspectFill
        
        messageInputBar.sendButton.backgroundColor = .blue
        
        let image =  UIImage(systemName: "arrow.up.message.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        
//        messageInputBar.sendButton.image = image
//        messageInputBar.sendButton.setImage(image, for: .normal)
        
        messageInputBar.sendButton.title = ""
    }
    
    private func insertNewMessage(message: SMessage) {
        guard !messages.contains(message) else { return }
        messages.append(message)
        messages.sort()
        
        let isLastMessage = messages.firstIndex(of: message) == (messages.count - 1)
        let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLastMessage
        
        messagesCollectionView.reloadData()
        
        if shouldScrollToBottom {
            DispatchQueue.main.async {
                self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
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
}


// MARK: - MessagesDataSource

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
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [
            NSAttributedString.Key.font: FontAppearance.defaultText,
                           NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }
    
    
    
}

// MARK: - MessagesLayoutDelegate

extension ChatsViewController: MessagesLayoutDelegate {
    
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        CGSize(width: 0, height: 4)
    }
}

extension ChatsViewController: MessagesDisplayDelegate {
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? .white : ColorAppearance.blue.color()
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? ColorAppearance.black.color() : .white
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize? {
        .zero
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        .bubble
    }
    
}

extension ChatsViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let message = SMessage(user: user, content: text)
        FirestoreService.shared.sendMessage(chat: chat, message: message) { result in
            switch result {
            case .success():
                self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
            case .failure(let error):
                self.showAlert(with: "Ошибка!", and: "Ошибка: \(error.localizedDescription)")
            }
        }
        inputBar.inputTextView.text = ""
    }
    
}
