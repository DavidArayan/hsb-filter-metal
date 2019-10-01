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
    
    // constant values for the thumb min and max size
    let trackHeight:CGFloat = 3
    let thumbMinSize:CGFloat = 5.0
    let thumbMaxSize:CGFloat = 30.0
    
    // we save this so we can use color interpolation for the handler
    // see GradientExt for the extension functions
    var gradients:[GradientValue]? = nil
    
    required init? (coder: NSCoder) {
        super.init(coder: coder)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(gesture:)))
        panGesture.cancelsTouchesInView = false
        self.addGestureRecognizer(panGesture)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGesture(gesture:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        
        self.addGestureRecognizer(tapGestureRecognizer)
        
        // add the touch down/up actions so we can animate the size of the thumb
        self.addTarget(self, action: #selector(touchDown), for:UIControl.Event.touchDown)
        self.addTarget(self, action: #selector(touchUp), for:UIControl.Event.touchUpInside)
        self.addTarget(self, action: #selector(touchUp), for:UIControl.Event.touchUpOutside)
    }
    
    @objc func touchDown() {
        
    }
    
    @objc func touchUp() {
        
    }
    
    /**
     * Handle smooth transition when the user moves the handle left to right
     */
    @objc func panGesture(gesture:UIPanGestureRecognizer) {
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
    public func setBackgroundGradient(gradients: [GradientValue]) {
        self.gradients = gradients
        let gradientLayer = gradients.gradientLayer
        
        gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: trackHeight)

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
    
    /**
     * Called internally to change the tint color of the current thumb according
     * to the color of the gradient and current position
     */
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
            
            let thumbColor:UIColor = gradients!.colorAt(position: mappedValue)
            
            // if this is not set, things go crazy... i don't know why
            self.thumbTintColor = thumbColor
            
            // set the custom size/color of the thumb
            setSliderThumbTintColor(color:thumbColor)
        }
    }
    
    func setSliderThumbTintColor(color: UIColor) {
        let circleImage:UIImage = makeCircleWith(size: CGSize(width: thumbMaxSize, height: thumbMaxSize),
                       backgroundColor: color)
        
        self.setThumbImage(circleImage, for: .normal)
        self.setThumbImage(circleImage, for: .highlighted)
    }
    
    /**
     * rather than redrawing the circles, we could pre-generate them and animate them
     * using an array. Would still need to change their color though
     */
    fileprivate func makeCircleWith(size: CGSize, backgroundColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(backgroundColor.cgColor)
        context?.setStrokeColor(UIColor.clear.cgColor)
        
        let bounds = CGRect(origin: .zero, size: size)
        context?.addEllipse(in: bounds)
        context?.drawPath(using: .fill)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
