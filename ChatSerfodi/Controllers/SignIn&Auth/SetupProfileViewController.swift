//
//  SetupProfileViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 08.11.2023.
//

import UIKit
import FirebaseAuth

class SetupProfileViewController: UIViewController {
    
    enum Padding {
        static let first: CGFloat = 60
        static let second: CGFloat = 40
        static let third: CGFloat = 30
    }
    
    let setupProfileLabel = UILabel(text: "CreatingProfile", fount: FontAppearance.firstTitle)
    let fullNameLabel = UILabel(text: "Name")
    let aboutMeLabel = UILabel(text: "Description")
    let sexLabel = UILabel(text: "Sex")
    let photoView = AddPhotoView()
    let fullNameTextField = OneLineTextField(font: FontAppearance.defaultText)
    let aboutMeTextField = OneLineTextField(font: FontAppearance.defaultText)
    let sexSegmentedController = UISegmentedControl(first: "Man", second: "Wom")
    let goToChatButton = UIButton(title: "GoChats", titleColor: ColorAppearance.white.color(), backgroundColor: ColorAppearance.black.color())
    var stackView: UIStackView!
    
    private let currentUser: User
    
    // MARK: init
    
    init(currentUser: User) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Live Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorAppearance.white.color()
        setupConstraints()
        goToChatButton.addTarget(self, action: #selector(goToChatsButtonTapped), for: .touchUpInside)
        photoView.pluseButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(moveContentUp), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    // MARK: Action
    
    @objc private func plusButtonTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true)
        photoView.circleImageView.contentMode = .scaleAspectFill
    }
    
    @objc private func goToChatsButtonTapped() {
        FirestoreService.shared.saveProfileWith(
            id: currentUser.uid,
            email: currentUser.email!,
            username: fullNameTextField.text,
            avatarImage: photoView.circleImageView.image,
            description: aboutMeTextField.text,
            sex: sexSegmentedController.titleForSegment(at: sexSegmentedController.selectedSegmentIndex)!) { (result) in
                switch result {
                case .success(let suser):
                    self.showAlert(with: "Successfully", and: "YouAreLoggedIn") {
                        let mainTabBar = MainTabBarController(currentUser: suser)
                        mainTabBar.modalPresentationStyle = .fullScreen
                        self.present(mainTabBar, animated: true)
                    }
                case .failure(let error):
                    self.showAlert(with: "Error", and: error.localizedDescription)
                }
            }
    }
    
    
    // MARK: Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = 0
                self.view.endEditing(true)
            }
        }
        super.touchesBegan(touches, with: event)
    }
    
    // for keyboard
    @objc func moveContentUp(notification: NSNotification) {
        let userInfo = notification.userInfo
        let keyboardFrame = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        let keyboardHeight = keyboardFrame!.size.height
        let emptySpaceHeight = view.frame.size.height - stackView.frame.maxY
        let converdContentHeight = keyboardHeight - emptySpaceHeight - goToChatButton.frame.height - Padding.second
        view.frame.origin.y = -converdContentHeight
    }
}

// MARK: UIImagePickerControllerDelegate
extension SetupProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        photoView.circleImageView.image = image
    }
}

// MARK: SetupProfileViewController
private extension SetupProfileViewController {
    
    func setupConstraints() {
        let fillNameStackView = UIStackView(arrangedSubviews: [fullNameLabel, fullNameTextField], axis: .vertical, spacing: 0)
        let aboutStackView = UIStackView(arrangedSubviews: [aboutMeLabel, aboutMeTextField], axis: .vertical, spacing: 0)
        let sexStackView = UIStackView(arrangedSubviews: [sexLabel, sexSegmentedController], axis: .vertical, spacing: 5)
        
        goToChatButton.heightAnchor.constraint(equalToConstant: Padding.first).isActive = true
        
        stackView = UIStackView(arrangedSubviews: [
            fillNameStackView,
            aboutStackView,
            sexStackView,
            goToChatButton
        ], axis: .vertical, spacing: Padding.second)
        
        setupProfileLabel.translatesAutoresizingMaskIntoConstraints = false
        photoView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(setupProfileLabel)
        view.addSubview(photoView)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            setupProfileLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: Padding.second),
            setupProfileLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        NSLayoutConstraint.activate([
            photoView.topAnchor.constraint(equalTo: setupProfileLabel.bottomAnchor, constant: Padding.second),
            photoView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 17.5)
        ])
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: photoView.bottomAnchor, constant: Padding.second),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Padding.second),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Padding.second)
        ])
    }
}
