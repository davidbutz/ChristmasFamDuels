//
//  ThresholdVisualView.swift
//  Boat Aware
//
//  Created by Adam Douglass on 6/24/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//
import UIKit

@IBDesignable

class ThresholdVisualView : UIView {
    
    var contentView : UIView?

    @IBOutlet weak var criticalLow : UIView!;
    @IBOutlet weak var warnLow : UIView!;
    @IBOutlet weak var normal : UIView!;
    @IBOutlet weak var warnHigh : UIView!;
    @IBOutlet weak var criticalHigh : UIView!;
    @IBOutlet weak var indicator : UIImageView!;
    
    // Constraints for Auto Layout adjustments
    @IBOutlet private weak var criticalLowWidthLayoutConstraint: NSLayoutConstraint!
    @IBOutlet private weak var warnLowWidthLayoutConstraint: NSLayoutConstraint!
    @IBOutlet private weak var normalWidthLayoutConstraint: NSLayoutConstraint!
    @IBOutlet private weak var warnHighWidthLayoutConstraint: NSLayoutConstraint!
    @IBOutlet private weak var criticalHighWidthLayoutConstraint: NSLayoutConstraint!
    @IBOutlet private weak var indicatorLeadingLayoutConstraint: NSLayoutConstraint!
    
    private var min : Double?;
    private var max : Double?;
    private var range : Double?;
    private var currentValue : Double?;
    
    var value : NSNumber? {
        didSet {
            if let value = value {
                currentValue = value.doubleValue;
            }
            else {
                currentValue = nil;
            }
            layoutIndicator();
        }
    }
    
    var rule : DeviceCapabilityRule? {
        didSet {
            if let rule = rule {
                var total = 0.0;
                // Loop through to get a total range, then adjust the layout constraints to match their %
                for rangeItem in rule.rule_range {
                    if (min == nil || rangeItem.gte.doubleValue < min) {
                        min = rangeItem.gte.doubleValue;
                    }
                    if (max == nil || rangeItem.lt.doubleValue > max) {
                        max = rangeItem.lt.doubleValue;
                    }
                    total += abs(rangeItem.gte.doubleValue - rangeItem.lt.doubleValue);
                }
                range = total;
                
                for rangeItem in rule.rule_range {
                    print("RANGE \(rangeItem.state_id):  \(rangeItem.gte) - \(rangeItem.lt)");
                    let span = abs(rangeItem.gte.doubleValue - rangeItem.lt.doubleValue);
                    var layoutConstraint : NSLayoutConstraint?;
                    switch (rangeItem.state_id.intValue) {
                        case 1:
                            layoutConstraint = criticalLowWidthLayoutConstraint;
                            break;
                        case 2:
                            layoutConstraint = warnLowWidthLayoutConstraint;
                            break;
                        case 3:
                            layoutConstraint = normalWidthLayoutConstraint;
                            break;
                        case 4:
                            layoutConstraint = warnHighWidthLayoutConstraint;
                            break;
                        case 5:
                            layoutConstraint = criticalHighWidthLayoutConstraint;
                            break;
                        default:
                            break;
                    }
                    
                    if let constraint = layoutConstraint {
                        let multiplier = span / total;
//                        print("pos = \(multiplier)");
                        let newConstraint = NSLayoutConstraint(
                            item: constraint.firstItem,
                            attribute: constraint.firstAttribute,
                            relatedBy: constraint.relation,
                            toItem: constraint.secondItem,
                            attribute: constraint.secondAttribute,
                            multiplier: CGFloat(multiplier),
                            constant: constraint.constant)
                        
                        newConstraint.priority = constraint.priority
                        
                        NSLayoutConstraint.deactivateConstraints([constraint])
                        NSLayoutConstraint.activateConstraints([newConstraint])
                        layoutConstraint = newConstraint;
                        self.setNeedsLayout();
                    }
                }
                layoutIndicator();
            }
        }
    }
    
    // Adjust the layout constraint on our Indicator to place it properly on the threshold
    private func layoutIndicator() {
        if (currentValue != nil && range != nil) {
            if (range! > 0.0) {
                let multiplier = (currentValue! - min!) / range!;
                print("indicator: \(currentValue) / \(range)")
                
                if (multiplier > 0) {
                    let newConstraint = NSLayoutConstraint(
                        item: indicatorLeadingLayoutConstraint.firstItem,
                        attribute: indicatorLeadingLayoutConstraint.firstAttribute,
                        relatedBy: indicatorLeadingLayoutConstraint.relation,
                        toItem: indicatorLeadingLayoutConstraint.secondItem,
                        attribute: indicatorLeadingLayoutConstraint.secondAttribute,
                        multiplier: CGFloat(multiplier),
                        constant: indicatorLeadingLayoutConstraint.constant)
                    
                    newConstraint.priority = indicatorLeadingLayoutConstraint.priority
                    
                    NSLayoutConstraint.deactivateConstraints([indicatorLeadingLayoutConstraint])
                    NSLayoutConstraint.activateConstraints([newConstraint])
                    indicatorLeadingLayoutConstraint = newConstraint;
                    indicator.hidden = false;
                    self.setNeedsLayout();
                    return;
                }
            }
        }
        
        indicator.hidden = true;
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        contentView = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        contentView!.frame = bounds
        
        // Make the view stretch with containing view
        contentView!.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(contentView!)
    }
    
    func loadViewFromNib() -> UIView! {
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: String(self.dynamicType), bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
}
