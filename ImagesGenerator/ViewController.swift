//
//  ViewController.swift
//  ImagesGenerator
//
//  Created by Massimiliano Bigatti on 19/06/15.
//  Copyright © 2015 Massimiliano Bigatti. All rights reserved.
//

import UIKit
import CoreGraphics

class ViewController: UIViewController {

    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var color1TextField: UITextField!
    @IBOutlet weak var lineWidthTextField: UITextField!
    @IBOutlet weak var color2TextField: UITextField!
    @IBOutlet weak var sizeSlider: UISlider!
    
    let gradientLayer = CAGradientLayer()
    let shapeLayer = CAShapeLayer()
    let backgroundShapeLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        //
        //
        gradientLayer.frame = CGRect(x: 0, y: 0, width: circleView.layer.frame.width, height: circleView.layer.frame.height)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.mask = shapeLayer
        
        circleView.layer.addSublayer(backgroundShapeLayer)
        circleView.layer.addSublayer(gradientLayer)
                
        updateImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sizeSliderValueChanged(sender: UISlider) {
        updateImage()
    }
    
    @IBAction func dataChanged(sender: UITextField) {
        updateImage()
    }
    
    @IBAction func export(sender: UIButton) {
        let oldSize = sizeSlider.value
        
        for index in 1...60 {
            sizeSlider.setValue(Float(index), animated: false)
            updateImage()
            
            let filename = "progress-\(index)@2x.png"
            saveImage(filename)
        }
        
        sizeSlider.value = oldSize
        updateImage()
    }
    
    private func updateImage() {
        updateGradient()
        updateBackgroundShape()
        updateArcShape()
    }
    
    private func updateGradient() {
        //
        // gradient
        //
        let color1 = UIColor.colorWithRGBString(color1TextField.text!)
        let color2 = UIColor.colorWithRGBString(color2TextField.text!)
        
        var colors = [AnyObject]()
        colors.append(color1.CGColor)
        colors.append(color2.CGColor)
        
        gradientLayer.colors = colors
    }
    
    private func updateBackgroundShape() {
        let center = CGPoint(x: circleView.frame.size.width / 2, y: circleView.frame.size.height / 2)
        
        let bezierPath = UIBezierPath(arcCenter: center,
            radius: (circleView.frame.size.width - CGFloat(strtoul(lineWidthTextField.text!, nil, 10))) / 2,
            startAngle: CGFloat(-M_PI_2),
            endAngle: CGFloat(3 * M_PI_2),
            clockwise: true)
        
        let path = CGPathCreateCopyByStrokingPath(bezierPath.CGPath, nil, CGFloat(strtoul(lineWidthTextField.text!, nil, 10)), bezierPath.lineCapStyle, bezierPath.lineJoinStyle, bezierPath.miterLimit)
        
        backgroundShapeLayer.path = path
        backgroundShapeLayer.fillColor = UIColor(white: 1.0, alpha: 0.2).CGColor
    }
    
    private func updateArcShape() {
        let center = CGPoint(x: circleView.frame.size.width / 2, y: circleView.frame.size.height / 2)
        
        let endAngle = (Double(sizeSlider.value) * 4 * M_PI_2) / 60 - M_PI_2
        
        let bezierPath = UIBezierPath(arcCenter: center,
            radius: (circleView.frame.size.width - CGFloat(strtoul(lineWidthTextField.text!, nil, 10))) / 2,
            startAngle: CGFloat(-M_PI_2),
            endAngle: CGFloat(endAngle),
            clockwise: true)
        
        bezierPath.lineCapStyle = .Round
        
        let path = CGPathCreateCopyByStrokingPath(bezierPath.CGPath, nil, CGFloat(strtoul(lineWidthTextField.text!, nil, 10)), bezierPath.lineCapStyle, bezierPath.lineJoinStyle, bezierPath.miterLimit)
        
        shapeLayer.path = path
    }
    
    func saveImage(filename: String) {
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
        let localUrl = NSURL(string: filename, relativeToURL: documentsUrl)!
        print("\(localUrl)")
        
        let color = circleView.backgroundColor;
        circleView.backgroundColor = UIColor.clearColor()
        
        UIGraphicsBeginImageContext(circleView.frame.size);
        
        circleView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        let imageData = UIImagePNGRepresentation(image);
        imageData?.writeToURL(localUrl, atomically: true)
        
        circleView.backgroundColor = color;
    }
}

extension UIColor {
     class func colorWithRGBString(hexString: String) -> UIColor {
        let redString = hexString.substringWithRange(Range(start: hexString.startIndex, end: hexString.startIndex.advancedBy(2)))
        let greenString = hexString.substringWithRange(Range(start: hexString.startIndex.advancedBy(2), end: hexString.startIndex.advancedBy(4)))
        let blueString = hexString.substringWithRange(Range(start: hexString.startIndex.advancedBy(4), end: hexString.startIndex.advancedBy(6)))
        
        let red = CGFloat(strtoul(redString, nil, 16)) / 255
        let green = CGFloat(strtoul(greenString, nil, 16)) / 255
        let blue = CGFloat(strtoul(blueString, nil, 16)) / 255
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

