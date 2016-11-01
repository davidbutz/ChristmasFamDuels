//
//  DeviceCapabilityTabBarConroller.swift
//  Boat Aware
//
//  Created by Adam Douglass on 2/9/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit

class DeviceCapabilityTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        self.tabBar.tintColor = UIColor.whiteColor()
        //self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.setNeedsStatusBarAppearanceUpdate()
        self.title = "Play";
        
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.title = self.title

    }
}
