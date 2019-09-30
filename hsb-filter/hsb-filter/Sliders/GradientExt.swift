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
    func setBackgroundGradient(gradients: [GradientValue], height:CGFloat) {
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
            gradientLayer.cornerRadius = 1.25
            
            return gradientLayer
        }
    }
    
    /**
     * Helper function that returns the RGBA Colors as a tuple at the provided
     * array position. This is used for performing interpolation operations on our
     * list of gradient values.
     */
    func getRGBA(atIndex:Int) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        self[atIndex].color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }
    
    /**
     * Perform a linear interpolation function using the current gradient array, taking into
     * account the positional information
     */
    func colorAt(position:Float) -> UIColor {
        // WARNING: Float equality comparison
        if (position <= self[0].position) {
            return self[0].color
        }
        
        // WARNING: Float equality comparison
        if (position >= self[count - 1].position) {
            return self[count - 1].color
        }
        
        var end:Int = 1
        
        // linear search which is O(n). This is ok considering we
        // are not dealing with super-massive arrays, however if
        // performance is an issue, can switch to Binary Search
        // which is O(log(n))
        while (self[end].position < position) {
            end += 1
        }
        
        // this involves alot of array access, and can be optimised
        // if array lookups (for whatever reason) are slow. Can be a performance
        // penalty if doing millions of ops per frame, not a concern here
        let spanTime:Float = (position - self[end - 1].position) / (self[end].position - self[end - 1].position)
        
        let colorA = self.getRGBA(atIndex: end - 1)
        let colorB = self.getRGBA(atIndex: end)
        
        // define our lerp function
        func lerp(a:CGFloat, b:CGFloat, t:CGFloat) -> CGFloat {
            return (a * (1.0 - t)) + (b * t);
        }
        
        // now we lerp(colorA, colorB, spanTime)
        // return (a * (1.0f - f)) + (b * f);
        let cgSpanTime:CGFloat = CGFloat(spanTime)
        
        // this could be SIMD accelerated for performance
        let lerpR:CGFloat = lerp(a: colorA.red, b: colorB.red, t: cgSpanTime)
        let lerpG:CGFloat = lerp(a: colorA.green, b: colorB.green, t: cgSpanTime)
        let lerpB:CGFloat = lerp(a: colorA.blue, b: colorB.blue, t: cgSpanTime)
        let lerpA:CGFloat = lerp(a: colorA.alpha, b: colorB.alpha, t: cgSpanTime)
        
        // create and return our generated/lerped UIColor
        return UIColor(red: lerpR, green: lerpG, blue: lerpB, alpha: lerpA)
    }
}
