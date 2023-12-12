//
//  PeopleViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 10.11.2023.
//

import UIKit
import FirebaseAuth

class PeopleViewController: UIViewController {
    
    let users = Bundle.main.decode([SUser].self, from: "user.json")
    
    var collectionView: UICollectionView!
    
    enum Section: Int, CaseIterable {
        case users
        
        func description(userCount: Int) -> String {
            switch self {
            case .users:
                return "\(userCount) people nearby"
            }
        }
    }
    
    var dataSourse: UICollectionViewDiffableDataSource<Section, SUser>!
    
    
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
        
        view.backgroundColor = .white
        
        setupSearchBar()
        setupCollectionView()
        createDataSourse()
        reloadData()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(signOut))
    }
    
    
    @objc private func signOut() {
        let ac = UIAlertController(title: nil, message: "Вы хотите выйти?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        ac.addAction(UIAlertAction(title: "Выйти", style: .destructive, handler: { _ in
            do {
                try Auth.auth().signOut()
                UIApplication.shared.firstKeyWindow?.rootViewController = AuthViewController()
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }))
        present(ac, animated: true)
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
        
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        
        collectionView.register(UserCell.self, forCellWithReuseIdentifier: UserCell.reuseId)
    }
    
    private func reloadData(with searchText: String? = nil) {
        let filtred = users.filter { (user) -> Bool in
            user.contains(filtr: searchText)
        }
        var snapshot = NSDiffableDataSourceSnapshot<Section, SUser>()
        snapshot.appendSections([.users])
        snapshot.appendItems(filtred, toSection: .users)
        dataSourse?.apply(snapshot, animatingDifferences: true)
    }
    
}

// MARK: UISearchBarDelegate
extension PeopleViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadData(with: searchText)
    }
}

extension PeopleViewController {
    
    private func createDataSourse() {
        dataSourse = UICollectionViewDiffableDataSource<Section, SUser>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, user) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknow section kind") }
            switch section {
            case .users:
                return self.configure(collectionView: collectionView, cellType: UserCell.self, with: user, for: indexPath)
            }
        })
        
        dataSourse?.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as? SectionHeader else { fatalError("Can not create new section") }
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknown section kind") }
            let items = self.dataSourse.snapshot().itemIdentifiers(inSection: .users)
            sectionHeader.configure(text: section.description(userCount: items.count), fount: .systemFont(ofSize: 36, weight: .light), textColor: .label)
            return sectionHeader
        }
        
    }
    
}


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





// MARK: SwiftUI

import SwiftUI

struct PeopleVCProvider: PreviewProvider {
    
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        let viewController = MainTabBarController(currentUser: SUser(username: "", email: "", avatarStringURL: "", description: "", sex: "", id: ""))
        
        func makeUIViewController(context: Context) -> some MainTabBarController {
            viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
        
    }
    
}
