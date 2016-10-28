//
//  CapabilityTitleView.swift
//  Boat Aware
//
//  Created by Adam Douglass on 6/23/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit

@IBDesignable

class CapabilityTitleView : UIView {
    var contentView : UIView?
    @IBOutlet weak var statusLabel : UILabel!;
    
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
    
    var deviceCapability: Capability? {
        didSet {
            if let deviceCapability = deviceCapability {

                // Depending on the "state" of the deviceCapability: set the bar color + title
                switch (deviceCapability.devicecapabilities[0].current_state_id.intValue) {
                    case 1:
                        self.statusLabel.text = "CRITICAL";
                        self.contentView!.backgroundColor = UIColor.boatAwareRed();
                        break;
                    case 5:
                        self.statusLabel.text = "CRITICAL";
                        self.contentView!.backgroundColor = UIColor.boatAwareRed();
                        break;
                    case 4:
                        self.statusLabel.text = "WARNING";
                        self.contentView!.backgroundColor = UIColor.boatAwareOrange();
                        break;
                    case 2:
                        self.statusLabel.text = "WARNING";
                        self.contentView!.backgroundColor = UIColor.boatAwareOrange();
                        break;
                    case 3:
                        self.statusLabel.text = "ALL GOOD";
                        self.contentView!.backgroundColor = UIColor.boatAwareGreen();
                        break;
                    default:
                        break;
                }
                self.setNeedsDisplay();
            }
        }
    }

    
}
