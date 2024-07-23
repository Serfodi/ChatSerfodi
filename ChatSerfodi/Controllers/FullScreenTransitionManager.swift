//
//  FullScreenTransitionManager.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 22.07.2024.
//

import UIKit

final class FullScreenTransitionManager: NSObject, UIViewControllerTransitioningDelegate {
    
    private let anchorViewTag: Int
    private weak var anchorView: UIView?
    
    init(anchorViewTag: Int) {
        self.anchorViewTag = anchorViewTag
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        anchorView = (presenting ?? source).view.viewWithTag(anchorViewTag)
        return FullScreenPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        FullScreenAnimationController(animationType: .present, anchorView: anchorView)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        FullScreenAnimationController(animationType: .dismiss, anchorView: anchorView)
    }
}
