//
//  FormViewController.swift
//  Boat Aware
//
//  Created by Adam Douglass on 3/14/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import Foundation

class FormViewController : UIViewController, UITextFieldDelegate {
    @IBOutlet weak var formView : UIScrollView!
    var activeTextField : UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false;
        
        // Register a touch gesture recognizer to cancel out of our input form
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(FormViewController.touch))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        recognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(recognizer)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FormViewController.keyboardNotification(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil) // 
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FormViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // Keyboard being hidden
    func keyboardWillHide(notification: NSNotification) {
        self.formView.contentInset = UIEdgeInsetsZero
        self.formView.scrollIndicatorInsets = UIEdgeInsetsZero
        self.formView.setContentOffset(CGPoint.zero, animated: false)
        self.formView.contentSize = self.view.frame.size;
    }
    
    // Keyboard did show
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            //            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            let duration:NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            
            if let activeTF = self.activeTextField {
                _ = UIView.animateWithDuration(
                    duration,
                    delay: 0.0,
                    options: [animationCurve], //[curve << 16],
                    animations: {
                        // Move the loginForm up the height of the keyboard
                        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                            
                            // Step 2: Adjust the bottom content inset of your scroll view by the keyboard height.
                            let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
                            self.formView.scrollIndicatorInsets = contentInsets;
                            self.formView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + keyboardSize.height);
                            // Step 3: Scroll the btnLogin into view.
                            let scrollPoint = CGPointMake(0.0, activeTF.frame.origin.y - (keyboardSize.height-15));
                            self.formView.setContentOffset(scrollPoint, animated:false);
                        }
                    },
                    completion: {
                        (value: Bool) in
                        
                    }
                )
            }
        }
        
    }
    
    
    // If a user touches outside the login form to dismiss the keyboard
    func touch() {
        self.view.endEditing(true)
    }
    
    // track which text field is active
    func textFieldDidBeginEditing(textField: UITextField) {
        self.activeTextField = textField
    }
}