//
//  DeviceCapabilityTabBarConroller.swift
//  Boat Aware
//
//  Created by Adam Douglass on 2/9/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit

class DeviceCapabilityTabBarController: UITabBarController {
    
    var selectedCapability : Capability?
    var selectedRemoControllerID : String = "";
    var selectedRules : DeviceCapabilityRules?
    
    override func viewDidLoad() {
        self.tabBar.tintColor = UIColor.whiteColor()
        //self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.setNeedsStatusBarAppearanceUpdate()
        
        if let deviceCapability = self.selectedCapability {
            self.title = deviceCapability.capability_name;
        }

        if selectedCapability?.capability_name == "Camera"{
            self.viewControllers?.removeAtIndex(1);
            self.viewControllers?.removeAtIndex(1);
            self.viewControllers?.removeAtIndex(1);
            self.viewControllers?.removeAtIndex(1);
            self.tabBar.hidden = true;
        }
        else {
            self.tabBar.hidden = false;
            self.viewControllers?.removeAtIndex(0); // Remove Camera if not camera
        }
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = self.title

    }
}
