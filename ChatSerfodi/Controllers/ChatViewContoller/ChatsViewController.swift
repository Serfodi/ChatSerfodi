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

private enum Const {
    static let ImageRightMargin: CGFloat = 16
    static let ImageBottomMarginForLargeState: CGFloat = 12
    static let ImageBottomMarginForSmallState: CGFloat = 6
    static let ImageSize: CGFloat = 40
}

class ChatsViewController: MessagesViewController {
    
    private var imageFriend = UIImageView()
    private let titleLabel = UILabel(text: "name", alignment: .center, fount: FontAppearance.buttonText, color: ColorAppearance.black.color())
    private let subtitleLabel = UILabel(text: "был недавно", alignment: .center, fount: FontAppearance.small, color: ColorAppearance.black.color())
    
    private var fullScreenTransitionManager: FullScreenTransitionManager?
    
    private var messages = [SMessage]()
    
    private var messageListener: ListenerRegistration?
    private var chatListener: ListenerRegistration?
    private var userListener: ListenerRegistration?
    
    private var user: SUser {
        FirestoreService.shared.currentUser
    }
    private var chat: SChat
    
    // DateFormatter
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter
    }()
    
    let dateFormatterDay: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM"
        return dateFormatter
    }()
    
    let dateFormatterLast: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM, HH:mm"
        return dateFormatter
    }()
    
    
    // MARK: init
    
    init(chat: SChat) {
        self.chat = chat
        super.init(nibName: nil, bundle: nil)
        titleLabel.text = chat.friendUsername
        if chat.typing != "nil" {
            subtitleLabel.text = chat.typing
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Live Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        configuration()
        // Listener
        setupMessageListener()
        setupChatListener()
        setupUserListener()
        
        
//        loadFirstMessages()
    }
    deinit {
        messageListener?.remove()
        chatListener?.remove()
        userListener?.remove()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        FirestoreService.shared.updateChatTyping(for: chat, typing: "nil")
    }
        
    // MARK: Listener
    
    private func setupMessageListener() {
        messageListener = ListenerService.shared.messagesObserve(chat: chat) { result in
            switch result {
            case .success(var message):
//                if let url = message.downloadURL {
//
//                    StorageService.shared.downloadImage(url: url) { [weak self] result in
//                        guard let self = self else { return  }
//                        switch result {
//                        case .success(let image):
//                            message.image = image
//                            self.insertNewMessage(message: message)
//                        case .failure(let error):
//                            self.showAlert(with: "Error", and: error.localizedDescription)
//                        }
//                    }
//
//                    self.insertNewMessage(message: message)
//                } else {
//                }
                self.insertNewMessage(message: message, animated: false)
                self.chat.lastMessage = message.descriptor
            case .failure(let error):
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        }
    }
    
    private func setupChatListener() {
        chatListener = ListenerService.shared.chatObserve(chatId: chat.friendId, completion: { result in
            switch result {
            case .success(let chat):
                let text = self.getStatus(isOnline: chat.isOnline, typing: chat.typing)
                if let text = text {
                    self.subtitleLabel.text = text
                }
            case .failure(let error):
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        })
    }
    
    private func setupUserListener() {
        userListener = ListenerService.shared.userObserver(userId: chat.friendId, completion: { result in
            switch result {
            case .success(let user):
                let text = self.getStatus(date: user.exitTime, isOnline: user.isOnline)
                if let text = text {
                    self.subtitleLabel.text = text
                }
            case .failure(let error):
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        })
    }
    
    
    // MARK: Message
    
    /// Делает вставку нового сообщения
    private func insertNewMessage(message: SMessage, animated: Bool = true) {
        guard !messages.contains(message) else { return }
        messages.append(message)
        messages.sort()
        let isLastMessage = messages.firstIndex(of: message) == (messages.count - 1)
        let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLastMessage
        self.messagesCollectionView.reloadData()
        if shouldScrollToBottom {
            DispatchQueue.main.async {
                self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: animated)
            }
        }
    }
    
    /// Отправляет фото
    private func sendPhoto(image: UIImage) {
        Task(priority: .userInitiated) {
            do {
                let url = try await StorageService.shared.uploadImageMessage(photo: image, to: chat)
                var imageMessage = SMessage(user: self.user, image: image)
                imageMessage.downloadURL = url
                try FirestoreService.shared.sendMessage(from: self.chat, message: imageMessage)
            }  catch {
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        }
    }
    
    private func insertMessage(_ message: SMessage) {
        messages.append(message)
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
//            messagesCollectionView.insertSections([messages.count - 1])
            messagesCollectionView.insertItems(at: [IndexPath(row: messages.count - 1, section: 0)])
            if messages.count >= 2 {
//                messagesCollectionView.reloadSections([messages.count - 2])
                messagesCollectionView.reloadItems(at: [IndexPath(row: messages.count - 2, section: 0)])
            }
        }, completion: { [weak self] _ in
            if self?.isLastItemVisible() == true {
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        })
    }
    
    // MARK: Action
    
    @objc func cameraIconTap() {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func openProfile() {
        Task(priority: .userInitiated) {
            do {
                let sUser = try await FirestoreService.shared.getUserData(id: chat.friendId)
                let vc = ProfileViewController(user: sUser)
                self.present(vc, animated: true)
            } catch {
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        }
    }
    
    // MARK: Helpers
    
    func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 { return true }
        return !messages[indexPath.row - 1].sentDate.compareDay(messages[indexPath.row].sentDate)
    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.row - 1 >= 0 else { return false }
        return messages[indexPath.row].sender.senderId == messages[indexPath.row - 1].sender.senderId && messages[indexPath.row - 1].sentDate.compareDay(messages[indexPath.row].sentDate)
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.row + 1 < messages.count else { return false }
        return messages[indexPath.row].sender.senderId == messages[indexPath.row + 1].sender.senderId && messages[indexPath.row + 1].sentDate.compareDay(messages[indexPath.row].sentDate)
    }
    
    
    func isLastItemVisible() -> Bool {
        guard !messages.isEmpty else { return false }
        let lastIndexPath = IndexPath(item: messages.count - 1, section: 0)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    func getStatus(date: Date? = nil, isOnline: Bool, typing: String = "nil") -> String? {
        if isOnline {
            if typing != "nil" {
                return typing
            }
            return NSLocalizedString("online", comment: "")
        } else {
            guard let date = date else { return nil }
            return dateFormatterLast.string(from: date)
        }
    }
}

// MARK: - MessageCellDelegate

extension ChatsViewController: MessageCellDelegate {
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        guard let message = self.messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: self.messagesCollectionView) else { return }
        if case MessageKind.photo(let media) = message.kind, let imageURL = media.url {
            
            StorageService.shared.downloadImage(url: imageURL) { [weak self] result in
                guard let self = self else { return  }
                switch result {
                case .success(let image):
                    guard let image = image else { return }
                    
                    let tag = indexPath.row + 1
                    let fullScreenTransitionManager = FullScreenTransitionManager(anchorViewTag: tag)
                    let fullScreenImageViewController = FullScreenImageViewController(image: image, tag: tag)
                    fullScreenImageViewController.modalPresentationStyle = .custom
                    fullScreenImageViewController.transitioningDelegate = fullScreenTransitionManager
                    self.present(fullScreenImageViewController, animated: true)
                    self.fullScreenTransitionManager = fullScreenTransitionManager
                    
                case .failure(let error):
                    self.showAlert(with: "Error", and: error.localizedDescription)
                }
            }
        }
        
    }
}


// MARK: - MessagesDisplayDelegate

extension ChatsViewController: MessagesDisplayDelegate {
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        if isFromCurrentSender(message: message) {
            return isNextMessageSameSender(at: indexPath) ? .bubble : .bubbleTail(.bottomRight, .curved)
        } else {
            return isNextMessageSameSender(at: indexPath) ? .bubble : .bubbleTail(.bottomLeft, .curved)
        }
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? ColorAppearance.blue.color() : ColorAppearance.gray.color()
    }
        
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? ColorAppearance.clearWhite.color() : ColorAppearance.black.color()
    }
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize? {
        .zero
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        imageView.tag = indexPath.row + 1
        if case MessageKind.photo(let media) = message.kind, let imageURL = media.url {
            StorageService.shared.downloadImage(url: imageURL) { [weak self] result in
                guard let self = self else { return  }
                switch result {
                case .success(let image):
                    imageView.image = image
                case .failure(let error):
                    self.showAlert(with: "Error", and: error.localizedDescription)
                }
            }
        }
    }
}


// MARK: - InputBarAccessoryViewDelegate

extension ChatsViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let message = SMessage(user: user, content: text)
        do {
            try FirestoreService.shared.sendMessage(from: self.chat, message: message)
            inputBar.inputTextView.text = ""
        } catch {
            self.showAlert(with: "Error", and: "NotSent")
            print("NotSent: \(error.localizedDescription)")
        }
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if text != "" {
            FirestoreService.shared.updateChatTyping(for: chat, typing: "пишет…")
        } else {
            FirestoreService.shared.updateChatTyping(for: chat, typing: "nil")
        }
    }
}


// MARK: - Messages Data Source

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

extension ChatsViewController: MessagesDataSource {
    
    func currentSender() -> MessageKit.SenderType {
        Sender(senderId: user.id, displayName: user.username)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        messages[indexPath.item]
    }
    
    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int { 1 }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: dateFormatterDay.string(from: message.sentDate), font: FontAppearance.Chat.topHeaderText)
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at _: IndexPath) -> NSAttributedString? {
        let dateString = dateFormatter.string(from: message.sentDate)
        if isFromCurrentSender(message: message) {
            return NSAttributedString(string: dateString, font: FontAppearance.Chat.bottomText, textColor: ColorAppearance.haveBlue.color())
        }
        return NSAttributedString(string: dateString, font: FontAppearance.Chat.bottomText, textColor: ColorAppearance.lightBlack.color())
    }
}


// MARK: - MessagesLayoutDelegate

extension ChatsViewController: MessagesLayoutDelegate {
    
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        CGSize(width: 0, height: 7)
    }

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        isTimeLabelVisible(at: indexPath) ? 30 : 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        -7
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in _: MessagesCollectionView) -> CGFloat {
        if isFromCurrentSender(message: message) {
            return isNextMessageSameSender(at: indexPath) ? 0 : 15
        } else {
            return isNextMessageSameSender(at: indexPath) ? 0 : 15
        }
    }
}


// MARK: - UIImagePickerControllerDelegate

extension ChatsViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        sendPhoto(image: image)
    }
}


// MARK: - UINavigationControllerDelegate

extension ChatsViewController: UINavigationControllerDelegate {}

// MARK: - Configuration

private extension ChatsViewController {
    
    func configuration() {
        self.tabBarController?.tabBar.isHidden = true
        configurationCollectionMessage()
        configureMessageInputBar()
        configurationLayout()
        configurationProfileInNavigationBar()
    }
    
    func configurationCollectionMessage() {
//        self.messagesCollectionView.backgroundColor = ColorAppearance.white.color()
    }
    
    func configureMessageInputBar() {
        configInputBar()
        configSendButton()
        configPaperclipButton()
    }
    
    func configInputBar() {
        messageInputBar.inputTextView.placeholder = NSLocalizedString("Message", comment: "")
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.layer.cornerRadius = 18
        messageInputBar.inputTextView.layer.borderWidth = 0.6
        messageInputBar.separatorLine.isHidden = true
        // Color
        messageInputBar.inputTextView.backgroundColor = ColorAppearance.clearWhite.color()
        messageInputBar.inputTextView.placeholderTextColor = ColorAppearance.lightBlack.color()
        messageInputBar.inputTextView.layer.borderColor = ColorAppearance.lightBlack.color().cgColor
        // Font
        messageInputBar.inputTextView.font = FontAppearance.Chat.text
        messageInputBar.inputTextView.textColor = ColorAppearance.black.color()
        // UIEdgeInsets
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 10)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 7, left: 13, bottom: 7, right: 12)
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 7, left: 0, bottom: 7, right: 0)
    }
    
    func configSendButton() {
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        let image =  UIImage(systemName: "arrow.up.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 36))
        messageInputBar.sendButton.setImage(image, for: .normal)
        messageInputBar.sendButton.title = nil
    }
    
    func configPaperclipButton() {
        let cameraIcon = InputBarButtonItem(type: .system)
        let cameraImage = UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 36))
        cameraIcon.image = cameraImage
        cameraIcon.tintColor = ColorAppearance.lightBlack.color()
        cameraIcon.addTarget(self, action: #selector(cameraIconTap), for: .primaryActionTriggered)
        cameraIcon.setSize(CGSize(width: 36, height: 36), animated: false)
        messageInputBar.leftStackView.alignment = .leading
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([cameraIcon], forStack: .left, animated: true)
    }
    
    func configurationLayout() {
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
            layout.photoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.photoMessageSizeCalculator.incomingAvatarSize = .zero
            layout.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(
                textAlignment: .right,
                textInsets: UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 10)))
            layout.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment(
                textAlignment: .left,
                textInsets: UIEdgeInsets(top: 4, left: 10, bottom: 0, right: 0)))
        }
    }
    
    func configurationProfileInNavigationBar() {
        imageFriend.sd_setImage(with: URL(string: self.chat.friendUserImageString))
        let rightButton = UIBarButtonItem(customView: imageFriend)
        rightButton.action = #selector(openProfile)
        navigationItem.rightBarButtonItem = rightButton
        imageFriend.layer.cornerRadius = Const.ImageSize / 2
        imageFriend.clipsToBounds = true
        imageFriend.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageFriend.heightAnchor.constraint(equalToConstant: Const.ImageSize),
            imageFriend.widthAnchor.constraint(equalTo: imageFriend.heightAnchor)
        ])
        titleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.adjustsFontSizeToFitWidth = true
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        let button = UIButton(frame: titleView.bounds)
        button.addTarget(self, action: #selector(openProfile), for: .touchUpInside)
        titleLabel.frame = CGRect(x: 0, y: -8, width: 200, height: 44)
        titleLabel.isUserInteractionEnabled = true
        titleView.insertSubview(titleLabel, at: 0)
        subtitleLabel.frame = CGRect(x: 0, y: 22, width: 200, height: 20)
        subtitleLabel.isUserInteractionEnabled = true
        titleView.insertSubview(subtitleLabel, at: 0)
        titleView.addSubview(button)
        navigationItem.titleView = titleView
        
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.isTranslucent = true
    }
}


// replay and forward: https://github.com/MessageKit/MessageKit/issues/1676
// full screen image: https://github.com/thomsmed/ios-examples/tree/main/FullScreenImageTransition

//func isLastSectionVisible() -> Bool {
//    guard !messageList.isEmpty else { return false }
//
//    let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
//
//    return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
//}
