//
//  SettingProfileViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 26.07.2024.
//

import UIKit
import TinyConstraints

class SettingProfileViewController: UIViewController {

    public let scrollView = UIScrollView()
    private let imageView = UIImageView()
    private let fullNameLabel = UILabel(text: "Name")
    private let aboutMeLabel = UILabel(text: "Description")
    private let fullNameTextField = OneLineTextField(font: FontAppearance.defaultText)
    private let aboutMeTextView = OneLineTextView(font: FontAppearance.defaultText)
    private let pickButton = UIButton(title: "ChooseAnotherPhoto", titleColor: ColorAppearance.black.color(), fount: FontAppearance.defaultBoldText)
    
    public var stackView: UIStackView!
    
    private lazy var aboutMeTextViewHeight = aboutMeTextView.height(48)
    private lazy var aspectRatioImage = imageView.aspectRatio(1)
    
    
    weak var delegate: ProfileChangesDelegate?
    
    // helper
    
    private var fullScreenTransitionManager: FullScreenTransitionManager?
    
    private lazy var container: UIVisualEffectView = {
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        blurEffectView.layer.cornerRadius = 24
        blurEffectView.clipsToBounds = true
        return blurEffectView
    }()
    
    // geters
    
    public var image: UIImage? {
        get {
            imageView.image
        }
        set {
            imageView.image = newValue
            resizeImage()
        }
    }
    
    public var fullNameText: String {
        fullNameTextField.text ?? ""
    }
    
    public var aboutMeText: String {
        aboutMeTextView.text
    }
    
    
    // MARK: init
    
    private var addViewToScroll: [UIView]?
    private let user: SUser
    
    init(user: SUser, addViewToScroll: [UIView]? = nil) {
        self.user = user
        self.addViewToScroll = addViewToScroll
        super.init(nibName: nil, bundle: nil)
        imageView.sd_setImage(with: URL(string: user.avatarStringURL))
        fullNameTextField.text = user.username
        aboutMeTextView.text = user.description
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Live circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resizeImage()
    }
    
    // MARK: Action
    
    @objc private func chengePhoto() {
        delegate?.changeBegin()
        view.endEditing(true)
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true)
    }
    
    @objc private func imageTap() {
        view.endEditing(true)
        let fullScreenTransitionManager = FullScreenTransitionManager(anchorViewTag: 1)
        let fullScreenImageViewController = FullScreenImageViewController(image: imageView.image!, tag: 1)
        fullScreenImageViewController.modalPresentationStyle = .custom
        fullScreenImageViewController.transitioningDelegate = fullScreenTransitionManager
        self.present(fullScreenImageViewController, animated: true)
        self.fullScreenTransitionManager = fullScreenTransitionManager
    }
    
    public func changeCancel() {
        imageView.sd_setImage(with: URL(string: user.avatarStringURL))
        resizeImage()
        fullNameTextField.text = user.username
        aboutMeTextView.text = user.description
    }
    
    // Helpers
    
    private func resizeImage() {
        aspectRatioImage.isActive = false
        let aspectRatio = imageView.intrinsicContentSize.width / imageView.intrinsicContentSize.height
        aspectRatioImage = imageView.aspectRatio(aspectRatio)
    }
    
}

// MARK: UIImagePickerControllerDelegate
extension SettingProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        self.image = image
    }
}

// MARK: UITextViewDelegate
extension SettingProfileViewController: UITextViewDelegate {
    
    fileprivate func fixHeight(_ textView: UITextView) {
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
        if size.height != newSize.height {
            aboutMeTextViewHeight.constant = newSize.height
            UIView.animate(withDuration: 0.2) {
                textView.layoutIfNeeded()
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        fixHeight(textView)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.changeBegin()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.text = textView.text.trimmingCharacters(in: .newlines)
        fixHeight(textView)
    }
}

// MARK: UIScrollViewDelegate
extension SettingProfileViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

// MARK: UITextFieldDelegate
extension SettingProfileViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.changeBegin()
    }
}



// MARK: - Configuration

private extension SettingProfileViewController {
    
    func configuration() {
        configurationView()
        configurationScrollView()
        configurationSendTextField()
        configurationImageViewView()
        configurationConstraints()
    }
    
    func configurationView() {
        view.backgroundColor = ColorAppearance.white.color()
        pickButton.addTarget(self, action: #selector(chengePhoto), for: .touchUpInside)
    }
    
    func configurationScrollView() {
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
    }
    
    func configurationImageViewView() {
        imageView.backgroundColor = ColorAppearance.gray.color()
        imageView.tag = 1
        imageView.contentMode = .scaleAspectFit
        imageView.setHugging(.defaultHigh, for: .horizontal)
        imageView.setCompressionResistance(.defaultHigh, for: .horizontal)
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTap))
        imageView.addGestureRecognizer(tap)
    }
    
    func configurationSendTextField() {
        fullNameTextField.delegate = self
        aboutMeTextView.isScrollEnabled = false
        aboutMeTextView.delegate = self
    }
    
    func configurationConstraints() {
        view.addSubview(scrollView)
        scrollView.edgesToSuperview()
        scrollView.addSubview(imageView)
        scrollView.addSubview(container)
        
        imageView.topToSuperview()
        imageView.leadingToSuperview()
        imageView.trailingToSuperview()
        imageView.width(to: scrollView)
        
        let fillNameStackView = UIStackView(arrangedSubviews: [fullNameLabel, fullNameTextField], axis: .vertical, spacing: 0)
        let aboutStackView = UIStackView(arrangedSubviews: [aboutMeLabel, aboutMeTextView], axis: .vertical, spacing: 0)
        let view = [pickButton, fillNameStackView, aboutStackView] + (addViewToScroll ?? [])
        stackView = UIStackView(arrangedSubviews: view, axis: .vertical, spacing: 30)
        container.contentView.addSubview(stackView)
        stackView.edgesToSuperview(insets: .top(10) + .bottom(10) + .left(20) + .right(20))
        container.topToBottom(of: imageView, offset: -20)
        container.leftToSuperview()
        container.rightToSuperview()
        container.bottomToSuperview()
    }
}
