//
//  AddPhotoView.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 08.11.2023.
//

import UIKit

class AddPhotoView: UIView {
    
    var circleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "person", withConfiguration: UIImage.SymbolConfiguration(pointSize: 60))
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        imageView.tintColor = ColorAppearance.black.color()
        imageView.layer.borderColor = ColorAppearance.black.color().cgColor
        imageView.layer.borderWidth = 4
        return imageView
    }()
    
    let pluseButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = ColorAppearance.black.color()
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(circleImageView)
        addSubview(pluseButton)
        
        setupConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circleImageView.layer.masksToBounds = true
        circleImageView.layer.cornerRadius = circleImageView.bounds.height / 2
    }
    
    
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            circleImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            circleImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            circleImageView.heightAnchor.constraint(equalToConstant: 100),
            circleImageView.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        NSLayoutConstraint.activate([
            pluseButton.leadingAnchor.constraint(equalTo: circleImageView.trailingAnchor, constant: 5),
            pluseButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            pluseButton.heightAnchor.constraint(equalToConstant: 30),
            pluseButton.widthAnchor.constraint(equalToConstant: 30)
        ])
        
        self.bottomAnchor.constraint(equalTo: circleImageView.bottomAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: pluseButton.trailingAnchor).isActive = true
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


