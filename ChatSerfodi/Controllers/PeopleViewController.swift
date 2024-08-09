//
//  PeopleViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 10.11.2023.
//

import UIKit
import FirebaseFirestore
import TinyConstraints

final class PeopleViewController: UIViewController {
    
    enum Section: Hashable {
        case users(String)
    }
    
    private var users = [SUser]()
    
    private var usersListener: ListenerRegistration?
    private var userListener: ListenerRegistration?
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, SUser>!
    
    // helpers View
    
    private var hideStack: UIStackView!
    
    // MARK: init
    
    private var currentUser: SUser
        
    init(user: SUser) {
        self.currentUser = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Live Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
        setupUsersListener()
        setupUserListener()
    }
    deinit {
        usersListener?.remove()
        userListener?.remove()
    }
    
    // MARK: Users Listener
    
    private func setupUsersListener() {
        usersListener = ListenerService.shared.usersObserve(users: users, completion: { (result) in
            switch result {
            case .success(let users):
                self.users = users
                
                // MARK: - to do
                let toRemove = self.currentUser.blocked + self.currentUser.activeChats
                if !toRemove.isEmpty {
                    self.users = self.users.filter { !toRemove.contains($0.id) }
                }
                // MARK: to do -
                
                self.reloadData()
            case .failure(let error):
                self.showAlert(with: "Error", and: #function + error.localizedDescription)
            }
        })
    }
    
    private func setupUserListener() {
        userListener = ListenerService.shared.userObserver(userId: currentUser.id, completion: { result in
            switch result {
            case .success(let user):
                self.currentUser = user
                self.showHideMessages(isHide: user.isHide)
            case .failure(let error):
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        })
    }
    
    // MARK: Reload Data
    
    private func reloadData(with searchText: String? = nil) {
        let filtered = users.filter { (user) -> Bool in
            user.contains(filter: searchText)
        }
        var snapshot = NSDiffableDataSourceSnapshot<Section, SUser>()
        let newSection = Section.users("\(filtered.count) " + NSLocalizedString("peopleNearby", comment: ""))
        snapshot.appendSections([newSection])
        snapshot.appendItems(filtered, toSection: newSection)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    // helpers
    
    private func showHideMessages(isHide: Bool) {
        collectionView.isHidden = isHide
        hideStack.isHidden = !isHide
    }
    
}

// MARK: UISearchBarDelegate

extension PeopleViewController: UISearchBarDelegate {
    
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

// MARK: UICollectionViewDelegate

extension PeopleViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let user = self.dataSource.itemIdentifier(for: indexPath) else { return }
        let pr = SendProfileViewController(user: user)
        pr.delegate = self
        present(pr, animated: true)
    }
}

// MARK: GoToAccept

extension PeopleViewController: GoToAccept {
    
    func GoToAccept(user: SUser) {
        self.tabBarController?.selectedIndex = 1
        NotificationCenter.default.post(name: Notification.Name("ShowRequestViewController"), object: nil, userInfo: ["SUser" : user])
    }
    
}


// MARK: - Configuration

private extension PeopleViewController {
    
    func configuration() {
        configurationView()
        configurationNavigationBar()
        configurationCollectionView()
        configurationDataSource()
        configurationStack()
    }
    
    func configurationView() {
        title = NSLocalizedString("People", comment: "")
        view.backgroundColor = ColorAppearance.white.color()
    }
    
    func configurationNavigationBar() {
        let searchController = UISearchController.defaultConfiguration()
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.configuration()
    }
    
    func configurationCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        collectionView.register(UserCell.self, forCellWithReuseIdentifier: UserCell.reuseId)
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        view.addSubview(collectionView)
        collectionView.edgesToSuperview()
    }
    
    enum Padding {
        static let first: CGFloat = 20
        static let second: CGFloat = 20
    }
    
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (_, _) in
            self.createUserSection()
        }
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = Padding.second
        layout.configuration = config
        return layout
    }
    
    func createUserSection() -> NSCollectionLayoutSection {
        var itemCount = 2
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        var groupSize = NSCollectionLayoutSize(widthDimension: .absolute(1), heightDimension: .absolute(1))
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.6))
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.97), heightDimension: .fractionalWidth(0.4))
        }
        
        var group = NSCollectionLayoutGroup(layoutSize: groupSize)
        
        if #available(iOS 16.0, *) {
            group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: itemCount)
        } else {
            group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: itemCount)
        }
        
        group.interItemSpacing = .fixed(Padding.first)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = Padding.first
        section.contentInsets = NSDirectionalEdgeInsets.init(top: Padding.first, leading: Padding.first, bottom: 0, trailing: 0)
        section.boundarySupplementaryItems = [createSectionHeader()]
        return section
    }
    
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let sectionHeaderSeize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderSeize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        return sectionHeader
    }
    
    func configurationDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, SUser>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, user) -> UICollectionViewCell? in
            return self.configure(collectionView: collectionView, cellType: UserCell.self, with: user, for: indexPath)
        })
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as? SectionHeader else {
                fatalError("Can not create new section")
            }
            switch section {
            case .users(let items):
                sectionHeader.configure(text: items, fount: FontAppearance.defaultBoldText, textColor: ColorAppearance.lightBlack.color())
            }
            return sectionHeader
        }
    }
    
    func configurationStack() {
        let label = UILabel(text: "AccountHidden", alignment: .center, fount: FontAppearance.firstTitle, color: ColorAppearance.black.color())
        let image = UIImageView(image: UIImage(systemName: "eye.slash.fill"))
        image.contentMode = .scaleAspectFit
        image.tintColor = ColorAppearance.black.color()
        hideStack = UIStackView(arrangedSubviews: [image, label], axis: .vertical, spacing: 10)
        hideStack.alignment = .center
        hideStack.isHidden = true
        view.addSubview(hideStack)
        image.height(100)
        let aspect = image.intrinsicContentSize.height / image.intrinsicContentSize.width
        image.aspectRatio(aspect)
        label.height(30)
        hideStack.centerInSuperview()
    }
    
}
