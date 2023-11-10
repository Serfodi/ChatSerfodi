//
//  ListViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 10.11.2023.
//

import UIKit


struct SChat: Hashable, Decodable {
    var userName: String
    var userImageString: String
    var lastMessage: String
    var id: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: SChat, rhs: SChat) -> Bool {
        lhs.id == rhs.id
    }
}


class ListViewController: UIViewController {

    let activChat = Bundle.main.decode([SChat].self, from: "activChat.json")
    let waitingChat = Bundle.main.decode([SChat].self, from: "waitingChat.json")
    
    var collectionView: UICollectionView!
    
    enum Section: Int, CaseIterable {
        case waitingChat
        case activeChat
    }
    
    var dataSourse: UICollectionViewDiffableDataSource<Section, SChat>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupCollectionView()
        createDataSourse()
        reloadData()
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
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cellid")
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cellid2")
        
//        collectionView.delegate = self
//        collectionView.dataSource = self
    }
    
    private func createDataSourse() {
        dataSourse = UICollectionViewDiffableDataSource<Section, SChat>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, chat) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknow section kind") }
            switch section {
            case .activeChat:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellid", for: indexPath)
                cell.backgroundColor = .systemBlue
                return cell
            case .waitingChat:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellid2", for: indexPath)
                cell.backgroundColor = .systemGray
                    return cell
            }
        })
    }
    
    private func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, SChat>()
        snapshot.appendSections([.waitingChat, .activeChat])
        snapshot.appendItems(waitingChat, toSection: .waitingChat)
        snapshot.appendItems(activChat, toSection: .activeChat)
        dataSourse?.apply(snapshot, animatingDifferences: true)
    }
    
}



// MARK: UISearchBarDelegate
extension ListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
}


extension ListViewController {
    
    private func createActivChats() -> NSCollectionLayoutSection? {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let grupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(84))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: grupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets.init(top: 16, leading: 20, bottom: 0, trailing: 20)
        section.interGroupSpacing = 8
        return section
    }
    
    private func createWatinigChats() -> NSCollectionLayoutSection? {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let grupSize = NSCollectionLayoutSize(widthDimension: .absolute(88), heightDimension: .absolute(88))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: grupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets.init(top: 16, leading: 20, bottom: 0, trailing: 0)
        return section
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIdex, layoutEnviroment) in
            
            guard let section = Section(rawValue: sectionIdex) else { fatalError("Unknow section kind") }
            
            switch section {
            case .activeChat:
                return self.createActivChats()
            case .waitingChat:
                return self.createWatinigChats()
            }
        }
        return layout
    }
}



/*
 // MARK: UICollectionViewDelegate, UICollectionViewDataSource
 extension ListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
 
 func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
 return 5
 }
 
 func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
 let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellid", for: indexPath)
 cell.backgroundColor = .red
 return cell
 }
 }
 
 extension ListViewController: UICollectionViewDelegateFlowLayout {
 
 func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
 CGSize(width: 50, height: 50)
 }
 
 }
 */



// MARK: SwiftUI

import SwiftUI

struct ListProvider: PreviewProvider {
    
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        let viewController = MainTabBarController()
        
        func makeUIViewController(context: Context) -> some MainTabBarController {
            viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
        
    }
    
}
