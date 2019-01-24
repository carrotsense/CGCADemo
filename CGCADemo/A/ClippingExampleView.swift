//
//  ClippingExampleView.swift
//  CGCADemo
//
//  Created by Sebastien Windal on 1/23/19.
//  Copyright © 2019 Sebastien Windal. All rights reserved.
//

import UIKit

class ClippingExampleView: UIView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.red.cgColor, UIColor.green.cgColor, UIColor.orange.cgColor]
        gradientLayer.locations = [ NSNumber(value: 0.2), NSNumber(value: 0.7), NSNumber(value: 1.0) ]
        gradientLayer.frame = bounds
        layer.addSublayer(gradientLayer)
        
        let maskLayer = CAShapeLayer()
        maskLayer.fillColor = UIColor.black.cgColor
        
        let path = CGMutablePath()
        path.move(to: CGPoint.zero)
        path.addEllipse(in: CGRect(x: 20, y: 20, width: 100, height: 100))
        path.addRect(CGRect(x: 200, y: 0, width: 30, height: 200))
        maskLayer.path = path
        maskLayer.frame = bounds
        
        gradientLayer.mask = maskLayer
    }
    

}
