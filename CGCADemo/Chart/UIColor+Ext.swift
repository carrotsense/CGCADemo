//
//  UIColor+Ext.swift
//  CGCADemo
//
//  Created by Sebastien Windal on 1/19/19.
//  Copyright © 2019 Sebastien Windal. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(hex:Int) {
        
        let red = (hex & 0x00FF0000) >> 16
        let green = (hex & 0x0000FF00) >> 8
        let blue = hex & 0x000000FF
        
        
        self.init(displayP3Red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1.0)
    }
    
}
