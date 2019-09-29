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
struct GradientValue {
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
    func setBackgroundGradient(gradients: [GradientValue], height:CGFloat) {
        let gradientLayer = gradients.gradientLayer
        
        gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.bounds.width, height: height)

        UIGraphicsBeginImageContextWithOptions(gradientLayer.frame.size, false, 0.0)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        self.setMaximumTrackImage(image?.resizableImage(withCapInsets:.zero),  for: .normal)
        self.setMinimumTrackImage(image?.resizableImage(withCapInsets:.zero),  for: .normal)
    }
}

/**
 * Extend the Array of GradientValue type and provide some helper
 * functionality to make the rest of the implementation a little easier
 * and clearer.
 */
extension Array where Element == GradientValue {
    
    var colorList:[UIColor] {
        get {
            var colors = [UIColor]()
            
            for gValue in self {
                colors.append(gValue.color)
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
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
            gradientLayer.transform = CATransform3DMakeRotation(CGFloat.pi / 2, 0, 0, 1)
            
            return gradientLayer
        }
    }
}
