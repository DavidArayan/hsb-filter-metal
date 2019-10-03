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
        
        // now we lerp(colorA, colorB, spanTime)
        // return (a * (1.0f - f)) + (b * f);
        let cgSpanTime:CGFloat = CGFloat(spanTime)
        
        // this could be SIMD accelerated for performance
        let lerpR:CGFloat = Util.lerp(colorA.red, b: colorB.red, t: cgSpanTime)
        let lerpG:CGFloat = Util.lerp(colorA.green, b: colorB.green, t: cgSpanTime)
        let lerpB:CGFloat = Util.lerp(colorA.blue, b: colorB.blue, t: cgSpanTime)
        let lerpA:CGFloat = Util.lerp(colorA.alpha, b: colorB.alpha, t: cgSpanTime)
        
        // create and return our generated/lerped UIColor
        return UIColor(red: lerpR, green: lerpG, blue: lerpB, alpha: lerpA)
    }
}
