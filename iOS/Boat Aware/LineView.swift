//
//  LineView.swift
//  Boat Aware
//
//  Created by Adam Douglass on 6/28/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit

class LineView : UIView {
    var width : CGFloat = 2.0;
    var startPosition : CGPoint?
    var endPosition : CGPoint?
    
    init(frame: CGRect, lineWidth: CGFloat, leftMargin: CGFloat, rightMargin: CGFloat) {
        super.init(frame: frame);
        self.opaque = false;
        let yPos = width / 2.0;
        self.width = lineWidth;
        self.startPosition = CGPoint(x: leftMargin, y: yPos);
        self.endPosition = CGPoint(x: frame.width - rightMargin, y: yPos);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect);
        if (startPosition != nil && endPosition != nil) {
            let context = UIGraphicsGetCurrentContext();
            CGContextSetStrokeColorWithColor(context, UIColor.darkGrayColor().CGColor);
            
            CGContextSetLineWidth(context, self.width);
            CGContextMoveToPoint(context, (startPosition?.x)!, (startPosition?.y)!);
            CGContextAddLineToPoint(context, (endPosition?.x)!, (endPosition?.y)!);
            CGContextStrokePath(context);
        }
    }
}
