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
    public class func map(_ x:CGFloat, inMin:CGFloat, inMax:CGFloat, outMin:CGFloat, outMax:CGFloat) -> CGFloat {
        return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
    }
    
    public class func clamp(_ x:CGFloat, minValue:CGFloat, maxValue:CGFloat) -> CGFloat {
        return min(max(x, minValue), maxValue)
    }
    
    public class func lerp(a:CGFloat, b:CGFloat, t:CGFloat) -> CGFloat {
        return (a * (1.0 - t)) + (b * t);
    }
}
