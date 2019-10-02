//
//  UIButtonExtension.swift
//  hsb-filter
//
//  Created by David Arayan on 2/10/19.
//  Copyright © 2019 David Arayan. All rights reserved.
//

import Foundation
import UIKit

/**
 * Lets me set the corner radius of UIButton using the XCode UI Designer
 */
@IBDesignable extension UIButton {

    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
}
