//
//  ListViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 10.11.2023.
//

import UIKit
import FirebaseFirestore
import Lottie

class ListViewController: UIViewController {

    var activeChat:[SChat] = []
    var waitingChat:[SChat] = []
    
    private var waitingChatsListener: ListenerRegistration?
    private var activityChatObserve: ListenerRegistration?
    
    var collectionView: UICollectionView!
    var collectionViewTopArc: NSLayoutConstraint!
    
    var searchView: LottieAnimationView! = {
        let duckView = LottieAnimationView(name: "search")
        duckView.loopMode = .loop
        duckView.contentMode = .scaleAspectFit
        return duckView
    }()
    
    var findButton = UIButton(title: "Перейти к поискам", titleColor: ColorAppearance.black.color(), backgroundColor: ColorAppearance.white.color(), fount: FontAppearance.buttonText, isShodow: true)
    
    var acceptButton = UIButton(title: "Примите запрос!", titleColor: ColorAppearance.black.color(), backgroundColor: .white, fount: FontAppearance.buttonText, isShodow: true)
    
    // Можно вынести в глобальную видимость. Для создания документов FirebaseFirestore
    enum Section: Int, CaseIterable {
        case waitingChat, activeChat
        func description() -> String {
            switch self {
            case .waitingChat:
                return "Ожидающие чаты"
            case .activeChat:
                return "Активные чаты"
            }
        }
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, SChat>?
    
    private let currentUser: SUser
    
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
        reloadData()
        
        view.addSubview(searchView)
        view.addSubview(findButton)
        view.addSubview(acceptButton)
        setupConstraint()
        findButton.addTarget(self, action: #selector(showFind), for: .touchUpInside)
        acceptButton.addTarget(self, action: #selector(presentPerson), for: .touchUpInside)
        
        waitingChatsListener = ListenerService.shared.waitingChatObserve(chats: waitingChat, completion: { result in
            switch result {
            case .success(let chats):
                self.waitingChat = chats
                self.reloadData()
                if self.waitingChat != [],  self.waitingChat.count <= chats.count {
                    let chatRequestVC = ChatRequestViewController(chat: chats.last!)
                    chatRequestVC.delegate = self
                    self.present(chatRequestVC, animated: true)
                }
            case .failure(let error):
                self.showAlert(with: "Ошибка!", and: error.localizedDescription)
            }
        })
        
        activityChatObserve = ListenerService.shared.activityChatObserve(chats: activeChat, completion: { result in
            switch result {
            case .success(let chats):
                self.activeChat = chats
                self.reloadData()
            case .failure(let error):
                self.showAlert(with: "Ошибка!", and: error.localizedDescription)
            }
        })
        
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
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin]
        collectionView.backgroundColor = ColorAppearance.white.color()
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        collectionView.register(ActiveChatCell.self, forCellWithReuseIdentifier: ActiveChatCell.reuseId)
        collectionView.register(WaitingChatCell.self, forCellWithReuseIdentifier: WaitingChatCell.reuseId)
    }
    
    @objc func showFind() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        self.tabBarController?.selectedIndex = 0
    }
    
    @objc func deleteChat(_ notification: Notification) {
        guard let chat = notification.userInfo?["Chat"] as? SChat else { return }
        removeActiveChats(chat: chat)
    }
    
    @objc func presentPerson() {
        let chatRequestVC = ChatRequestViewController(chat: waitingChat.last!)
        chatRequestVC.delegate = self
        self.present(chatRequestVC, animated: true)
    }
}

// MARK: WaitingChatsNavigation
extension ListViewController: WaitingChatsNavigation {
    
    func removeWaitingChats(chat: SChat) {
        FirestoreService.shared.deleteWaitingChat(chat: chat) { result in
            switch result {
            case .success():
                self.showAlert(with: "Успешно!", and: "Чат с \(chat.friendUsername) был удален.")
            case .failure(let error):
                self.showAlert(with: "Ошибка!", and: "Чат с \(chat.friendUsername) не был удален. Ошибка: \(error.localizedDescription)")
            }
        }
    }
    
    func removeActiveChats(chat: SChat) {
        FirestoreService.shared.deleteActiveChat(chat: chat) { result in
            switch result {
            case .success():
                self.showAlert(with: "Успешно!", and: "Чат с \(chat.friendUsername) был удален.")
            case .failure(let error):
                self.showAlert(with: "Ошибка!", and: "Чат с \(chat.friendUsername) не был удален. Ошибка: \(error.localizedDescription)")
            }
        }
    }
    
    func chatToActive(chat: SChat) {
        FirestoreService.shared.changeToActive(chat: chat) { result in
            switch result {
            case .success():
                self.showAlert(with: "Успешно!", and: "Приятного общения с \(chat.friendUsername).")
            case .failure(let error):
                self.showAlert(with: "Ошибка!", and: "Чат с \(chat.friendUsername) не был создан. Ошибка: \(error.localizedDescription)")
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
            let chatRequestVC = ChatRequestViewController(chat: chat)
            chatRequestVC.delegate = self
            self.present(chatRequestVC, animated: true)
        case .activeChat:
            let chatVC = ChatsViewController(user: currentUser, chat: chat)
            chatVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(chatVC, animated: true)
        }
    }
}

// MARK:  Data source
extension ListViewController {
    
    private func createDataSource() {
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
            sectionHeader.configure(text: section.description(), fount: FontAppearance.defaultBoldText, textColor: ColorAppearance.black.color().withAlphaComponent(0.5))
            return sectionHeader
        }
    }
    
    // MARK: ReloadData
    
    private func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SChat>()
        snapshot.appendSections([.waitingChat, .activeChat])
        snapshot.appendItems(waitingChat, toSection: .waitingChat)
        snapshot.appendItems(activeChat, toSection: .activeChat)
        dataSource?.apply(snapshot, animatingDifferences: true)
        
        if activeChat.isEmpty && waitingChat.isEmpty {
            collectionView.isHidden = true
            searchView.isHidden = false
            findButton.isHidden = false
        } else {
            collectionView.isHidden = false
            searchView.isHidden = true
            findButton.isHidden = true
        }
        
        if waitingChat.isEmpty {
            collectionView.frame.origin.y = -140
            collectionView.frame.size.height = collectionView.frame.height + 140
        } else if collectionView.frame.origin.y == -140 {
            collectionView.frame.origin.y = 0
            collectionView.frame.size.height = collectionView.frame.height - 140
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
        print(searchText)
    }
}


// MARK: - Create

extension ListViewController {
    
    private func createActiveChats() -> NSCollectionLayoutSection? {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let grupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(78))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: grupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets.init(top: 16, leading: 20, bottom: 0, trailing: 20)
        section.interGroupSpacing = 10
        section.boundarySupplementaryItems = [createSectionHeader()]
        return section
    }
    
    private func createWaitingChats() -> NSCollectionLayoutSection? {
        // cells
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let grupSize = NSCollectionLayoutSize(widthDimension: .absolute(88), heightDimension: .absolute(88))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: grupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets.init(top: 16, leading: 20, bottom: 0, trailing: 0)
        
        // header
        section.boundarySupplementaryItems = [createSectionHeader()]
        
        return section
    }
    
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let sectionHeaderSeize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderSeize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        return sectionHeader
    }
    
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
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
        config.interSectionSpacing = 20
        layout.configuration = config
        return layout
    }
    
    private func setupSearchBar() {
        navigationController?.navigationBar.barTintColor = .mainWhite()
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
        searchView.translatesAutoresizingMaskIntoConstraints = false
        findButton.translatesAutoresizingMaskIntoConstraints = false
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: -40),
            searchView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            searchView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            searchView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
        ])
        
        NSLayoutConstraint.activate([
            findButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -60),
            findButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 60),
            findButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
        
        NSLayoutConstraint.activate([
            acceptButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -60),
            acceptButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 60),
            acceptButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
        
    }
    
}
