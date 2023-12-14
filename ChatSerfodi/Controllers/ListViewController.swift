//
//  ListViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 10.11.2023.
//

import UIKit
import FirebaseFirestore

class ListViewController: UIViewController {

    var activeChat:[SChat] = []
    var waitingChat:[SChat] = []
    
    private var waitingChatsListener: ListenerRegistration?
    private var activityChatObserve: ListenerRegistration?
    
    var collectionView: UICollectionView!
    
    // Можно вынести в глобальную видимость. Для создания документов FirebaseFirestore
    enum Section: Int, CaseIterable {
        case waitingChat, activeChat
        
        func description() -> String {
            switch self {
            case .waitingChat:
                return "Waiting chat"
            case .activeChat:
                return "Active chat"
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupCollectionView()
        createDataSource()
        reloadData()
        
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
    }

    
    
    
    deinit {
        waitingChatsListener?.remove()
        activityChatObserve?.remove()
    }
    
    
    private func setupSearchBar() {
        navigationController?.navigationBar.barTintColor = .mainWhite()
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .mainWhite()
        view.addSubview(collectionView)
        
        collectionView.delegate = self
        
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        
        collectionView.register(ActiveChatCell.self, forCellWithReuseIdentifier: ActiveChatCell.reuseId)
        collectionView.register(WaitingChatCell.self, forCellWithReuseIdentifier: WaitingChatCell.reuseId)
    }
}



// MARK: UICollectionViewDelegate

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
            print(#function)
        }
    }
    
}


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





// MARK:  Data sourse

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
            
            sectionHeader.configure(text: section.description(), fount: .laoSangamMN20(), textColor: UIColor(white: 0.6, alpha: 1))
            
            return sectionHeader
        }
    }
    
    private func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SChat>()
        snapshot.appendSections([.waitingChat, .activeChat])
        snapshot.appendItems(waitingChat, toSection: .waitingChat)
        snapshot.appendItems(activeChat, toSection: .activeChat)
        dataSource?.apply(snapshot, animatingDifferences: true)
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
        // cells
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let grupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(78))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: grupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets.init(top: 16, leading: 20, bottom: 0, trailing: 20)
        section.interGroupSpacing = 8
        
        // header
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
}


// MARK: - SwiftUI

//import SwiftUI
//
//struct ListProvider: PreviewProvider {
//
//    static var previews: some View {
//        ContainerView().edgesIgnoringSafeArea(.all)
//    }
//
//    struct ContainerView: UIViewControllerRepresentable {
//
//        let viewController = MainTabBarController(currentUser: SUser(username: "", email: "", avatarStringURL: "", description: "", sex: "", id: ""))
//
//        func makeUIViewController(context: Context) -> some MainTabBarController {
//            viewController
//        }
//
//        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
//
//    }
//
//}
