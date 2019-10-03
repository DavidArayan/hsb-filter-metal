//
//  Util.swift
//  hsb-filter
//
//  Created by David Arayan on 3/10/19.
//  Copyright © 2019 David Arayan. All rights reserved.
//

import Foundation
import UIKit

class Util {
    
    /**
     * Perform linear mapping between two different coordinates
     */
    public class func map(_ x:CGFloat, inMin:CGFloat, inMax:CGFloat, outMin:CGFloat, outMax:CGFloat) -> CGFloat {
        return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
    }
    
    /**
     * Ensure value is not greater or less than min and max
     */
    public class func clamp(_ x:CGFloat, minValue:CGFloat, maxValue:CGFloat) -> CGFloat {
        return min(max(x, minValue), maxValue)
    }
    
    /**
     * Linear Interpolation
     */
    public class func lerp(_ a:CGFloat, b:CGFloat, t:CGFloat) -> CGFloat {
        return (a * (1.0 - t)) + (b * t);
    }
    
    /**
     * Cubic SCurve
     */
    public class func curve(_ a:CGFloat, b:CGFloat, t:CGFloat) -> CGFloat {
        let cubicTime:CGFloat = t * t * (3.0 - 2.0 * t)
        
        return Util.lerp(a, b: b, t: cubicTime)
    }
}
