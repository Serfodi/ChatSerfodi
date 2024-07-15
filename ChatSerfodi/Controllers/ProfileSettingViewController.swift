//
//  ProfileSettingViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 04.07.2024.
//

import UIKit
import FirebaseAuth

class ProfileSettingViewController: UIViewController {

    let containerView: UIView = {
        let view = UIView()
        view.addBlur(blur: .init(style: .regular))
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    let fullNameLabel = UILabel(text: "Name")
    let aboutMeLabel = UILabel(text: "Description")
    
    let photoView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
     
    let fullNameTextField = OneLineTextField(font: FontAppearance.defaultText)
    let aboutMeTextField = OneLineTextField(font: FontAppearance.defaultText)
    
    var stackView: UIStackView!
    
    let pickButton = UIButton(title: "ChooseAnotherPhoto", titleColor: ColorAppearance.black.color(), fount: FontAppearance.defaultBoldText)
        
    private let currentUser: SUser
    
    init(currentSUser: SUser) {
        self.currentUser = currentSUser
        super.init(nibName: nil, bundle: nil)
        fullNameTextField.text = currentSUser.username
        aboutMeTextField.text = currentSUser.description
        photoView.sd_setImage(with: URL(string: currentSUser.avatarStringURL))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorAppearance.white.color()
        configNavigationBar()
        setupConstraints()
        pickButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(moveContentUp), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func plusButtonTapped() {
        endEditing()
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true)
    }
    
    @objc func saveProfile() {
        endEditing()
        FirestoreService.shared.updateProfile(sUser: currentUser,
                                              username: fullNameTextField.text!,
                                              avatarImage: photoView.image,
                                              description: aboutMeTextField.text!) { result in
            switch result {
            case .success(_):
                self.showAlert(with: "Successfully", and: "TheChangesAreSaved")
            case .failure(let error):
                self.showAlert(with: "Error", and: error.localizedDescription)
            }
        }
    }
    
    @objc private func signOut() {
        endEditing()
        let ac = UIAlertController(title: nil, message: NSLocalizedString("GetOut", comment: ""), preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
        ac.addAction(UIAlertAction(title: NSLocalizedString("Exit", comment: ""), style: .destructive, handler: { _ in
            do {
                try Auth.auth().signOut()
                UIApplication.shared.firstKeyWindow?.rootViewController = AuthViewController()
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }))
        present(ac, animated: true)
    }
    
    // MARK: Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            self.endEditing()
        }
        super.touchesBegan(touches, with: event)
    }
    
    @objc func moveContentUp(notification: NSNotification) {
        let userInfo = notification.userInfo
        let keyboardFrame = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        let keyboardHeight = keyboardFrame!.size.height
        let emptySpaceHeight = view.frame.size.height - containerView.frame.maxY + (containerView.frame.height - stackView.frame.maxY)
        let converdContentHeight = keyboardHeight - emptySpaceHeight + 10
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = -converdContentHeight
            self.view.layoutIfNeeded()
        }
    }
    
    func endEditing() {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
            self.view.layoutIfNeeded()
            self.view.endEditing(true)
        }
    }
    
}


// MARK: UIImagePickerControllerDelegate
extension ProfileSettingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        photoView.image = image
    }
}


// MARK: SetupProfileViewController
private extension ProfileSettingViewController {
    
    private func configNavigationBar() {
        navigationItem.title = NSLocalizedString("MyProfile", comment: "")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Exit", comment: ""), style: .done, target: self, action: #selector(signOut))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Save", comment: ""), style: .done, target: self, action: #selector(saveProfile))
        navigationController?.navigationBar.addBGBlur()
        navigationController?.navigationBar.standardAppearance.titleTextAttributes = [.font: FontAppearance.buttonText, .foregroundColor: ColorAppearance.black.color()]
        navigationController?.navigationBar.scrollEdgeAppearance?.titleTextAttributes = [.font: FontAppearance.buttonText, .foregroundColor: ColorAppearance.black.color()]
    }
    
    func setupConstraints() {
        photoView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(photoView)
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            photoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -15),
            photoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        let aspectRatioConstraint = NSLayoutConstraint(item: photoView, attribute: .width, relatedBy: .equal, toItem: photoView, attribute: .height, multiplier: 1.0, constant: 0)
        photoView.addConstraint(aspectRatioConstraint)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: photoView.bottomAnchor, constant: -30),
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        let fillNameStackView = UIStackView(arrangedSubviews: [fullNameLabel, fullNameTextField], axis: .vertical, spacing: 0)
        let aboutStackView = UIStackView(arrangedSubviews: [aboutMeLabel, aboutMeTextField], axis: .vertical, spacing: 0)

        stackView = UIStackView(arrangedSubviews: [
            pickButton,
            fillNameStackView,
            aboutStackView
        ], axis: .vertical, spacing: 30)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -10)
        ])
    }
}
