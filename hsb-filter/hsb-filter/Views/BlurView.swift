//
//  BlurView.swift
//  hsb-filter
//
//  Created by David Arayan on 30/9/19.
//  Copyright © 2019 David Arayan. All rights reserved.
//

import Foundation
import UIKit

class BlurView: UIView {
    required init? (coder: NSCoder) {
        super.init(coder: coder)
        
        if (!UIAccessibility.isReduceTransparencyEnabled) {
            self.backgroundColor = .clear

            let blurEffect = UIBlurEffect(style: .systemMaterialDark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            
            blurEffectView.frame = self.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            self.insertSubview(blurEffectView, at: 0)
        }
        else {
            self.backgroundColor = UIColor(named: "Bottom Nav")!
        }
    }
}
