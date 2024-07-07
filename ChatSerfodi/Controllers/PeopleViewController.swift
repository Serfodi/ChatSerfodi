//
//  PeopleViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 10.11.2023.
//

import UIKit
import FirebaseFirestore

class PeopleViewController: UIViewController {
    
    var users = [SUser]()
    private var usersListener: ListenerRegistration?
    
    var collectionView: UICollectionView!
    
    enum Section: Int, CaseIterable {
        case users
        
        func description(userCount: Int) -> String {
            switch self {
            case .users:
                return "\(userCount) человека рядом"
            }
        }
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, SUser>!
    
    
    private let currentUser: SUser
    
    init(currentUser: SUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        title = currentUser.username
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        usersListener?.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupCollectionView()
        createDataSource()
        
        usersListener = ListenerService.shared.usersObserve(users: users, completion: { (result) in
            switch result {
            case .success(let users):
                self.users = users
                self.reloadData()
            case .failure(let error):
                self.showAlert(with: "Ошибка!", and: error.localizedDescription)
            }
        })
    }
    
    private func setupSearchBar() {
//        navigationController?.navigationBar.barTintColor = .white
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
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = ColorAppearance.white.color()
        
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        collectionView.register(UserCell.self, forCellWithReuseIdentifier: UserCell.reuseId)
    }
    
    private func reloadData(with searchText: String? = nil) {
        let filtered = users.filter { (user) -> Bool in
            user.contains(filtr: searchText)
        }
        var snapshot = NSDiffableDataSourceSnapshot<Section, SUser>()
        snapshot.appendSections([.users])
        snapshot.appendItems(filtered, toSection: .users)
        
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
}


// MARK: UISearchBarDelegate
extension PeopleViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadData(with: searchText)
    }
}


extension PeopleViewController {
    
    private func createDataSource() {
        
        dataSource = UICollectionViewDiffableDataSource<Section, SUser>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, user) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknow section kind") }
            switch section {
            case .users:
                return self.configure(collectionView: collectionView, cellType: UserCell.self, with: user, for: indexPath)
            }
        })
        
        dataSource?.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as? SectionHeader else {
                fatalError("Can not create new section")
            }
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("Unknown section kind")
            }
            let items = self.dataSource.snapshot().itemIdentifiers(inSection: .users)
            sectionHeader.configure(text: section.description(userCount: items.count), fount: FontAppearance.defaultBoldText, textColor: ColorAppearance.black.color().withAlphaComponent(0.5))
            return sectionHeader
        }
    }
    
    private func reloadSectionHeader(text: String) {}
    
}



// MARK: UICollectionViewCompositionalLayout

extension PeopleViewController {
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIdex, layoutEnviroment) in
            guard let section = Section(rawValue: sectionIdex) else { fatalError("Unknow section kind") }
            switch section {
            case .users:
                return self.createUserSection()
            }
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        layout.configuration = config
        
        return layout
    }
    
    private func createUserSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.6))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        group.interItemSpacing = .fixed(15)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 15
        section.contentInsets = NSDirectionalEdgeInsets.init(top: 15, leading: 15, bottom: 0, trailing: 0)
        section.boundarySupplementaryItems = [createSectionHeader()]
        
        return section
    }
    
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let sectionHeaderSeize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderSeize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        return sectionHeader
    }
}


// MARK: UICollectionViewDelegate


extension PeopleViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let user = self.dataSource.itemIdentifier(for: indexPath) else { return }
        let profileVC = ProfileViewController(user: user)
        present(profileVC, animated: true)
    }
}
