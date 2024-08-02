//
//  SunView.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 03.07.2024.
//

import UIKit

final class SunView: UIView {
    
    var one: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = ColorAppearance.Sun.one.color().cgColor
        return layer
    }()
    
    var two: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = ColorAppearance.Sun.two.color().cgColor
        return layer
    }()
    
    var three: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = ColorAppearance.Sun.three.color().cgColor
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.insertSublayer(three, at: 1)
        layer.insertSublayer(two, at: 2)
        layer.insertSublayer(one, at: 3)
        
        create(frame: frame)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func create(frame: CGRect) {
        let sizeThree = frame.size * 0.75
        let rect = sizeThree.centered(in: frame)
        let threePath = UIBezierPath(ovalIn: rect)
        three.path = threePath.cgPath
        
        let sizeTwo = frame.size * 0.65
        let rectTwo = sizeTwo.centered(in: frame)
        let twoPath = UIBezierPath(ovalIn: rectTwo)
        two.path = twoPath.cgPath
        
        let sizeOne = frame.size * 0.55
        let rectThree = sizeOne.centered(in: frame)
        let onePath = UIBezierPath(ovalIn: rectThree)
        one.path = onePath.cgPath
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        create(frame: bounds)
    }
    
}
