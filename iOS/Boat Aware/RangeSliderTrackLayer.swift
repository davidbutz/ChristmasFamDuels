//
//  RangeSliderTrackLayer.swift
//  Boat Aware
//
//  Created by Dave Butz on 6/1/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit
import QuartzCore

class RangeSliderTrackLayer: CALayer {
    weak var rangeSlider: RangeSlider?
    
    override func drawInContext(ctx: CGContext) {
        if let slider = rangeSlider {
            
            // Clip
            let cornerRadius = bounds.height * slider.curvaceousness / 2.0
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
            CGContextAddPath(ctx, path.CGPath)
            
            // Fill the track
            CGContextSetFillColorWithColor(ctx, slider.trackTintColor.CGColor)
            CGContextAddPath(ctx, path.CGPath)
            CGContextFillPath(ctx)
            
            // Fill the highlighted range
            CGContextSetFillColorWithColor(ctx, slider.trackHighlightYellowColor.CGColor)
            let lowerValuePosition = CGFloat(slider.positionForValue(slider.firstValue))
            let upperValuePosition = CGFloat(slider.positionForValue(slider.secondValue))
            
            let rect = CGRect(x: lowerValuePosition, y: 0.0, width: upperValuePosition - lowerValuePosition, height: bounds.height)
            CGContextFillRect(ctx, rect)
            
            
            CGContextSetFillColorWithColor(ctx, slider.trackHighlightGreenColor.CGColor)
            let lowerValuePosition2 = CGFloat(slider.positionForValue(slider.secondValue))
            let upperValuePosition2 = CGFloat(slider.positionForValue(slider.thirdValue))
            
            let rect2 = CGRect(x: lowerValuePosition2, y: 0.0, width: upperValuePosition2 - lowerValuePosition2, height: bounds.height)
            CGContextFillRect(ctx, rect2)
            
            
            CGContextSetFillColorWithColor(ctx, slider.trackHighlightYellowColor.CGColor)
            let lowerValuePosition3 = CGFloat(slider.positionForValue(slider.thirdValue))
            let upperValuePosition3 = CGFloat(slider.positionForValue(slider.fourthValue))

            
            let rect3 = CGRect(x: lowerValuePosition3, y: 0.0, width: upperValuePosition3 - lowerValuePosition3, height: bounds.height)
            CGContextFillRect(ctx, rect3)
        }
    }
    
}
