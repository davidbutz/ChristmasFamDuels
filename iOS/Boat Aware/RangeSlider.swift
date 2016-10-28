//
//  RangeSlider.swift
//  Boat Aware
//
//  Created by Dave Butz on 5/27/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit
import QuartzCore

class RangeSlider: UIControl {
    
    //var minimumValue = 0.0
    //var maximumValue = 120.0
    
    //var firstValue = 20.0
    //var secondValue = 40.0
    //var thirdValue = 80.0
    //var fourthValue = 100.0
    var theValue = 0.0
    
    var minimumValue: Double = 0.0 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var maximumValue: Double = 120.0 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var firstValue: Double = 20.0 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var secondValue: Double = 40.0 {
        didSet {
            updateLayerFrames()
        }
    }
 
    var thirdValue: Double = 80.0 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var fourthValue: Double = 100.0 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var trackTintColor: UIColor = UIColor.redColor(){
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    var trackHighlightTintColor: UIColor = UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    var thumbTintColor: UIColor = UIColor.whiteColor() {
        didSet {
            firstThumbLayer.setNeedsDisplay()
            secondThumbLayer.setNeedsDisplay()
            thirdThumbLayer.setNeedsDisplay()
            fourthThumbLayer.setNeedsDisplay()
        }
    }
    
    var curvaceousness: CGFloat = 1.0 {
        didSet {
            trackLayer.setNeedsDisplay()
            firstThumbLayer.setNeedsDisplay()
            secondThumbLayer.setNeedsDisplay()
            thirdThumbLayer.setNeedsDisplay()
            fourthThumbLayer.setNeedsDisplay()
        }
    }
    
    
    
    
    var previousLocation = CGPoint()
    
    // 5 possible values.
    let trackLayer = RangeSliderTrackLayer()
    let firstThumbLayer = RangeSliderThumbLayer()
    let secondThumbLayer = RangeSliderThumbLayer()
    let thirdThumbLayer = RangeSliderThumbLayer()
    let fourthThumbLayer = RangeSliderThumbLayer()
    
    //var trackTintColor = UIColor.redColor()//UIColor(white: 0.9, alpha: 1.0)
    //TODO: Makes these also 'settable'
    var trackHighlightYellowColor = UIColor.yellowColor()
    var trackHighlightGreenColor = UIColor(red: 0.0, green: 0.94, blue: 0.45, alpha: 1.0)
    //var trackHighlightTintColor = UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0)
    //var thumbTintColor = UIColor.whiteColor()
    
    //var curvaceousness : CGFloat = 2.0
    
    
    var thumbWidth: CGFloat {
        return CGFloat(bounds.height)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        trackLayer.rangeSlider = self
        trackLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(trackLayer)
        
        firstThumbLayer.rangeSlider = self
        firstThumbLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(firstThumbLayer)
        
        secondThumbLayer.rangeSlider = self
        secondThumbLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(secondThumbLayer)
        
        thirdThumbLayer.rangeSlider = self
        thirdThumbLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(thirdThumbLayer)
        
        fourthThumbLayer.rangeSlider = self
        fourthThumbLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(fourthThumbLayer)
        /*
          trackLayer.backgroundColor = UIColor.blueColor().CGColor
        layer.addSublayer(trackLayer)
        
        firstThumbLayer.backgroundColor = UIColor.greenColor().CGColor
        layer.addSublayer(firstThumbLayer)
        
        secondThumbLayer.backgroundColor = UIColor.greenColor().CGColor
        layer.addSublayer(secondThumbLayer)
        
        thirdThumbLayer.backgroundColor = UIColor.greenColor().CGColor
        layer.addSublayer(thirdThumbLayer)
        
        fourthThumbLayer.backgroundColor = UIColor.greenColor().CGColor
        layer.addSublayer(fourthThumbLayer)
        
        updateLayerFrames()
         */
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
        //firstThumbLayer.rangeSlider = self
        //secondThumbLayer.rangeSlider = self
        //thirdThumbLayer.rangeSlider = self
        //fourthThumbLayer.rangeSlider = self
    }
 
    func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        trackLayer.frame = bounds.insetBy(dx: 0.0, dy: bounds.height / 3)
        trackLayer.setNeedsDisplay()
        
        let firstThumbCenter = CGFloat(positionForValue(firstValue))
        firstThumbLayer.frame = CGRect(x: firstThumbCenter - thumbWidth / 2.0, y: 0.0,
                                       width: thumbWidth, height: thumbWidth)
        firstThumbLayer.setNeedsDisplay()
        
        let secondThumbCenter = CGFloat(positionForValue(secondValue))
        secondThumbLayer.frame = CGRect(x: secondThumbCenter - thumbWidth / 2.0, y: 0.0,
                                       width: thumbWidth, height: thumbWidth)
        secondThumbLayer.setNeedsDisplay()
        
        let thirdThumbCenter = CGFloat(positionForValue(thirdValue))
        thirdThumbLayer.frame = CGRect(x: thirdThumbCenter - thumbWidth / 2.0, y: 0.0,
                                        width: thumbWidth, height: thumbWidth)
        thirdThumbLayer.setNeedsDisplay()
        
        
        let fourthThumbCenter = CGFloat(positionForValue(fourthValue))
        fourthThumbLayer.frame = CGRect(x: fourthThumbCenter - thumbWidth / 2.0, y: 0.0,
                                        width: thumbWidth, height: thumbWidth)
        fourthThumbLayer.setNeedsDisplay()
        
        CATransaction.commit()
    }
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        previousLocation = touch.locationInView(self)
        
        // Hit test the thumb layers
        if firstThumbLayer.frame.contains(previousLocation) {
            firstThumbLayer.highlighted = true
        } else if secondThumbLayer.frame.contains(previousLocation) {
            secondThumbLayer.highlighted = true
        } else if thirdThumbLayer.frame.contains(previousLocation) {
            thirdThumbLayer.highlighted = true
        } else if fourthThumbLayer.frame.contains(previousLocation) {
            fourthThumbLayer.highlighted = true
        }
        
        return firstThumbLayer.highlighted || secondThumbLayer.highlighted || thirdThumbLayer.highlighted || fourthThumbLayer.highlighted

    }
    
    
    func boundValue(value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let location = touch.locationInView(self)
        
        // 1. Determine by how much the user has dragged
        let deltaLocation = Double(location.x - previousLocation.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.width - thumbWidth)
        
        previousLocation = location
        
        // 2. Update the values
        if firstThumbLayer.highlighted {
            firstValue += deltaValue
            firstValue = boundValue(firstValue, toLowerValue: minimumValue, upperValue: secondValue)
            theValue = firstValue
        } else if secondThumbLayer.highlighted {
            secondValue += deltaValue
            secondValue = boundValue(secondValue, toLowerValue: firstValue, upperValue: thirdValue)
            theValue = secondValue
        } else if thirdThumbLayer.highlighted {
            thirdValue += deltaValue
            thirdValue = boundValue(thirdValue, toLowerValue: secondValue, upperValue: fourthValue)
            theValue = thirdValue
        } else if fourthThumbLayer.highlighted {
            fourthValue += deltaValue
            fourthValue = boundValue(fourthValue, toLowerValue: thirdValue, upperValue: maximumValue)
            theValue = fourthValue
        }
        
        // 3. Update the UI
        //CATransaction.begin()
        //CATransaction.setDisableActions(true)
        
        //updateLayerFrames()
        
        //CATransaction.commit()
        
        sendActionsForControlEvents(.ValueChanged)
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        firstThumbLayer.highlighted = false
        secondThumbLayer.highlighted = false
        thirdThumbLayer.highlighted = false
        fourthThumbLayer.highlighted = false
    }
    
    func positionForValue(value: Double) -> Double {
        return Double(bounds.width - thumbWidth) * (value - minimumValue) /
            (maximumValue - minimumValue) + Double(thumbWidth / 2.0)
    }
    
    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
}
