//
//  WeatherData.swift
//  CGCADemo
//
//  Created by Sebastien Windal on 1/14/19.
//  Copyright © 2019 Sebastien Windal. All rights reserved.
//

import Foundation
import UIKit

struct WeatherData: Decodable {
    var temperature:[CGFloat] = []
    var precipitation:[CGFloat] = []
}
