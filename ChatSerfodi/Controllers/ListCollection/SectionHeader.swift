//
//  SectionHeader.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 17.11.2023.
//

import UIKit

class SectionHeader: UICollectionReusableView {
    
    static let reuseId = "SectionHeader"
    
    let titile = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titile.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titile)
        
        NSLayoutConstraint.activate([
            titile.topAnchor.constraint(equalTo: self.topAnchor),
            titile.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            titile.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            titile.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(text: String, fount: UIFont?, textColor: UIColor) {
        titile.textColor = textColor
        titile.font = fount
        titile.text = text
    }
    
}
