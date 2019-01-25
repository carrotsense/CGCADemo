//
//  WeatherChartView.swift
//  CGCADemo
//
//  Created by Sebastien Windal on 1/14/19.
//  Copyright © 2019 Sebastien Windal. All rights reserved.
//

import UIKit

struct WeatherChartViewSettings {
    
    let animationDurations: TimeInterval = 1.0
    
    let leftPadding:CGFloat = 30.0
    let rightPadding:CGFloat = 40.0
    let bottomPadding:CGFloat = 30.0
    let topPadding:CGFloat = 20.0
    
    let gridLineColor:UIColor = UIColor.lightGray
    let gridLineWidth:CGFloat = 0.5
    let gridLineDashPatten:[NSNumber] = [ NSNumber(value:2.0), NSNumber(value:5.0) ]
    
    let borderLineColor:UIColor = UIColor.gray
    let borderLineWidth:CGFloat = 1.0
    
    let textColor:UIColor = UIColor.black
    let textSize:CGFloat = 10.0
    
    let tempCircleStrokeColor = UIColor.orange
    let tempCircleColor = UIColor.white
    let tempCircleStrokeWidth:CGFloat = 1.5
    let tempCircleDiameter:CGFloat = 4.0
    let tempLineWidth:CGFloat = 1.5
    let tempLineColor:UIColor = UIColor.orange.withAlphaComponent(0.7)
    
    let precipitationLineColor:UIColor = UIColor.blue
    let precipitationGradientColors = [
        UIColor(hex: 0x7abcff).withAlphaComponent(0.9).cgColor,
        UIColor(hex: 0x0359c9).withAlphaComponent(0.9).cgColor
    ]
    let precipitationGradientLocation:[NSNumber] = [ NSNumber(value:0.2), NSNumber(value:0.8) ]
    let precipitationLineWidth: CGFloat = 0.5
    
    static var defaultSettings:WeatherChartViewSettings {
        return WeatherChartViewSettings()
    }
}

class WeatherChartView: UIView {
    
    //
    // MARK: - layers
    //
    
    // the horizontal dashed lines
    lazy private var gridLayer:CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = settings.gridLineColor.cgColor
        shapeLayer.lineWidth = settings.gridLineWidth
        shapeLayer.lineDashPattern = settings.gridLineDashPatten
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.contentsScale = UIScreen.main.scale
        return shapeLayer
    }()
    
    // the solid border
    lazy private var borderLayer:CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = settings.borderLineColor.cgColor
        shapeLayer.lineWidth = settings.borderLineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.contentsScale = UIScreen.main.scale
        return shapeLayer
    }()
    
    // temperature labels on the left
    lazy private var tempLabelLayers:[CATextLayer] = {
        let temps = stride(from: minTemp, to: maxTemp + tempInterval, by: tempInterval)
        var layers = [CATextLayer]()
        for t in temps {
            let layer = CATextLayer()
            layer.fontSize = settings.textSize
            layer.foregroundColor = settings.textColor.cgColor
            layer.string = "\(t)C"
            layer.contentsScale = UIScreen.main.scale
            layers.append(layer)
        }
        return layers
    }()
    
    // precipitation labels on the right
    lazy private var precipitaionLabelLayers:[CATextLayer] = {
        let prec = stride(from: minPrecipitation, to: maxPrecipitation + precipitationInterval, by: precipitationInterval)
        var layers = [CATextLayer]()
        for p in prec {
            let layer = CATextLayer()
            layer.fontSize = settings.textSize
            layer.foregroundColor = settings.textColor.cgColor
            layer.string = "\(Int(p))mm"
            layer.contentsScale = UIScreen.main.scale
            layers.append(layer)
        }
        return layers
    }()
    
    // month labels at the bottom
    lazy private var monthLabelLayers:[CATextLayer] = {
        let months = stride(from: monthMin, to: monthMax, by: 1)
        var layers = [CATextLayer]()
        for m in months {
            let layer = CATextLayer()
            layer.fontSize = settings.textSize
            layer.alignmentMode = CATextLayerAlignmentMode.center
            layer.foregroundColor = settings.textColor.cgColor
            layer.string = [ "J","F","M","A","M","J","J","A","S","O","N","D" ][Int(m)]
            layer.contentsScale = UIScreen.main.scale
            layers.append(layer)
        }
        return layers
    }()
    
    // the temperatre cirles, one per month
    lazy private var temperatureCirclesLayer:CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = settings.tempCircleStrokeColor.cgColor
        shapeLayer.lineWidth = settings.tempCircleStrokeWidth
        shapeLayer.fillColor = settings.tempCircleColor.cgColor
        shapeLayer.contentsScale = UIScreen.main.scale
        return shapeLayer
    }()
    
    // the temperatre line, connects the temperatre cirles
    lazy private var temperatureLineLayer:CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = settings.tempLineColor.cgColor
        shapeLayer.lineWidth = settings.tempLineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.contentsScale = UIScreen.main.scale
        return shapeLayer
    }()
    
    // precipitation bars clipping mask, one layer per bar/month
    lazy private var precipitationBarLayers:[CAShapeLayer] = {
        return (Int(monthMin)..<Int(monthMax)).map { _ in
            let shapeLayer = CAShapeLayer()
            shapeLayer.fillColor = UIColor.black.cgColor
            shapeLayer.contentsScale = UIScreen.main.scale
            return shapeLayer
        }
    }()
    
    // precipitation bars gradient layer, one layer per bar/month
    lazy private var precipitationGradientLayers:[CAGradientLayer] = {
        return (Int(monthMin)..<Int(monthMax)).map { _ in
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = settings.precipitationGradientColors
            gradientLayer.locations = settings.precipitationGradientLocation
            gradientLayer.contentsScale = UIScreen.main.scale
            return gradientLayer
        }
    }()
    
    //
    // MARK: - View lifecycle
    //
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    private func commonInit() {
        // add all layers to the chart, in that order.
        layer.addSublayer(borderLayer)
        layer.addSublayer(gridLayer)
        for l in tempLabelLayers {
            layer.addSublayer(l)
        }
        for l in precipitaionLabelLayers {
            layer.addSublayer(l)
        }
        for l in monthLabelLayers {
            layer.addSublayer(l)
        }
        for (i, l) in precipitationGradientLayers.enumerated() {
            layer.addSublayer(l)
            l.mask = precipitationBarLayers[i]
        }
        layer.addSublayer(temperatureLineLayer)
        layer.addSublayer(temperatureCirclesLayer)
    }
    
    //
    // all layers, except label layers must be full size
    //
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // resize all layers to match the chart new size
        borderLayer.frame = layer.bounds
        gridLayer.frame = layer.bounds
        temperatureLineLayer.frame = layer.bounds
        temperatureLineLayer.frame = layer.bounds
        for l in precipitationGradientLayers {
            l.frame = bounds
        }
        for l in precipitationBarLayers {
            l.frame = bounds
        }
        updateGrid(animated: false)
        updateLabels()
        updateTemperatureCircles(animated: false)
        updateTemperatureLine(animated: false)
        updatePrecipitationBars(animated: false)
    }
    
    //
    // MARK: - data, scales, etc...
    // in the real world those would be computed after parsing input data.
    //
    private var temperatures:[CGFloat] = []
    private var precipitations:[CGFloat] = []
    private let minTemp:CGFloat = -5
    private let maxTemp:CGFloat = 35
    private let tempInterval:CGFloat = 5
    private let monthMin:CGFloat = 0
    private let monthMax:CGFloat = 12
    
    private let minPrecipitation:CGFloat = 0
    private let maxPrecipitation:CGFloat = 200
    private let precipitationInterval: CGFloat = 25
    
    private var settings = WeatherChartViewSettings.defaultSettings

    // conversion C degree -> Point
    private var temperatureTransformMatrix:CGAffineTransform {
        let pointsPerMonth = (frame.width - settings.leftPadding - settings.rightPadding) / (monthMax - monthMin)
        let pointsPerDegree = (frame.height - settings.bottomPadding - settings.topPadding) / (maxTemp - minTemp)
        return CGAffineTransform(
            a: pointsPerMonth,
            b: 0,
            c: 0,
            d: -pointsPerDegree,
            tx: settings.leftPadding,
            ty: frame.height + minTemp * pointsPerDegree - settings.bottomPadding)
    }
    
    // conversion precipitation mm -> Point
    private var precipitationTransform:CGAffineTransform {
        let pointsPerMonth = (frame.width - settings.leftPadding - settings.rightPadding) / (monthMax - monthMin)
        let pointsPerMM = (frame.height - settings.bottomPadding - settings.topPadding) / (maxPrecipitation - minPrecipitation)
        return CGAffineTransform(
            a: pointsPerMonth,
            b: 0,
            c: 0,
            d: -pointsPerMM,
            tx: settings.leftPadding,
            ty: frame.height + minPrecipitation * pointsPerMM - settings.bottomPadding)
    }
    
}

//
// MARK: - our interface with the outside world.
//
extension WeatherChartView {
    
    public func updateChart(for city:City, animated:Bool) {
        self.temperatures = city.monthlyAvgTemperatureC
        self.precipitations = city.monthlyAvgPrecipitationmm
        updateGrid(animated: animated)
        updateTemperatureCircles(animated: animated)
        updateTemperatureLine(animated: animated)
        updatePrecipitationBars(animated: animated)
    }
}

//
// MARK: - path generation
//
extension WeatherChartView {
    
    private func newGridPath() -> CGPath {
        let path = CGMutablePath()
        
        // to simplify we will have a fixed number of lines every 5 degree, between -5 and 35C,
        for t in stride(from: minTemp + tempInterval, to: maxTemp, by: tempInterval) {
            path.move(to: CGPoint(x: monthMin, y: t), transform: temperatureTransformMatrix)
            path.addLine(to: CGPoint(x: monthMax, y: t), transform: temperatureTransformMatrix)
        }
        return path
    }
    
    private func newBorderPath() -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: monthMin, y: minTemp), transform: temperatureTransformMatrix)
        path.addLine(to: CGPoint(x: monthMin, y: maxTemp), transform: temperatureTransformMatrix)
        path.addLine(to: CGPoint(x: monthMax, y: maxTemp), transform: temperatureTransformMatrix)
        path.addLine(to: CGPoint(x: monthMax, y: minTemp), transform: temperatureTransformMatrix)
        path.closeSubpath()
        return path
    }
    
    private func newTemperatureCirclesPath() -> CGPath {
        let path = CGMutablePath()
        
        if temperatures.isEmpty {
            return path
        }
        
        for (i,t) in temperatures.enumerated() {
            let rect = CGRect(x: CGFloat(i) + 0.5, y: t, width: 0, height: 0) // the circle is located in the middle of the month hence +0.5
            let convertedRect = rect.applying(temperatureTransformMatrix)
            
            let r = settings.tempCircleDiameter / 2.0
            let coordinates = CGRect(x: convertedRect.origin.x - r, y: convertedRect.origin.y - r, width: settings.tempCircleDiameter, height: settings.tempCircleDiameter)
            
            path.addEllipse(in: coordinates)
        }
        return path
    }
    
    private func newTemperatureLinePath() -> CGPath {
        let path = CGMutablePath()
        
        if temperatures.isEmpty {
            return path
        }
        
        var first = true
        for (i,t) in temperatures.enumerated() {
            let point = CGPoint(x: CGFloat(i) + 0.5, y: t)
            
            if first {
                first = false
                path.move(to: point, transform: temperatureTransformMatrix)
            } else {
                path.addLine(to: point, transform: temperatureTransformMatrix)
            }
        }
        return path
    }
    
    private func newPrecipitationPaths() -> [CGPath] {
        
        if precipitations.isEmpty {
            return []
        }
        
        return (Int(monthMin)..<Int(monthMax)).map { month in
            let path = CGMutablePath()
            let mm = precipitations[month]
            let rect = CGRect(x: CGFloat(month)+0.07, y: 0, width: 0.86, height: mm)
            path.addRect(rect, transform:precipitationTransform)
            return path
        }
    }
}


//
// MARK: - animations
//
extension WeatherChartView {
    
    private func updateGrid(animated: Bool) {
        borderLayer.path = newBorderPath()
        gridLayer.path = newGridPath()
    }
    
    private func updateTemperatureCircles(animated: Bool) {
        let path = newTemperatureCirclesPath()
        
        if temperatureCirclesLayer.path == nil || !animated {
            temperatureCirclesLayer.path = path
            return
        }
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = temperatureCirclesLayer.path
        animation.toValue = path
        animation.duration = settings.animationDurations
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.fillMode = CAMediaTimingFillMode.both
        animation.isRemovedOnCompletion = false
        
        temperatureCirclesLayer.add(animation, forKey: animation.keyPath)
        temperatureCirclesLayer.path = path
    }
    
    private func updateTemperatureLine(animated: Bool) {
        let path = newTemperatureLinePath()
        
        if temperatureLineLayer.path == nil || !animated {
            temperatureLineLayer.path = path
            return
        }
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = temperatureLineLayer.path
        animation.toValue = path
        animation.duration = settings.animationDurations
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.fillMode = CAMediaTimingFillMode.both
        animation.isRemovedOnCompletion = false

        temperatureLineLayer.add(animation, forKey: animation.keyPath)
        temperatureLineLayer.path = path
    }
    
    private func updatePrecipitationBars(animated: Bool) {
        let paths = newPrecipitationPaths()
        
        if paths.isEmpty { return }
        
        for (i, l) in precipitationBarLayers.enumerated() {
            let path = paths[i]
            if l.path == nil || !animated {
                l.path = path
                continue
            }
            
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = l.path
            animation.toValue = path
            animation.duration = settings.animationDurations
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            animation.fillMode = CAMediaTimingFillMode.both
            animation.isRemovedOnCompletion = false
            
            l.add(animation, forKey: animation.keyPath)
            l.path = path
        }
        
    }
    
    //
    // label layers are different, they are not using the full size of the chart.
    // position each layer frame where it should be.
    //
    private func updateLabels() {
        
        let temps = stride(from: minTemp, to: maxTemp + tempInterval, by: tempInterval)
        
        for (i,temp) in temps.enumerated() {
            let pointInDegree = CGPoint(x: 0, y: temp)
            let pointInPoints = pointInDegree.applying(temperatureTransformMatrix)
            let l = tempLabelLayers[i]
            l.frame = CGRect(x: 0, y: pointInPoints.y - 7, width: settings.leftPadding, height: 20)
        }
        
        let precipitations = stride(from: minPrecipitation, to: maxPrecipitation + precipitationInterval, by: precipitationInterval)
        for (i,prec) in precipitations.enumerated() {
            let pointInMM = CGPoint(x: 0, y: prec)
            let pointInPoints = pointInMM.applying(precipitationTransform)
            let l = precipitaionLabelLayers[i]
            l.frame = CGRect(x: frame.width - settings.rightPadding + 5, y: pointInPoints.y - 7, width: settings.rightPadding, height: 20)
        }
        
        let months = stride(from: monthMin, to: monthMax, by: 1)
        for (i,month) in months.enumerated() {
            let rectInMonth = CGRect(x: month, y: 0, width: 1.0, height: 0)
            let rectInPoints = rectInMonth.applying(temperatureTransformMatrix)
            let l = monthLabelLayers[i]
            l.frame = CGRect(x: rectInPoints.origin.x, y: frame.height - settings.bottomPadding + 5, width: rectInPoints.width, height: 20)

        }
    }
}
