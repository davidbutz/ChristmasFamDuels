//
//  cfdNavigationController.swift
//  Christmas Fam Duels
//
//  Created by Dave Butz on 11/5/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit

class cfdNavigationController: UINavigationController , UIViewControllerTransitioningDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Status bar white font
        self.navigationBar.barStyle = UIBarStyle.Black;
        //UINavigationBar.appearance().barTintColor = UIColor.redColor()
        self.navigationBar.tintColor = UIColor.whiteColor();
    }
    
}
