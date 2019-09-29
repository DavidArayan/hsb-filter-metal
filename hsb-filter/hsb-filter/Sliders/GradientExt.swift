//
//  BaseSlider.swift
//  hsb-filter
//
//  Created by David Arayan on 29/9/19.
//  Copyright © 2019 David Arayan. All rights reserved.
//

import Foundation
import UIKit

/**
 * This is a custom gradient value with a color and position.
 * Used for setting the background gradient texture for UISlider
 * components.
 */
public struct GradientValue {
    let color: UIColor
    let position: Float
}

/**
 * We will add stateless extension functions to the UISlider component
 * for setting the background gradient etc.. This simplifies the design and
 * ensures functionality is encapsulated properly.
 *
 * We could also just extend the UISlider with a base class
 */
extension UISlider {
    
    /**
     * Sets the background gradient provided a list of gradients and a height value for the slider
     */
    public func setBackgroundGradient(gradients: [GradientValue], height:CGFloat) {
        let gradientLayer = gradients.gradientLayer
        
        gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: height)

        UIGraphicsBeginImageContextWithOptions(gradientLayer.frame.size, false, 0.0)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let sretchedImage = image?.stretchableImage(withLeftCapWidth: 14, topCapHeight: 0)

        self.setMinimumTrackImage(sretchedImage, for: .normal)
        self.setMaximumTrackImage(sretchedImage, for: .normal)
    }
}

/**
 * Extend the Array of GradientValue type and provide some helper
 * functionality to make the rest of the implementation a little easier
 * and clearer.
 */
extension Array where Element == GradientValue {
    
    var colorList:[CGColor] {
        get {
            var colors = [CGColor]()
            
            for gValue in self {
                colors.append(gValue.color.cgColor)
            }
            
            return colors
        }
    }
    
    var colorPositionList:[NSNumber] {
        get {
            var positions = [NSNumber]()
            
            for gValue in self {
                positions.append(NSNumber(value: gValue.position))
            }
            
            return positions
        }
    }
    
    /**
     * Simple helper function that generates a CAGradientLayer from the current array of
     * GradientValue types. Should be a simple case of plug and play with the UISlider
     * component.
     */
    var gradientLayer:CAGradientLayer {
        get {
            let gradientLayer = CAGradientLayer()
            
            gradientLayer.locations = self.colorPositionList
            gradientLayer.colors = self.colorList
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            gradientLayer.cornerRadius = 1.25;
            
            return gradientLayer
        }
    }
}
