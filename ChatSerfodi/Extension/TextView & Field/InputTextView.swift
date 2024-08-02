//
//  InputTextView.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 26.07.2024.
//

import UIKit

class InputTextView: UITextView {
    
    private let placeholderLabel = UILabel()
    
    var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
            placeholderLabel.sizeToFit()
        }
    }
    
    // MARK: Init
        
    init(font: UIFont, textColor: UIColor = ColorAppearance.black.color(), backgroundColor: UIColor, textContainerInset: UIEdgeInsets? = nil) {
        super.init(frame: .zero, textContainer: nil)
        commonInit()
        self.font = font
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        if let textContainerInset = textContainerInset {
            self.textContainerInset = textContainerInset
        }
        self.layer.borderColor = ColorAppearance.lightBlack.color().cgColor
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: textContainerInset?.top ?? 0).isActive = true
        placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ((textContainerInset?.left ?? 0) + 4)).isActive = true
        placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -(textContainerInset?.right ?? 0)).isActive = true
        placeholderLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -(textContainerInset?.bottom ?? 0)).isActive = true
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func commonInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: UITextView.textDidChangeNotification, object: nil)
        placeholderLabel.font = font
        placeholderLabel.textColor = ColorAppearance.lightBlack.color()
        placeholderLabel.numberOfLines = 0
        addSubview(placeholderLabel)
    }
    
    @objc private func textDidChange(_ notification: Notification) {
        placeholderLabel.isHidden = !text.isEmpty
    }
    
}


extension UITextView {
    
    func numberOfLines() -> Int {
        guard let font = font else { return 0 }
        let contentHeight = contentSize.height
        let lineHeight = font.lineHeight
        let numberOfLines = Int(contentHeight / lineHeight)
        return numberOfLines
    }
}


