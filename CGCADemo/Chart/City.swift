//
//  City.swift
//  CGCADemo
//
//  Created by Sebastien Windal on 1/14/19.
//  Copyright © 2019 Sebastien Windal. All rights reserved.
//

import UIKit

struct City {
    let name:String
    let monthlyAvgPrecipitationmm:[CGFloat]
    let monthlyAvgTemperatureC:[CGFloat]
    
    
    init(name:String, resourceName:String) {
        self.name = name
        
        let filePath = Bundle.main.url(forResource: resourceName, withExtension: "json")!

        let data = try! Data(contentsOf: filePath, options: .mappedIfSafe)
        
        let weatherData = try! JSONDecoder().decode(WeatherData.self, from: data)
        
        self.monthlyAvgTemperatureC = weatherData.temperature
        self.monthlyAvgPrecipitationmm = weatherData.precipitation
    }
}

