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
        let panGesture = UIPanGestureRecognizer(target: self, action:#selector(panGesture(gesture:)))
        self.addGestureRecognizer(panGesture)
    }
    
    /**
     * Handle smooth transition when the user moves the handle left to right
     */
    @objc func panGesture(gesture:UIPanGestureRecognizer) {
        let currentPoint = gesture.location(in: self)
        let percentage = currentPoint.x / self.bounds.size.width;
        let delta = Float(percentage) * (self.maximumValue - self.minimumValue)
        let value = self.minimumValue + delta

        self.setValue(value, animated: true)
        
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
        if (self.gradients != nil) {
            self.thumbTintColor = gradients?.colorAt(position: self.value)
        }
    }
}
