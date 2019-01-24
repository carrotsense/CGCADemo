//
//  SomeViewController.swift
//  CGCADemo
//
//  Created by Sebastien Windal on 1/15/19.
//  Copyright © 2019 Sebastien Windal. All rights reserved.
//

import UIKit

class SomeViewController: UIViewController {

    @IBOutlet weak var chartView: WeatherChartView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let cities = [
        City(name: "San Francisco", resourceName: "sf"),
        City(name: "Redwood City", resourceName: "rwc"),
        City(name: "San Jose", resourceName: "sanjose"),
        City(name: "Las Vegas", resourceName: "vegas"),
        City(name: "Vancouver", resourceName: "vancouver"),
        City(name: "Warsaw", resourceName: "warsaw"),
        City(name: "Toronto", resourceName: "toronto"),
        City(name: "Hong Kong", resourceName: "hk"),
        City(name: "Mumbai", resourceName: "mumbai")
    ]
    
    var index = 0
    
    @IBAction func someAction(_ sender: Any) {
        index += 1
        
        chartView.updateChart(for: cities[index % cities.count], animated: true)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

}

extension SomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let city = cities[indexPath.row]
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CityCollectionViewCell", for: indexPath) as? CityCollectionViewCell else {
            fatalError("CityCollectionViewCell dequeue failed")
        }
        cell.cityLabel.text = city.name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let city = cities[indexPath.row]
        
        chartView.updateChart(for: city, animated: true)
    }
    
}
