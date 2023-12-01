//
//  SetupProfileViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 08.11.2023.
//

import UIKit

class SetupProfileViewController: UIViewController {

    
    let setupProfileLabel = UILabel(text: "Set up profile", fount: .avenir26())
    let fullNameLabel = UILabel(text: "Full name")
    let aboutMeLabel = UILabel(text: "About me")
    let sexLabel = UILabel(text: "sex")
    
    let photoView = AddPhotoView()
    
    let fullNameTextField = OneLineTextField(foun: .avenir20())
    let aboutMeTextField = OneLineTextField(foun: .avenir20())
    
    let sexSegmentedControll = UISegmentedControl(first: "Male", second: "Femail")
    
    let goToChatButton = UIButton(title: "Go to chats!", titleColor: .white, backgroundColor: .buttonDark(), cornorRadius: 4)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        setupConstraints()
    }
    
}


extension SetupProfileViewController {
    
    private func setupConstraints() {
        let fillNameStackView = UIStackView(arrangedSubviews: [fullNameLabel, fullNameTextField], axis: .vertical, spacing: 0)
        let aboutStackView = UIStackView(arrangedSubviews: [aboutMeLabel, aboutMeTextField], axis: .vertical, spacing: 0)
        let sexStackView = UIStackView(arrangedSubviews: [sexLabel, sexSegmentedControll], axis: .vertical, spacing: 5)
        
        goToChatButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [
            fillNameStackView,
            aboutStackView,
            sexStackView,
            goToChatButton
        ], axis: .vertical, spacing: 40)
        
        
        setupProfileLabel.translatesAutoresizingMaskIntoConstraints = false
        photoView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(setupProfileLabel)
        view.addSubview(photoView)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            setupProfileLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            setupProfileLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            photoView.topAnchor.constraint(equalTo: setupProfileLabel.bottomAnchor, constant: 40),
            photoView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 17.5)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: photoView.bottomAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
    }
    
}




// MARK: SwiftUI

import SwiftUI

struct SetupProfileProvider: PreviewProvider {
    
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        let viewController = SetupProfileViewController()
        
        func makeUIViewController(context: Context) -> some UIViewController {
            viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
        
    }
    
}
