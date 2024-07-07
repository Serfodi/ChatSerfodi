//
//  SetupProfileViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 08.11.2023.
//

import UIKit
import FirebaseAuth

class SetupProfileViewController: UIViewController {
    
    
    let setupProfileLabel = UILabel(text: "Создания профиля", fount: FontAppearance.firstTitle)
    let fullNameLabel = UILabel(text: "Имя")
    let aboutMeLabel = UILabel(text: "Описание")
    let sexLabel = UILabel(text: "Пол")
    
    let photoView = AddPhotoView()
    
    let fullNameTextField = OneLineTextField(font: FontAppearance.defaultText)
    let aboutMeTextField = OneLineTextField(font: FontAppearance.defaultText)
    
    let sexSegmentedControll = UISegmentedControl(first: "Муж", second: "Жен")
    
    let goToChatButton = UIButton(title: "Просмотреть чаты!", titleColor: ColorAppearance.white.color(), backgroundColor: ColorAppearance.black.color())
    
    var stackView: UIStackView!
    
    private let currentUser: User
    
    init(currentUser: User) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
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
    }
    
    
    
    @objc private func goToChatsButtonTapped() {
        FirestoreService.shared.saveProfileWith(
            id: currentUser.uid,
            email: currentUser.email!,
            username: fullNameTextField.text,
            avatarImage: photoView.circleImageView.image,
            description: aboutMeTextField.text,
            sex: sexSegmentedControll.titleForSegment(at: sexSegmentedControll.selectedSegmentIndex)!) { (result) in
                switch result {
                case .success(let suser):
                    self.showAlert(with: "Успешно", and: "Вы авторизованы!") {
                        let mainTabBar = MainTabBarController(currentUser: suser)
                        mainTabBar.modalPresentationStyle = .fullScreen
                        self.present(mainTabBar, animated: true)
                    }
                case .failure(let error):
                    self.showAlert(with: "Ошибка!", and: error.localizedDescription)
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
    
    @objc func moveContentUp(notification: NSNotification) {
        let userInfo = notification.userInfo
        let keyboardFrame = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        let keyboardHeight = keyboardFrame!.size.height
        let emptySpaceHeight = view.frame.size.height - stackView.frame.maxY
        let converdContentHeight = keyboardHeight - emptySpaceHeight
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
        let sexStackView = UIStackView(arrangedSubviews: [sexLabel, sexSegmentedControll], axis: .vertical, spacing: 5)
        
        goToChatButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        stackView = UIStackView(arrangedSubviews: [
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
