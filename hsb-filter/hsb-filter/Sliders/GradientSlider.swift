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
    
    /**
     * Simple cases to handle the thumb grow/shrink animation
     */
    enum ThumbState {
        case touchedDown
        case touchedUp
        case idle
    }
    
    /**
     * Simple cases to handle the track translation
     */
    enum TrackState {
        case animating
        case idle
    }
    
    // constant values for the thumb min and max size
    let trackHeight:CGFloat = 3
    let thumbMinSize:CGFloat = 10.0
    let thumbMaxSize:CGFloat = 31.0
    
    // this will change and animate according to user actions
    var currentThumbSize:CGFloat = 10.0
    
    // these are the animations responsible for growing/shrinking the
    // thumb graphic when the user touches down/up
    let animationFactor:CGFloat = 2.5
    var timerUpdate:Timer? = nil
    var animationState:ThumbState = .idle
    
    // this is the track translation animation factors. Using normal animation
    // frameworks did not work well, so implemented my own.
    let trackAnimationTimeFactor:CGFloat = 0.08
    var trackAnimationTime:CGFloat = 0.0
    var startValue:CGFloat = 0.0
    var targetValue:CGFloat = 0.0
    var trackAnimationState:TrackState = .idle
    
    // we save this so we can use color interpolation for the handler
    // see GradientExt for the extension functions
    var gradients:[GradientValue]? = nil
    
    // This is to ensure that the proper final non-animated value
    // is returned, so we don't mix up animations with slider final
    // values in the main application
    var realValue:Float {
        get {
            if (trackAnimationState == .idle) {
                return self.value
            }
            
            return Float(self.targetValue)
        }
    }
    
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
        
        // setup the grow animation when the user touches down
        self.timerUpdate = Timer.scheduledTimer(timeInterval: 0.01,
                                                target: self,
                                                selector: #selector(update),
                                                userInfo: nil,
                                                repeats: true)
    }
    
    /**
     * This is called continuously by a timer every 33ms
     */
    @objc func update() {
        switch animationState {
        case .touchedDown:
            // we grow our current thumb size to the maximum size
            let newSize:CGFloat = currentThumbSize + animationFactor
            
            let clampedSize:CGFloat = Util.clamp(newSize,
                                                 minValue: thumbMinSize,
                                                 maxValue: thumbMaxSize)
            
            // we have reached the upper limit, cut off from here
            if (clampedSize < newSize) {
                animationState = .idle
                currentThumbSize = thumbMaxSize
            }
            else {
                currentThumbSize = clampedSize
            }
        case .touchedUp:
            // we shrink our current thumb size to the minimum size
            let newSize:CGFloat = currentThumbSize - animationFactor
            
            let clampedSize:CGFloat = Util.clamp(newSize,
                                                 minValue: thumbMinSize,
                                                 maxValue: thumbMaxSize)
            
            // we have reached the lower limit, cut off from here
            if (clampedSize > newSize) {
                animationState = .idle
                currentThumbSize = thumbMinSize
            }
            else {
                currentThumbSize = clampedSize
            }
        case .idle:
            break
        }
        
        switch trackAnimationState {
        case .animating:
            let currentValue:CGFloat = Util.curve(self.startValue,
                                                 b: self.targetValue,
                                                 t: self.trackAnimationTime)
            
            let newTrackTime:CGFloat = self.trackAnimationTime + self.trackAnimationTimeFactor
            let clampedTrackTime:CGFloat = Util.clamp(newTrackTime, minValue: 0.0, maxValue: 1.0)
            
            // see if we should be terminating the animation or proceeding as normal
            if (newTrackTime > clampedTrackTime) {
                self.setValue(Float(self.targetValue), animated: true)
                trackAnimationState = .idle
            }
            else {
                trackAnimationTime = clampedTrackTime
                self.setValue(Float(currentValue), animated: true)
            }
        case .idle:
            break
        }
        
        // update the look/feel
        if (animationState != .idle || trackAnimationState != .idle) {
            updateThumbTintColor()
        }
    }
    
    @objc func touchDown() {
        animationState = .touchedDown
    }
    
    @objc func touchUp() {
        animationState = .touchedUp
    }
    
    /**
     * Handle smooth transition when the user moves the handle left to right
     */
    @objc func panGesture(gesture:UIPanGestureRecognizer) {
        if (gesture.state == .changed && trackAnimationState == .idle) {
            // perform the smooth transition
            let currentPoint = gesture.location(in: self)
            let percentage = currentPoint.x / self.bounds.size.width;
            let delta = Float(percentage) * (self.maximumValue - self.minimumValue)
            let value = self.minimumValue + delta

            self.setValue(value, animated: true)
            
            updateThumbTintColor()
        }
        
        if (gesture.state == .began) {
            touchDown()
        }
        else if (gesture.state == .ended) {
            touchUp()
        }
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
        
        setAnimatedValue(Float(value))
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
        
        updateThumbTintColor()
    }
    
    /**
     * Interpolate the track value over time
     */
    public func setAnimatedValue(_ value:Float) {
        self.targetValue = CGFloat(value)
        self.startValue = CGFloat(self.value)
        self.trackAnimationTime = 0.0
        self.trackAnimationState = .animating
    }
    
    /**
     * Called internally to change the tint color of the current thumb according
     * to the color of the gradient and current position
     */
    private func updateThumbTintColor() {
        if (self.gradients != nil) {
            let mappedValue:CGFloat = Util.map(CGFloat(self.value),
                                             inMin:CGFloat(self.minimumValue),
                                             inMax:CGFloat(self.maximumValue),
                                             outMin:0.0,
                                             outMax:1.0)
            
            let thumbColor:UIColor = gradients!.colorAt(position: Float(mappedValue))
            
            // if this is not set, things go crazy... i don't know why
            self.thumbTintColor = thumbColor
            
            // set the custom size/color of the thumb
            setThumbColor(color:thumbColor, withRadius:currentThumbSize)
        }
    }
    
    /**
     * This handles cases to ensure the small thumb and large thumbs are mapped
     * correctly onto the slider track
     */
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let currentBounds:CGRect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        
        let minTrack:CGFloat = 0.0
        let maxTrack:CGFloat = bounds.size.width - bounds.size.height
        
        // map the current thumb size so the rendering appears correct on both ends
        // of the track regardless of the current thumb size
        let trackFactor:CGFloat = Util.map(currentThumbSize,
                                         inMin:thumbMinSize,
                                         inMax:thumbMaxSize,
                                         outMin:thumbMinSize,
                                         outMax:0.0)
        
        // this is the actual size of the thumb
        // based on the size of the current thumb
        // let minNewTrack:CGFloat = minTrack - trackFactor
        // let maxNewTrack:CGFloat = maxTrack + trackFactor
        
        // NOTE: Uncomment to have the track go all the way instead of locking
        // inside the track. With the current implementation it felt quite odd during use
        let minNewTrack:CGFloat = minTrack - trackFactor - (currentThumbSize / 2.0)
        let maxNewTrack:CGFloat = maxTrack + trackFactor + (currentThumbSize / 2.0)
        
        let currentValue:CGFloat = currentBounds.origin.x
        
        // grab the new mapped value to be rendered in a new position, calculated
        // from the old maximum position and new position based on thumb size
        let mappedValue:CGFloat = Util.map(currentValue,
                                         inMin:minTrack,
                                         inMax:maxTrack,
                                         outMin:minNewTrack,
                                         outMax:maxNewTrack)
        
        let modifiedBounds:CGRect = CGRect(x: mappedValue,
                                           y: currentBounds.origin.y,
                                           width: currentBounds.size.width,
                                           height: currentBounds.size.height)
        
        return modifiedBounds
    }
    
    /**
     * Sets the thumb color and radius
     */
    func setThumbColor(color: UIColor, withRadius: CGFloat) {
        let imageSize:CGSize = CGSize(width: thumbMaxSize, height: thumbMaxSize)
        let circleSize:CGSize = CGSize(width: withRadius, height: withRadius)
        
        let circleImage:UIImage = makeCircleWith(size: imageSize, circleSize: circleSize, backgroundColor: color)
        
        self.setThumbImage(circleImage, for: .normal)
        self.setThumbImage(circleImage, for: .highlighted)
    }
    
    /**
     * rather than redrawing the circles, we could pre-generate them and animate them
     * using an array. Would still need to change their color though
     */
    fileprivate func makeCircleWith(size: CGSize, circleSize: CGSize, backgroundColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(backgroundColor.cgColor)
        context.setStrokeColor(UIColor.clear.cgColor)
        
        let originPt:CGFloat = Util.map(circleSize.width,
                                        inMin: thumbMinSize,
                                        inMax: thumbMaxSize,
                                        outMin: thumbMinSize,
                                        outMax: 0.0)
        
        let origin:CGPoint = CGPoint(x: originPt, y: originPt)
        
        let bounds = CGRect(origin: origin, size: circleSize)
        context.addEllipse(in: bounds)
        context.drawPath(using: .fill)
        
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
}
