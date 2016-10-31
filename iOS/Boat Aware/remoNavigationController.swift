//
//  remoNavigationController.swift
//  Boat Aware
//
//  Created by Dave Butz on 4/6/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit

class remoNavigationController: UINavigationController , UIViewControllerTransitioningDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Status bar white font
        self.navigationBar.barStyle = UIBarStyle.Black;
        //UINavigationBar.appearance().barTintColor = UIColor.redColor()
        self.navigationBar.tintColor = UIColor.whiteColor();
    }

}
