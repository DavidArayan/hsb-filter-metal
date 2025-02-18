//
//  ViewController.swift
//  hsb-filter
//
//  Created by David Arayan on 29/9/19.
//  Copyright © 2019 David Arayan. All rights reserved.
//

import UIKit
import MetalKit

/**
 * This Controller also handles the simple Metal rendering for real-time
 * adjustment of HSB values.
 * NOTE: Ideally a separate Renderer class would be created, left over for
 * simplicity
 */
class ViewController: UIViewController, MTKViewDelegate {
    
    enum HSBRenderMode {
        case enabled
        case disabled
    }
    
    @IBOutlet weak var hueSlider: GradientSlider!
    @IBOutlet weak var saturationSlider: GradientSlider!
    @IBOutlet weak var brightnessSlider: GradientSlider!
    
    // Metal resources
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var sourceTexture: MTLTexture!
    
    // Metal View Instance
    @IBOutlet weak var metalView: MTKView!
    
    // Core Image resources
    var context: CIContext!
    let saturationFilter = CIFilter(name: "CIColorControls")!
    let brightnessFilter = CIFilter(name: "CIColorControls")!
    let hueFilter = CIFilter(name: "CIHueAdjust")!
    let colorSpace = CGColorSpace.init(name: CGColorSpace.extendedLinearDisplayP3)!
    
    // render status
    var renderStatus:HSBRenderMode = .enabled
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        device = MTLCreateSystemDefaultDevice()
        commandQueue = device.makeCommandQueue()!
        
        metalView.delegate = self
        metalView.device = device
        metalView.framebufferOnly = false
        
        context = CIContext(mtlDevice: device)
        
        // load texture as an MTL Texture
        let loader = MTKTextureLoader(device: device)
        let url = Bundle.main.url(forResource: "Neon-Source", withExtension: "png")!
        
        // simulator shows this upside down, real devices show real way up
        // simulator bugged or device bugged.. or both bugged? or none bugged?
        #if targetEnvironment(simulator)
        sourceTexture = try! loader.newTexture(URL: url,
                                               options: [:])
        #else
        sourceTexture = try! loader.newTexture(URL: url,
                                               options: [MTKTextureLoader.Option.origin: MTKTextureLoader.Origin.flippedVertically])
        #endif
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
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
            GradientValue(color: UIColor(named: "Hue 56")!, position: 0.56),
            GradientValue(color: UIColor(named: "Hue 66")!, position: 0.66),
            GradientValue(color: UIColor(named: "Hue 73")!, position: 0.73),
            GradientValue(color: UIColor(named: "Hue 87")!, position: 0.87),
            GradientValue(color: UIColor(named: "Hue 100")!, position: 1.0)
        ]
         
        let satGradients:[GradientValue] = [
            GradientValue(color: UIColor(named: "Saturation 0")!, position: 0.0),
            GradientValue(color: UIColor(named: "Saturation 100")!, position: 1.0)
        ]
         
        let briGradients:[GradientValue] = [
            GradientValue(color: UIColor(named: "Brightness 0")!, position: 0.0),
            GradientValue(color: UIColor(named: "Brightness 100")!, position: 1.0)
        ]
         
        hueSlider.setBackgroundGradient(gradients: hueGradients)
        saturationSlider.setBackgroundGradient(gradients: satGradients)
        brightnessSlider.setBackgroundGradient(gradients: briGradients)
    }
    
    // callbacks from METAL
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    /**
     * Perform real-time rendering into our Metal View
     */
    func draw(in view: MTKView) {
        if let currentDrawable = view.currentDrawable {
            let commandBuffer = commandQueue.makeCommandBuffer()!
            
            let inputImage = CIImage(mtlTexture: sourceTexture)!
            
            // process brightness filter
            brightnessFilter.setValue(inputImage, forKey: kCIInputImageKey)
            brightnessFilter.setValue(brightnessSlider.value as NSNumber, forKey: kCIInputBrightnessKey)

            let brightnessOutput = brightnessFilter.outputImage!

            // process saturation filter
            saturationFilter.setValue(brightnessOutput, forKey: kCIInputImageKey)
            saturationFilter.setValue(saturationSlider.value as NSNumber, forKey: kCIInputSaturationKey)

            let saturationOutput = saturationFilter.outputImage!

            // process the hue filter
            hueFilter.setValue(saturationOutput, forKey: kCIInputImageKey)
            hueFilter.setValue(hueSlider.value as NSNumber, forKey: "inputAngle")

            let hueOutput = hueFilter.outputImage!

            context.render(hueOutput,
                          to: currentDrawable.texture,
                          commandBuffer: commandBuffer,
                          bounds: inputImage.extent,
                          colorSpace: colorSpace)
            
            commandBuffer.present(currentDrawable)
            commandBuffer.commit()
        }
    }
    
    /**
     * Called by the "reset" button
     */
    @IBAction func resetHSB(_ sender: UIButton) {
        resetHSB()
    }
    
    @IBAction func previewTouchDown() {
        disableHSB()
    }
    
    // touch up inside/outside can probably be combined into
    // a single action from the UI
    @IBAction func previewTouchUpInside() {
        enableHSB()
    }
    
    @IBAction func previewTouchUpOutside() {
        enableHSB()
    }
    
    // these are used by the preview functionality only
    var tempHueValue:Float = 0.0
    var tempSaturationValue:Float = 0.0
    var tempBrightnessValue:Float = 0.0
    
    fileprivate func resetHSB() {
        self.hueSlider.setAnimatedValue(0.0)
        self.saturationSlider.setAnimatedValue(1.0)
        self.brightnessSlider.setAnimatedValue(0.0)
    }
    
    fileprivate func enableHSB() {
        if (renderStatus == .disabled) {
            renderStatus = .enabled
            
            hueSlider.setAnimatedValue(tempHueValue)
            saturationSlider.setAnimatedValue(tempSaturationValue)
            brightnessSlider.setAnimatedValue(tempBrightnessValue)
        }
    }
    
    fileprivate func disableHSB() {
        // in here we will do a fancy thing where we temporarily save the
        // previous slider values, and reset them back when rendering is
        // re-enabled
        if (renderStatus == .enabled) {
            renderStatus = .disabled
            
            tempHueValue = hueSlider.realValue
            tempSaturationValue = saturationSlider.realValue
            tempBrightnessValue = brightnessSlider.realValue
            
            hueSlider.setAnimatedValue(0.0)
            saturationSlider.setAnimatedValue(1.0)
            brightnessSlider.setAnimatedValue(0.0)
        }
    }
}

