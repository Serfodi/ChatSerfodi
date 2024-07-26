//
//  FullScreenPresentationController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 22.07.2024.
//

import UIKit
import TinyConstraints

final class FullScreenPresentationController: UIPresentationController {
    
    private let blurEffect = UIBlurEffect(style: .systemThinMaterial)
    
    private lazy var closeButtonContainer: UIVisualEffectView = {
        let closeButtonBlurEffectView = UIVisualEffectView(effect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(close), for: .primaryActionTriggered)
        closeButtonBlurEffectView.contentView.addSubview(vibrancyEffectView)
        vibrancyEffectView.contentView.addSubview(button)
        button.edgesToSuperview()
        vibrancyEffectView.edgesToSuperview()
        closeButtonBlurEffectView.layer.cornerRadius = 24
        closeButtonBlurEffectView.clipsToBounds = true
        closeButtonBlurEffectView.size(CGSize(width: 48, height: 48))
        return closeButtonBlurEffectView
    }()
    
    private lazy var backgroundView: UIVisualEffectView = {
        let blurVisualEffectView = UIVisualEffectView(effect: blurEffect)
        blurVisualEffectView.effect = nil
        return blurVisualEffectView
    }()
    
    private lazy var swipeDownGesture: UISwipeGestureRecognizer = {
        let swipeGestureRecognizer =  UISwipeGestureRecognizer(target: self, action: #selector(close))
        swipeGestureRecognizer.direction = .down
        return swipeGestureRecognizer
    }()
    
    private lazy var swipeUpGesture: UISwipeGestureRecognizer = {
        let swipeGestureRecognizer =  UISwipeGestureRecognizer(target: self, action: #selector(close))
        swipeGestureRecognizer.direction = .up
        return swipeGestureRecognizer
    }()
    
    @objc private func close() {
        presentedViewController.dismiss(animated: true)
    }
    
}

// MARK: override UIPresentationController

extension FullScreenPresentationController {
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        
        containerView.addSubview(backgroundView)
        containerView.addSubview(closeButtonContainer)
        backgroundView.edgesToSuperview()
        closeButtonContainer.topToSuperview(offset: 16, usingSafeArea: true)
        closeButtonContainer.trailingToSuperview(offset: 16, usingSafeArea: true)
        
        guard let transitionCoordinator = presentingViewController.transitionCoordinator else { return }
        
        closeButtonContainer.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        transitionCoordinator.animate(alongsideTransition: { context in
            self.backgroundView.effect = self.blurEffect
            self.closeButtonContainer.transform = .identity
        })
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            backgroundView.removeFromSuperview()
            closeButtonContainer.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {
        guard let transitionCoordinator = presentingViewController.transitionCoordinator else { return }
        
        transitionCoordinator.animate(alongsideTransition: { context in
            self.backgroundView.effect = nil
            self.closeButtonContainer.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        })
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            backgroundView.removeFromSuperview()
            closeButtonContainer.removeFromSuperview()
        }
    }
    
    
}
