//
//  RangeSliderThumbLayer.swift
//  Boat Aware
//
//  Created by Dave Butz on 6/1/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit
import QuartzCore

class RangeSliderThumbLayer: CALayer {
    var highlighted = false
    var displayvalue = ""
    weak var rangeSlider: RangeSlider?
    
    
    
    override func drawInContext(ctx: CGContext) {
        if let slider = rangeSlider {
            let thumbFrame = bounds.insetBy(dx: 2.0, dy: 2.0)
            let cornerRadius = thumbFrame.height * slider.curvaceousness / 2.0
            let thumbPath = UIBezierPath(roundedRect: thumbFrame, cornerRadius: cornerRadius)
            
            // Fill - with a subtle shadow
            let shadowColor = UIColor.grayColor()
            CGContextSetShadowWithColor(ctx, CGSize(width: 0.0, height: 1.0), 1.0, shadowColor.CGColor)
            CGContextSetFillColorWithColor(ctx, slider.thumbTintColor.CGColor)
            CGContextAddPath(ctx, thumbPath.CGPath)
            CGContextFillPath(ctx)
            
            // Outline
            CGContextSetStrokeColorWithColor(ctx, shadowColor.CGColor)
            CGContextSetLineWidth(ctx, 0.5)
            CGContextAddPath(ctx, thumbPath.CGPath)
            CGContextStrokePath(ctx)
            let mytest = String.localizedStringWithFormat("%.1f", slider.theValue);
            if highlighted {
                CGContextSetFillColorWithColor(ctx, UIColor(white: 0.0, alpha: 0.1).CGColor)
                CGContextAddPath(ctx, thumbPath.CGPath)
                CGContextFillPath(ctx)
                
                // Tanslate and scale upside-down to compensate for Quartz's inverted coordinate system
                CGContextTranslateCTM(ctx, 0.0, thumbFrame.height);
                CGContextScaleCTM(ctx, 1.0, -1.0);
                
                let aFont = UIFont(name: "Optima-Bold", size: 9)
                // create a dictionary of attributes to be applied to the string
                let attr:CFDictionaryRef = [NSFontAttributeName:aFont!,NSForegroundColorAttributeName:UIColor.blackColor()]
                
                let text = CFAttributedStringCreate(nil, mytest, attr)
                // create the line of text
                let line = CTLineCreateWithAttributedString(text)
                CGContextSetLineWidth(ctx, 2)
                CGContextSetTextPosition(ctx, 5, 7)
                
                CTLineDraw(line, ctx)
                
            }
        }
    }
    
}