//
//  UtilExt.swift
//  hsb-filter
//
//  Created by David Arayan on 30/9/19.
//  Copyright © 2019 David Arayan. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    /**
     * Helper function to create a custom sized thumb, this will be used to both change the color
     * and interpolate custom size when the user pressed up/down
     */
    public class func createThumbImage(size: CGFloat, color: UIColor) -> UIImage {
        let layerFrame = CGRect(x: 0, y: 0, width: size, height: size)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = CGPath(ellipseIn: layerFrame.insetBy(dx: 1, dy: 1), transform: nil)
        shapeLayer.fillColor = color.cgColor
        shapeLayer.strokeColor = color.withAlphaComponent(0.65).cgColor

        let layer = CALayer.init()
        layer.frame = layerFrame
        layer.addSublayer(shapeLayer)
        
        return layer.image
    }
}

extension CALayer {
    var image:UIImage {
        get {
            UIGraphicsBeginImageContextWithOptions(self.frame.size, false, UIScreen.main.scale)
            self.render(in: UIGraphicsGetCurrentContext()!)
            let outputImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return outputImage!
        }
    }
}
