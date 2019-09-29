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
    func setBackgroundGradient(gradients: [GradientValue]) {
        // to-do
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
    
    var colorPositionList:[Float] {
        get {
            var positions = [Float]()
            
            for gValue in self {
                positions.append(gValue.position)
            }
            
            return positions
        }
    }
}
