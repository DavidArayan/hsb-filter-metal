//
//  HSBFilter.swift
//  hsb-filter
//
//  Created by David Arayan on 1/10/19.
//  Copyright © 2019 David Arayan. All rights reserved.
//

import Foundation
import UIKit

/**
 * Reuse as many variables as possible to allow for real-time adjustment of HSB on an image
 * 
 * NOTE: This is discontinued because the performance was too slow for real-time HSB
 * adjustment. Left over for reference purposes only on how this would work for CPU/Slow based
 * implementations.
 */
class HSBFilter {
    
    // the target image being adjusted for HSB
    let targetImage:UIImage
    let ciImageRef:CIImage
    
    // color filter changes saturation and brightness of the image
    // hue filter changes the hue tone
    let colorFilter:CIFilter
    let hueFilter:CIFilter
    
    // the main drawing context
    let context:CIContext
    
    init(image:UIImage) {
        self.targetImage = image
        self.ciImageRef = CIImage(cgImage:image.cgImage!)
        
        self.colorFilter = CIFilter(name: "CIColorControls")!
        self.hueFilter = CIFilter(name: "CIHueAdjust")!
        
        self.context = CIContext(options: nil)
    }
    
    /**
     * Returns the original unmodified image
     */
    var originalImage:UIImage {
        get {
            return targetImage
        }
    }
    
    /**
     * Perform the HSB adjustment using Apple provided Filters
     */
    public func adjustHSB(hue:CGFloat, saturation:CGFloat, brightness:CGFloat) -> UIImage {
        hueFilter.setValue(self.ciImageRef, forKey: "inputImage")
        hueFilter.setValue(hue as NSNumber, forKey: "inputAngle")
        
        let hueOutput = hueFilter.outputImage!
        
        colorFilter.setValue(hueOutput, forKey: kCIInputImageKey)
        colorFilter.setValue(saturation, forKey: kCIInputSaturationKey)
        colorFilter.setValue(brightness, forKey: kCIInputBrightnessKey)
        
        let colorOutput = colorFilter.outputImage!
        
        guard let adjustedImage = self.context.createCGImage(colorOutput, from: colorOutput.extent) else {
            return self.originalImage
        }
        
        return UIImage(cgImage: adjustedImage, scale: UIScreen.main.scale, orientation: self.originalImage.imageOrientation)
    }
}
