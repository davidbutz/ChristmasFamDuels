//
//  emailInvitationsViewController.swift
//  Christmas Fam Duels
//
//  Created by Dave Butz on 10/30/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit

class emailInvitationsViewController: UIViewController {

    
    @IBOutlet weak var txtemail1: UITextField!
    
    @IBOutlet weak var txtemail2: UITextField!
    
    @IBOutlet weak var txtemail3: UITextField!
    
    @IBOutlet weak var txtemail4: UITextField!
    
    @IBOutlet weak var txtemail5: UITextField!
    
    
    @IBOutlet weak var onclickSendInvitations: UIButton!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
