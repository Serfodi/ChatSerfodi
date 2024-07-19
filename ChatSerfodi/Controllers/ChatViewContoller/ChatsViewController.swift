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
    /// Margin from right anchor of safe area to right anchor of Image
    static let ImageRightMargin: CGFloat = 16
    /// Margin from bottom anchor of NavBar to bottom anchor of Image for Large NavBar state
    static let ImageBottomMarginForLargeState: CGFloat = 12
    /// Margin from bottom anchor of NavBar to bottom anchor of Image for Small NavBar state
    static let ImageBottomMarginForSmallState: CGFloat = 6
    static let ImageSize: CGFloat = 40
}

class ChatsViewController: MessagesViewController {
    
    private var imageFriend = UIImageView()
    private let titleLabel = UILabel(text: "name", alignment: .center, fount: FontAppearance.buttonText, color: ColorAppearance.black.color())
    private let subtitleLabel = UILabel(text: "был недавно", alignment: .center, fount: FontAppearance.small, color: ColorAppearance.black.color())
    
    private var messages = [SMessage]()
    private var messageListener: ListenerRegistration?
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
//        self.user = user
        self.chat = chat
        super.init(nibName: nil, bundle: nil)
        titleLabel.text = chat.friendUsername
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
        setupUserListener()
    }
    deinit {
        messageListener?.remove()
        userListener?.remove()
    }
    
    // MARK: Listener
    
    private func setupMessageListener() {
        messageListener = ListenerService.shared.messagesObserve(chat: chat) { result in
            switch result {
            case .success(var message):
                if let url = message.downloadURL {
                    StorageService.shared.downloadImage(url: url) { [weak self] result in
                        guard let self = self else { return  }
                        switch result {
                        case .success(let image):
                            message.image = image
                            self.insertNewMessage(message: message)
                        case .failure(let error):
                            self.showAlert(with: "Error", and: error.localizedDescription)
                        }
                    }
                } else {
                    self.insertNewMessage(message: message)
                }
                self.chat.lastMessage = message.descriptor
            case .failure(let error):
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        }
    }
    
    private func setupUserListener() {
        userListener = ListenerService.shared.userObserver(userId: chat.friendId, completion: { result in
            switch result {
            case .success(let user):
                self.subtitleLabel.text = self.getStatus(date: user.exitTime, isOnline: user.isOnline)
            case .failure(let error):
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        })
    }
    
    // MARK: Message
    
    /// Делает вставку нового сообщения
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
    
    /// Отправляет фото
    private func sendPhoto(image: UIImage) {
        StorageService.shared.uploadImageMessage(photo: image, to: chat) { result in
            switch result {
            case .success(let url):
                var imageMessage = SMessage(user: self.user, image: image)
                imageMessage.downloadURL = url
                FirestoreService.shared.sendMessage(chat: self.chat, message: imageMessage) { result in
                    switch result {
                    case .success():
                        self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                    case .failure(_):
                        self.showAlert(with: "Error", and: "NotSent")
                    }
                }
            case .failure(let error):
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        }
    }
    
    
    // MARK: Action
    
    @objc func cameraIconTap() {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func openProfile() {
        FirestoreService.shared.getUserData(userId: chat.friendId) { result in
            switch result {
            case .success(let user):
                let vc = ProfileViewController(user: user)
                self.present(vc, animated: true)
            case .failure(let error):
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
    
    func getStatus(date: Date, isOnline: Bool) -> String {
        if isOnline {
            return NSLocalizedString("online", comment: "")
        } else {
            return dateFormatterLast.string(from: date)
        }
    }
    
}

// MARK: - MessageCellDelegate

extension ChatsViewController: MessageCellDelegate {
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        
        
        
        
        
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        print("Image tapped")
    }
    
    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("Accessory view tapped")
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
        isFromCurrentSender(message: message) ? .white : .black
    }
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize? {
        .zero
    }
}


// MARK: - InputBarAccessoryViewDelegate

extension ChatsViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let message = SMessage(user: user, content: text)
        FirestoreService.shared.sendMessage(chat: chat, message: message) { result in
            switch result {
            case .success():
                self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
            case .failure(let error):
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        }
        inputBar.inputTextView.text = ""
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
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return 1
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: dateFormatterDay.string(from: message.sentDate), attributes: [.font: FontAppearance.defaultText, .foregroundColor: UIColor.darkGray])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at _: IndexPath) -> NSAttributedString? {
        let dateString = dateFormatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [.font: UIFont.preferredFont(forTextStyle: .caption2)])
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
            return isNextMessageSameSender(at: indexPath) ? 0 : 12
        } else {
            return isNextMessageSameSender(at: indexPath) ? 0 : 12
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
        configureMessageInputBar()
        configurationTabBar()
        configurationLayout()
        configurationProfileInNavigationBar()
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
        messageInputBar.inputTextView.layer.borderWidth = 0.4
        messageInputBar.separatorLine.isHidden = true
        // Color
        messageInputBar.inputTextView.backgroundColor = ColorAppearance.clearWhite.color()
        messageInputBar.inputTextView.placeholderTextColor = ColorAppearance.black.color().withAlphaComponent(0.5)
        messageInputBar.inputTextView.layer.borderColor = ColorAppearance.black.color().withAlphaComponent(0.5).cgColor
        // Font
        messageInputBar.inputTextView.font = FontAppearance.Chat.text
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
        cameraIcon.addTarget(self, action: #selector(cameraIconTap), for: .primaryActionTriggered)
        cameraIcon.setSize(CGSize(width: 36, height: 36), animated: false)
        messageInputBar.leftStackView.alignment = .leading
        messageInputBar.setLeftStackViewWidthConstant(to: 48, animated: false)
        messageInputBar.setStackViewItems([cameraIcon], forStack: .left, animated: true)
        messageInputBar.topStackView.spacing = 18
    }
    
    func configurationTabBar() {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func configurationLayout() {
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
            layout.photoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.photoMessageSizeCalculator.incomingAvatarSize = .zero
            layout.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(
                textAlignment: .right,
                textInsets: UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 8)))
            layout.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment(
                textAlignment: .left,
                textInsets: UIEdgeInsets(top: 3, left: 8, bottom: 0, right: 0)))
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
    }
    
}



// replay and forward: https://github.com/MessageKit/MessageKit/issues/1676
