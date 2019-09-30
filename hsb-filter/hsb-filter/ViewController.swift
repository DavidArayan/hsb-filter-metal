//
//  ViewController.swift
//  hsb-filter
//
//  Created by David Arayan on 29/9/19.
//  Copyright © 2019 David Arayan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var hueSlider: UISlider!
    @IBOutlet weak var saturationSlider: UISlider!
    @IBOutlet weak var brightnessSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        
        // NOTE: This is done for the purposes of simplicity. In a real implementation
        // this would likely be its own construct/class to ensure positions are always mapped
        // between 0.0 and 1.0. This is to protect other developers and our future selves from
        // simple logic errors.
        // See GradientExt that contains extension methods to deal with an array of GradientValue
        let hueGradients:[GradientValue] = [
            GradientValue(color: UIColor(named: "Hue 0")!, position: 0.0),
            GradientValue(color: UIColor(named: "Hue 13")!, position: 0.13),
            GradientValue(color: UIColor(named: "Hue 31")!, position: 0.31),
            GradientValue(color: UIColor(named: "Hue 45")!, position: 0.45),
            GradientValue(color: UIColor(named: "Hue 50")!, position: 0.50),
            GradientValue(color: UIColor(named: "Hue 56")!, position: 0.56),
            GradientValue(color: UIColor(named: "Hue 66")!, position: 0.66),
            GradientValue(color: UIColor(named: "Hue 73")!, position: 0.73),
            GradientValue(color: UIColor(named: "Hue 87")!, position: 0.87),
            GradientValue(color: UIColor(named: "Hue 100")!, position: 1.0)
        ]
         
        let satGradients:[GradientValue] = [
            GradientValue(color: UIColor(named: "Saturation 0")!, position: 0.0),
            GradientValue(color: UIColor(named: "Saturation 50")!, position: 0.50),
            GradientValue(color: UIColor(named: "Saturation 100")!, position: 1.0)
        ]
         
        let briGradients:[GradientValue] = [
            GradientValue(color: UIColor(named: "Brightness 0")!, position: 0.0),
            GradientValue(color: UIColor(named: "Brightness 50")!, position: 0.50),
            GradientValue(color: UIColor(named: "Brightness 100")!, position: 1.0)
        ]
         
        hueSlider.setBackgroundGradient(gradients: hueGradients, height: 2.0)
        saturationSlider.setBackgroundGradient(gradients: satGradients, height: 2.0)
        brightnessSlider.setBackgroundGradient(gradients: briGradients, height: 2.0)
    }
}

