//
//  SegueFromLeft.swift
//  Boat Aware
//
//  Created by Adam Douglass on 3/11/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit
import QuartzCore

class SegueFromLeft: UIStoryboardSegue {
    
    override func perform()
    {
        let src = self.sourceViewController
        let dst = self.destinationViewController
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        src.view.transform = CGAffineTransformMakeTranslation(0, 0)
        dst.view.transform = CGAffineTransformMakeTranslation(-src.view.frame.size.width, 0)
        
        UIView.animateWithDuration(0.25,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: {
                dst.view.transform = CGAffineTransformMakeTranslation(0, 0)
                src.view.transform = CGAffineTransformMakeTranslation(src.view.frame.size.width, 0)
            },
            completion: { finished in
                src.presentViewController(dst, animated: false, completion: nil)
            }
        )
    }
    
}