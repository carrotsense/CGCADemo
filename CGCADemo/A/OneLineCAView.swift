//
//  oneLineCAView.swift
//  CGCADemo
//
//  Created by Sebastien Windal on 1/13/19.
//  Copyright © 2019 Sebastien Windal. All rights reserved.
//

import UIKit

class OneLineCAView: UIView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let lineLayer = CAShapeLayer()
        lineLayer.strokeColor = UIColor.black.cgColor
        let path = CGMutablePath()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: 100, y: 50))
        lineLayer.path = path
        
        layer.addSublayer(lineLayer)
    }

}
