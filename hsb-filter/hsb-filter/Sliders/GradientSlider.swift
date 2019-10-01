//
//  GradientSlider.swift
//  hsb-filter
//
//  Created by David Arayan on 30/9/19.
//  Copyright © 2019 David Arayan. All rights reserved.
//

import Foundation
import UIKit

class GradientSlider: UISlider {
    
    // we save this so we can use color interpolation for the handler
    // see GradientExt for the extension functions
    var gradients:[GradientValue]? = nil
    
    required init? (coder: NSCoder) {
        super.init(coder: coder)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(gesture:)))
        self.addGestureRecognizer(panGesture)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGesture(gesture:)))
        
        self.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    /**
     * Handle smooth transition when the user moves the handle left to right
     */
    @objc func panGesture(gesture:UIPanGestureRecognizer) {
        // in here we will also grow/shrink the thumb image
        // using a timed animation sequence, one for up and
        // another for down
        
        // TO-DO
        
        // perform the smooth transition
        let currentPoint = gesture.location(in: self)
        let percentage = currentPoint.x / self.bounds.size.width;
        let delta = Float(percentage) * (self.maximumValue - self.minimumValue)
        let value = self.minimumValue + delta

        self.setValue(value, animated: true)
        
        updateThumbTintColor()
    }
    
    /**
     * Used for animating the thumb graphic up or down
     */
    @objc func tapGesture(gesture:UITapGestureRecognizer) {
        let slider: UISlider? = gesture.view as? UISlider
        
        if (slider?.isHighlighted)! {
            return
        }

        let pt: CGPoint = gesture.location(in: slider)
        let percentage = pt.x / (slider?.frame.size.width)!
        let delta = Float(percentage) * Float((slider?.maximumValue)! - (slider?.minimumValue)!)
        let value = (slider?.minimumValue)! + delta
        slider?.setValue(Float(value), animated: true)
        
        updateThumbTintColor()
    }
    
    /**
     * Sets the background gradient provided a list of gradients and a height value for the slider
     */
    public func setBackgroundGradient(gradients: [GradientValue], height:CGFloat) {
        self.gradients = gradients
        let gradientLayer = gradients.gradientLayer
        
        gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: height)

        UIGraphicsBeginImageContextWithOptions(gradientLayer.frame.size, false, 0.0)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let stretchedImage = image?.stretchableImage(withLeftCapWidth: 14, topCapHeight: 0)

        self.setMinimumTrackImage(stretchedImage, for: .normal)
        self.setMaximumTrackImage(stretchedImage, for: .normal)
    }
    
    /**
     * Resets back to the original value of 0.5
     */
    public func reset() {
        self.setValue(0.5, animated: true)
        
        updateThumbTintColor()
    }
    
    private func updateThumbTintColor() {
        // this performs a mapping between the slider values into a normalized
        // range suitable for mapping the gradient
        func map(x:Float, inMin:Float, inMax:Float, outMin:Float, outMax:Float) -> Float {
            return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
        }
        
        if (self.gradients != nil) {
            let mappedValue:Float = map(x:self.value,
                                        inMin:self.minimumValue,
                                        inMax:self.maximumValue,
                                        outMin:0.0,
                                        outMax:1.0)
            
            self.thumbTintColor = gradients?.colorAt(position: mappedValue)
        }
    }
}
