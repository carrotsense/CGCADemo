//
//  OneLineCGView.swift
//  CGCADemo
//
//  Created by Sebastien Windal on 1/13/19.
//  Copyright © 2019 Sebastien Windal. All rights reserved.
//

import UIKit

class OneLineCGView: UIView {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext()!
        context.setStrokeColor(UIColor.black.cgColor)
        let path = CGMutablePath()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x:100, y: 50))
        context.addPath(path)
        context.strokePath()
    }

}
