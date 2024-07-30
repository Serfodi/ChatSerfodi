//
//  ListViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 10.11.2023.
//

import UIKit
import FirebaseFirestore
import Lottie

private enum Padding {
    static let first: CGFloat = 60
    static let second: CGFloat = 40
    static let third: CGFloat = 20
    
    static let interSectionSpacing: CGFloat = 20
    
    enum ActiveChats {
        static let activeCellHeight:  CGFloat = 78
        static let interGroupSpacing: CGFloat = 10
        static let contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20)
    }
    enum WaitingChats {
        static let waitingChatsHeight: CGFloat = 88
        static let interGroupSpacing: CGFloat = 16
        static let contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 0)
    }
}


class ListViewController: UIViewController {

    let searchView = LottieAnimationView(name: "search", contentMode: .scaleAspectFit)
    let findButton = UIButton(title: "GoSearch", titleColor: ColorAppearance.black.color(), backgroundColor: ColorAppearance.white.color(), fount: FontAppearance.buttonText, isShadow: true)
    let acceptButton = UIButton(title: "AcceptRequest", titleColor: ColorAppearance.black.color(), backgroundColor: .white, fount: FontAppearance.buttonText, isShadow: true)
    
    var collectionView: UICollectionView!
    var collectionViewTopArc: NSLayoutConstraint!
    
    var activeChat:[SChat] = []
    var waitingChat:[SChat] = []
    
    private var waitingChatsListener: ListenerRegistration?
    private var activityChatObserve: ListenerRegistration?
    
    enum Section: Int, CaseIterable {
        case waitingChat, activeChat
        func description() -> String {
            switch self {
            case .waitingChat:
                return NSLocalizedString("WaitingChat", comment: "")
            case .activeChat:
                return NSLocalizedString("ActiveChat", comment: "")
            }
        }
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, SChat>?
    
    private let currentUser: SUser
    
    // MARK: init
    
    init(currentUser: SUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        title = currentUser.username
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Live Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSearchBar()
        setupCollectionView()
        createDataSource()
        setupConstraint()
        findButton.addTarget(self, action: #selector(showFind), for: .touchUpInside)
        acceptButton.addTarget(self, action: #selector(presentPerson(_:)), for: .touchUpInside)
        setupWaitingChatsListener()
        setupActivityChatObserve()
        NotificationCenter.default.addObserver(self, selector: #selector(presentPersonNotification(_:)), name: Notification.Name("ShowRequestViewController"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteChat(_:)), name: Notification.Name("DeleteChat"), object: nil)
    }
    deinit {
        waitingChatsListener?.remove()
        activityChatObserve?.remove()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchView.play()
    }
    
    // MARK: Listener
    
    private func setupWaitingChatsListener() {
        waitingChatsListener = ListenerService.shared.waitingChatObserve(chats: waitingChat, completion: { result in
            switch result {
            case .success(let chats):
                self.waitingChat = chats
                self.reloadData()
//                if self.waitingChat != [], self.waitingChat.count <= chats.count {
//                    self.showRequestViewController(chat: chats.last!)
//                }
            case .failure(let error):
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        })
    }
    
    private func setupActivityChatObserve() {
        activityChatObserve = ListenerService.shared.activityChatObserve(chats: activeChat, completion: { result in
            switch result {
            case .success(let chats):
                self.activeChat = chats
                self.reloadData()
            case .failure(let error):
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        })
    }
    
    // MARK: Action
    
    @objc func showFind() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        self.tabBarController?.selectedIndex = 0
    }
    
    @objc func deleteChat(_ notification: Notification) {
        guard let chat = notification.userInfo?["Chat"] as? SChat else { return }
        removeActiveChats(chat: chat)
    }
    
    @objc func presentPerson(_ sender: UIButton) {
        showRequestViewController(chat: waitingChat.last!)
    }
    
    @objc func presentPersonNotification(_ notification: Notification) {
        guard let user = notification.userInfo?["SUser"] as? SUser else { return }
        guard let chat = waitingChat.first(where: { $0.friendId == user.id }) else { return }
        showRequestViewController(chat: chat)
    }
    
    // MARK: Helper
    
    private func showRequestViewController(chat: SChat) {
        Task(priority: .userInitiated) {
            do {
                let friend = try await FirestoreService.shared.getUserData(id: chat.friendId)
                let chatRequestVC = RequestViewController(user: friend, chat: chat)
                chatRequestVC.delegate = self
                self.present(chatRequestVC, animated: true)
            } catch {
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        }
    }
    
}


// MARK: WaitingChatsNavigation

extension ListViewController: WaitingChatsNavigation {
    
    func removeWaitingChats(chat: SChat) {
        Task(priority: .userInitiated) {
            do {
                try await FirestoreService.shared.deleteWaitingChat(from: chat.friendId)
                self.showAlert(with: "Successfully", and: "Chat was deleted.")
            } catch {
                self.showAlert(with: "Error", and: "Chat not was deleted.")
            }
        }
    }
    
    func removeActiveChats(chat: SChat) {
        Task(priority: .userInitiated) {
            do {
                try await FirestoreService.shared.deleteActiveChat(friendId: chat.friendId)
                self.showAlert(with: "Successfully", and: "Chat was deleted.")
            } catch {
                self.showAlert(with: "Error", and: "Chat not was deleted.")
            }
        }
        Task(priority: .background) {
            do {
                try await FirestoreService.shared.clearActiveChat(friendId: chat.friendId)
            } catch {
                self.showAlert(with: "Error", and: #function + error.localizedDescription)
            }
        }
    }
    
    func chatToActive(chat: SChat) {
        Task(priority: .userInitiated) {
            do {
                try await FirestoreService.shared.changeToActive(chat: chat)
                self.showAlert(with: "Successfully", and: "EnjoyThe")
            } catch {
                self.showAlert(with: "Error", and: #function + error.localizedDescription)
            }
        }
    }
}


// MARK: - UICollectionViewDelegate

extension ListViewController: UICollectionViewDelegate {
    
    func collectionView(_ tableView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let chat = self.dataSource?.itemIdentifier(for: indexPath) else { return }
        guard let section = Section(rawValue: indexPath.section) else { return }
        switch section {
        case .waitingChat:
            showRequestViewController(chat: chat)
        case .activeChat:
            let chatVC = ChatsViewController(chat: chat)
            chatVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(chatVC, animated: true)
        }
    }
}

// MARK:  Data source
private extension ListViewController {
    
    func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, SChat>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, chat) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknown section kind") }
            switch section {
            case .activeChat:
                return self.configure(collectionView: collectionView, cellType: ActiveChatCell.self, with: chat, for: indexPath)
            case .waitingChat:
                return self.configure(collectionView: collectionView, cellType: WaitingChatCell.self, with: chat, for: indexPath)
            }
        })
        dataSource?.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as? SectionHeader else { fatalError("Can not create new section") }
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknown section kind") }
            sectionHeader.configure(text: section.description(), fount: FontAppearance.defaultBoldText, textColor: ColorAppearance.lightBlack.color())
            return sectionHeader
        }
    }
    
    // MARK: Reload Data
    
    func reloadData(with searchText: String? = nil) {
        let filteredActiveChat = activeChat.filter { (chat) -> Bool in
            chat.contains(filter: searchText)
        }
        let filteredWaitingChat = activeChat.filter { (chat) -> Bool in
            chat.contains(filter: searchText)
        }
        var snapshot = NSDiffableDataSourceSnapshot<Section, SChat>()
        snapshot.appendSections([.waitingChat, .activeChat])
        snapshot.appendItems(filteredWaitingChat, toSection: .waitingChat)
        snapshot.appendItems(filteredActiveChat, toSection: .activeChat)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SChat>()
        snapshot.appendSections([.waitingChat, .activeChat])
        snapshot.appendItems(waitingChat, toSection: .waitingChat)
        snapshot.appendItems(activeChat, toSection: .activeChat)
        dataSource?.apply(snapshot, animatingDifferences: true)
        emptyChats()
    }
    
    func emptyChats() {
        if activeChat.isEmpty && waitingChat.isEmpty {
            collectionView.isHidden = true
            navigationItem.searchController?.searchBar.isHidden = true
            searchView.isHidden = false
            findButton.isHidden = false
        } else {
            collectionView.isHidden = false
            navigationItem.searchController?.searchBar.isHidden = false
            searchView.isHidden = true
            findButton.isHidden = true
        }
        
        if waitingChat.isEmpty {
            collectionView.frame.origin.y = -150
            collectionView.frame.size.height = collectionView.frame.height + 150
        } else if collectionView.frame.origin.y == -150 {
            collectionView.frame.origin.y = 0
            collectionView.frame.size.height = collectionView.frame.height - 150
        }
        
        if activeChat.isEmpty && !waitingChat.isEmpty {
            acceptButton.isHidden = false
        } else {
            acceptButton.isHidden = true
        }
    }
}


// MARK: - UISearchBarDelegate

extension ListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            reloadData()
        } else {
            reloadData(with: searchText)
        }
    }
        
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        reloadData()
    }
}


// MARK: - Create

private extension ListViewController {
    
    func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = ColorAppearance.white.color()
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        collectionView.register(ActiveChatCell.self, forCellWithReuseIdentifier: ActiveChatCell.reuseId)
        collectionView.register(WaitingChatCell.self, forCellWithReuseIdentifier: WaitingChatCell.reuseId)
    }
    
    func createActiveChats() -> NSCollectionLayoutSection? {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(Padding.ActiveChats.activeCellHeight))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = Padding.ActiveChats.contentInsets
        section.interGroupSpacing = Padding.ActiveChats.interGroupSpacing
        section.boundarySupplementaryItems = [createSectionHeader()]
        return section
    }
    
    func createWaitingChats() -> NSCollectionLayoutSection? {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(Padding.WaitingChats.waitingChatsHeight), heightDimension: .absolute(Padding.WaitingChats.waitingChatsHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = Padding.WaitingChats.interGroupSpacing
        section.contentInsets = Padding.WaitingChats.contentInsets
        section.boundarySupplementaryItems = [createSectionHeader()]
        return section
    }
    
    func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let sectionHeaderSeize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderSeize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        return sectionHeader
    }
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) in
            guard let section = Section(rawValue: sectionIndex) else { fatalError("Unknown section kind") }
            switch section {
            case .activeChat:
                return self.createActiveChats()
            case .waitingChat:
                return self.createWaitingChats()
            }
        }
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = Padding.interSectionSpacing
        layout.configuration = config
        return layout
    }
    
    func setupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        navigationController?.navigationBar.addBGBlur()
        navigationController?.navigationBar.standardAppearance.titleTextAttributes = [.font: FontAppearance.buttonText, .foregroundColor: ColorAppearance.black.color()]
        navigationController?.navigationBar.scrollEdgeAppearance?.titleTextAttributes = [.font: FontAppearance.buttonText, .foregroundColor: ColorAppearance.black.color()]
    }
    
    func setupConstraint() {
        view.addSubview(searchView)
        view.addSubview(findButton)
        view.addSubview(acceptButton)
        searchView.isHidden = true
        findButton.isHidden = true
        acceptButton.isHidden = true
        searchView.translatesAutoresizingMaskIntoConstraints = false
        findButton.translatesAutoresizingMaskIntoConstraints = false
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: -Padding.second),
            searchView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            searchView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            searchView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
        ])
        NSLayoutConstraint.activate([
            findButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -Padding.first),
            findButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: Padding.first),
            findButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -Padding.second)
        ])
        NSLayoutConstraint.activate([
            acceptButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -Padding.first),
            acceptButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: Padding.first),
            acceptButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -Padding.second)
        ])
    }
}
