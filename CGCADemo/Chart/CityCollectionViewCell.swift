//
//  CityCollectionViewCell.swift
//  CGCADemo
//
//  Created by Sebastien Windal on 1/19/19.
//  Copyright © 2019 Sebastien Windal. All rights reserved.
//

import UIKit

class CityCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cityLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = UIColor.black
                cityLabel.textColor = UIColor.white
            } else {
                backgroundColor = UIColor.white
                cityLabel.textColor = UIColor.black
            }
        }
    }
}
