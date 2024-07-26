//
//  FullScreenImageViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 22.07.2024.
//

import UIKit

/*

class FullScreenImageViewController: UIViewController {
    
    var zoomAnimator = UIViewPropertyAnimator()
    
    private lazy var zoomButtonContainer: UIVisualEffectView = {
        let closeButtonBlurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
        closeButtonBlurEffectView.layer.cornerRadius = 24
        closeButtonBlurEffectView.clipsToBounds = true
        closeButtonBlurEffectView.frame.size = CGSize(width: 120, height: 48)
        let button = UIButton(type: .system)
        button.setTitle("Zoom", for: .normal)
        button.titleLabel?.font = FontAppearance.buttonText
        button.configuration?.imagePadding = -10
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        button.setImage(UIImage(systemName: "arrow.down.right.and.arrow.up.left"), for: .normal)
        button.addTarget(self, action: #selector(zooming), for: .primaryActionTriggered)
        
        let vibrancyEffectView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect:  UIBlurEffect(style: .systemThinMaterial)))
        closeButtonBlurEffectView.contentView.addSubview(vibrancyEffectView)
        vibrancyEffectView.contentView.addSubview(button)
        
        button.frame = vibrancyEffectView.bounds
        button.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        closeButtonBlurEffectView.translatesAutoresizingMaskIntoConstraints = false
        closeButtonBlurEffectView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        closeButtonBlurEffectView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
        vibrancyEffectView.frame = closeButtonBlurEffectView.bounds
        vibrancyEffectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        return closeButtonBlurEffectView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bouncesZoom = true
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
        
//    private let imageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFit
//        imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//        imageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
//        return imageView
//    }()
    
    private var imageView: UIImageView!
    
    
//    private lazy var imageViewLandscapeConstraint = imageView.heightToSuperview(isActive: false, usingSafeArea: true)
//    private lazy var imageViewPortraitConstraint = imageView.widthToSuperview(isActive: false, usingSafeArea: true)
    
    // MARK: init
    
    init (image: UIImage, tag: Int) {
        super.init(nibName: nil, bundle: nil)
        imageView = UIImageView(image: image)
        imageView.tag = tag
        
        scrollView.contentSize = image.size
        setupCurrentMaxandMinZoomScale()
        
//        scrollView.zoomScale = scrollView.maximumZoomScale
//        let margin = (self.view.bounds.size - scrollView.contentSize) * 0.5
//        let insets = [margin.width, margin.height].map { $0 > 0 ? $0 : 0 }
//        scrollView.contentInset = UIEdgeInsets(top: insets[1], left: insets[0], bottom: insets[1], right: insets[0])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureBehaviour()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        let margin = (self.view.bounds.size - scrollView.contentSize) * 0.5
        let insets = [margin.width, margin.height].map { $0 > 0 ? $0 : 0 }
        scrollView.contentInset = UIEdgeInsets(top: insets[1], left: insets[0], bottom: insets[1], right: insets[0])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scrollView.setContentOffset(scrollView.contentOffset, animated: false)
        showZoomOutAnimation(false)
    }
    
    
    // MARK: Action
    
    @objc func zooming(_ sender: UIButton) {
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
    }
    
    // MARK: Helpers
    
    func showZoomOutAnimation(_ isShow: Bool) {
        guard !zoomAnimator.isRunning else { return }
        zoomAnimator = UIViewPropertyAnimator(duration: 0.15, curve: .easeIn)
        switch isShow {
        case true:
            // Show "zoom"
            self.zoomButtonContainer.isHidden = false
            zoomAnimator.addAnimations {
                self.zoomButtonContainer.transform = .identity
            }
        case false:
            // Hide "zoom"
            zoomAnimator.addAnimations {
                self.zoomButtonContainer.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
            }
            zoomAnimator.addCompletion { pozition in
                if pozition == .end {
                    self.zoomButtonContainer.isHidden = true
                }
            }
        }
        zoomAnimator.startAnimation()
    }
    
}

// MARK: Configuration
extension FullScreenImageViewController {
        
    private func setupCurrentMaxandMinZoomScale() {
        let boundsSize = self.view.bounds.size
        let imageSize = imageView.image!.size

        let xScale = boundsSize.width / imageSize.width
        let yScale = boundsSize.height / imageSize.height
        let minScale = min(xScale, yScale)

        var maxScale = 1.0
        if minScale < 0.1 {
            maxScale = 0.3
        }
        if minScale >= 0.1 && minScale < 0.5  {
            maxScale = 0.7
        }
        if minScale >= 0.5 {
            maxScale = max(1.0, minScale)
        }
        scrollView.maximumZoomScale = maxScale
        scrollView.minimumZoomScale = minScale
    }
    
    
    
    private func configure() {
        view.backgroundColor = .clear
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(zoomButtonContainer)
        
        scrollView.frame = self.view.bounds
        scrollView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        zoomButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        zoomButtonContainer.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        zoomButtonContainer.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    
    private func configureBehaviour() {
        scrollView.delegate = self
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(zoomMaxMin))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGestureRecognizer)
    }
        
    @objc private func zoomMaxMin(_ sender: UITapGestureRecognizer) {
        if scrollView.zoomScale == scrollView.maximumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            showZoomOutAnimation(false)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
            showZoomOutAnimation(true)
        }
    }
    
}

// MARK: UIScrollViewDelegate

extension FullScreenImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        showZoomOutAnimation(true)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if self.scrollView.zoomScale <= self.scrollView.minimumZoomScale {
            showZoomOutAnimation(false)
        }
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if self.scrollView.zoomScale <= self.scrollView.minimumZoomScale {
            showZoomOutAnimation(false)
        }
    }
}


*/


import TinyConstraints

class FullScreenImageViewController: UIViewController {
    
    private lazy var zoomButtonContainer: UIVisualEffectView = {
        let closeButtonBlurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
        closeButtonBlurEffectView.layer.cornerRadius = 24
        closeButtonBlurEffectView.clipsToBounds = true
        closeButtonBlurEffectView.size(CGSize(width: 120, height: 48))
        
        let button = UIButton(type: .system)
        button.setTitle("Zoom", for: .normal)
        button.titleLabel?.font = FontAppearance.buttonText
        button.configuration?.imagePadding = -10
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        button.setImage(UIImage(systemName: "arrow.down.right.and.arrow.up.left"), for: .normal)
        button.addTarget(self, action: #selector(zooming), for: .primaryActionTriggered)
        
        let vibrancyEffectView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect:  UIBlurEffect(style: .systemThinMaterial)))
        closeButtonBlurEffectView.contentView.addSubview(vibrancyEffectView)
        vibrancyEffectView.contentView.addSubview(button)
        
        button.frame = vibrancyEffectView.bounds
        button.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        vibrancyEffectView.frame = closeButtonBlurEffectView.bounds
        vibrancyEffectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        return closeButtonBlurEffectView
    }()
    
    var zoomAnimator = UIViewPropertyAnimator()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bouncesZoom = true
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let wrapperView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let octocatImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setHugging(.defaultHigh, for: .horizontal)
        imageView.setCompressionResistance(.defaultHigh, for: .horizontal)
        return imageView
    }()
    
    private lazy var imageViewLandscapeConstraint = octocatImageView.heightToSuperview(isActive: false, usingSafeArea: true)
    private lazy var imageViewPortraitConstraint = octocatImageView.widthToSuperview(isActive: false, usingSafeArea: true)
    
    init(image: UIImage, tag: Int) {
        super.init(nibName: nil, bundle: nil)
        octocatImageView.tag = tag
        octocatImageView.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureBehaviour()
        showZoomOutAnimation(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Force any ongoing scrolling to stop and prevent the image view jumping during dismiss animation.
        // Which is caused by the scroll animation and dismiss animation running at the same time.
        scrollView.setContentOffset(scrollView.contentOffset, animated: false)
        showZoomOutAnimation(false)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        traitCollectionChanged(from: previousTraitCollection)
    }
    
    private func configureUI() {
        view.backgroundColor = .clear
        
        view.addSubview(scrollView)
        view.addSubview(zoomButtonContainer)
        
        scrollView.addSubview(wrapperView)
        wrapperView.addSubview(octocatImageView)
        
        scrollView.edgesToSuperview()
        
        zoomButtonContainer.topToSuperview(offset: 16, usingSafeArea: true)
        zoomButtonContainer.centerXToSuperview()
        
        // The wrapper view will fill up the scroll view, and act as a target for pinch and pan event
        wrapperView.edges(to: scrollView.contentLayoutGuide)
        wrapperView.width(to: scrollView.safeAreaLayoutGuide)
        wrapperView.height(to: scrollView.safeAreaLayoutGuide)
        
        octocatImageView.centerInSuperview()
        
        // Constraint UIImageView to fit the aspect ratio of the containing image
        let aspectRatio = octocatImageView.intrinsicContentSize.height / octocatImageView.intrinsicContentSize.width
        octocatImageView.heightToWidth(of: octocatImageView, multiplier: aspectRatio)
    }
    
    private func configureBehaviour() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        // scrollView.maximumZoomScale = 1.0001 // "Hack" to enable bouncy zoom without zooming
        scrollView.maximumZoomScale = 2.0
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(zoomMaxMin))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    private func traitCollectionChanged(from previousTraitCollection: UITraitCollection?) {
        if traitCollection.horizontalSizeClass != .compact {
            // Ladscape
            imageViewPortraitConstraint.isActive = false
            imageViewLandscapeConstraint.isActive = true
        } else {
            // Portrait
            imageViewLandscapeConstraint.isActive = false
            imageViewPortraitConstraint.isActive = true
        }
    }
    
    func showZoomOutAnimation(_ isShow: Bool) {
        guard !zoomAnimator.isRunning else { return }
        zoomAnimator = UIViewPropertyAnimator(duration: 0.15, curve: .easeIn)
        switch isShow {
        case true:
            // Show "zoom"
            self.zoomButtonContainer.isHidden = false
            zoomAnimator.addAnimations {
                self.zoomButtonContainer.transform = .identity
            }
        case false:
            // Hide "zoom"
            zoomAnimator.addAnimations {
                self.zoomButtonContainer.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
            }
            zoomAnimator.addCompletion { pozition in
                if pozition == .end {
                    self.zoomButtonContainer.isHidden = true
                }
            }
        }
        zoomAnimator.startAnimation()
    }
    
    @objc private func zoomMaxMin(_ sender: UITapGestureRecognizer) {
        if scrollView.zoomScale == scrollView.maximumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            showZoomOutAnimation(false)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
            showZoomOutAnimation(true)
        }
    }
    
    @objc func zooming(_ sender: UIButton) {
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
    }
    
}

// MARK: UIScrollViewDelegate

extension FullScreenImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        octocatImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        if self.scrollView.zoomScale <= self.scrollView.minimumZoomScale {
            showZoomOutAnimation(false)
        }
        
        // Make sure the zoomed image stays centred
        let currentContentSize = scrollView.contentSize
        let originalContentSize = wrapperView.bounds.size
        let offsetX = max((originalContentSize.width - currentContentSize.width) * 0.5, 0)
        let offsetY = max((originalContentSize.height - currentContentSize.height) * 0.5, 0)
        octocatImageView.center = CGPoint(x: currentContentSize.width * 0.5 + offsetX,
                                          y: currentContentSize.height * 0.5 + offsetY)
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        showZoomOutAnimation(true)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if self.scrollView.zoomScale <= self.scrollView.minimumZoomScale {
            showZoomOutAnimation(false)
        }
    }
    
}
