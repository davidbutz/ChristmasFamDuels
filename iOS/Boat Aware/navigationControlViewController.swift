//
//  navigationControlViewController.swift
//
//  Created by Dave Butz on 12/19/15.
//  Copyright © 2015 Dave Butz. All rights reserved.
//

import UIKit

class navigationControlViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let settings  = UIBarButtonItem(image: UIImage(named: "Settings.png"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(navigationControlViewController.navToSettings(_:)));
        self.navigationItem.setRightBarButtonItem(settings, animated: true);
        self.navigationBar.tintColor = UIColor.whiteColor();
        //[self.navigationItem setRightBarButtonItem: settings];
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func navToSettings(sender: UIBarButtonItem) {
        let settingview = self.storyboard?.instantiateViewControllerWithIdentifier("viewSettings");

        self.presentViewController(settingview!, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
