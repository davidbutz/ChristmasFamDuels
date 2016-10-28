//
//  DeviceCapability_Slider.swift
//  Boat Aware
//
//  Created by Dave Butz on 5/25/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit

class DeviceCapability_Slider: UIViewController , UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
  
    @IBOutlet var lblCapability: UILabel!
    
    @IBOutlet var viewCurrentStatus: UIView!
    
    //let rangeSlider = RangeSlider(frame: CGRectZero)
    var selectedCapability : Capability?
    var selectedRemoControllerID : String = "";
    var selectedRules :  DeviceCapabilityRules?
    var rulesList : Array<DeviceCapabilityRule> = [];
    let textCellIdentifier = "rulescell"
    var selected_rule = JSONDictionary()
    
    
    typealias JSONArray = Array<AnyObject>
    typealias JSONDictionary = Dictionary<String, AnyObject>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self;
        tableView.dataSource = self;
        //rangeSlider.backgroundColor = UIColor.redColor()
        
        //view.addSubview(rangeSlider)
        //rangeSlider.addTarget(self, action: #selector(DeviceCapability_Slider.rangeSliderValueChanged(_:)), forControlEvents: .ValueChanged)
    }
    
    override func viewDidAppear(animated: Bool) {
        //let appvar = ApplicationVariables.applicationvariables;
        if let deviceTabBar = self.tabBarController as? DeviceCapabilityTabBarController {
            selectedCapability = deviceTabBar.selectedCapability;
            selectedRemoControllerID = deviceTabBar.selectedRemoControllerID;
            selectedRules = deviceTabBar.selectedRules;
            if let _ = selectedRules?.rules {
                self.rulesList = (selectedRules?.rules)!;
            }
            
            //set the name of the text
            if let capability_name = selectedCapability?.capability_name{
                lblCapability.text = "Rules - " + capability_name;
            }
            
            var color = UIColor(red: 85/255, green: 137/255, blue: 84/255, alpha: 1);
            if let crrstateid = self.selectedCapability?.devicecapabilities[0].current_state_id {
                switch(String(crrstateid)){
                case "1":
                    color = UIColor.redColor();
                    break;
                case "5":
                    color = UIColor.redColor();
                    break;
                case "4":
                    color = UIColor.yellowColor();
                    break;
                case "2":
                    color = UIColor.yellowColor();
                    break;
                default:
                    break;
                }
            }
            dispatch_async(dispatch_get_main_queue(),{
                //put both the current state and the bar at the top (viewCurrentStatus) to the appropriate colors;
                self.viewCurrentStatus.backgroundColor = color;
                self.tableView.reloadData();
            })
        }
    }
    
    
    func rangeSliderValueChanged(rangeSlider: RangeSlider) {
        print("Range slider value changed: (\(rangeSlider.firstValue) \(rangeSlider.secondValue) \(rangeSlider.thirdValue) \(rangeSlider.fourthValue))")
    }
    
    //override func viewDidLayoutSubviews() {
    //    let margin: CGFloat = 20.0
    //    let width = view.bounds.width - 2.0 * margin
     //   rangeSlider.frame = CGRect(x: margin, y: margin + topLayoutGuide.length,
     //                              width: width, height: 31.0)
    //}

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rulesList.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        // Configure the cell...
        let rule = DeviceCapabilityRule(rulenative: rulesList[indexPath.row]);
        
        let rule_name = rule?.rule_name;
        let cellview = cell.viewWithTag(1) as! UILabel;
        cellview.text = rule_name;
        
        let cellimageleft = cell.viewWithTag(3);
        let cellimageright = cell.viewWithTag(4);
        let cellimageview = cell.viewWithTag(2);
        
        var lowerbound = NSNumber(double: 0.0);
        var upperbound = NSNumber(double: 0.0);
        //first I'll get the LBound and UBound of the Range.
        if let lbound = rule?.rule_range[0].gte{
            if lbound == -1 {
                lowerbound = 0.0;
            }
            else {
                lowerbound = lbound;
            }
        }
        if let ubound = rule?.rule_range[4].lt{
            if ubound == -1 {
                upperbound = 0.0;
            }
            else {
                upperbound = ubound;
            }
        }
        //then i'll get the set points for each thumb.
        let firstThumbValue = rule?.rule_range[0].lt;
        let secondThumbValue = rule?.rule_range[1].lt;
        let thirdThumbValue = rule?.rule_range[2].lt;
        let fourthThumbValue = rule?.rule_range[3].lt;
        
        //then i'll create a label for the left sitting inside of "let margin: CGFloat = 20.0"
        //so basically 0-20...
        let leftSlider = UITextField();
        leftSlider.text = lowerbound.stringValue;
        leftSlider.font = UIFont(name: "MarkerFelt-Thin", size: 10);
        leftSlider.contentVerticalAlignment = UIControlContentVerticalAlignment.Center;
        leftSlider.frame = CGRect(x: 0, y: 0, width: 30, height: 31.0);
        cellimageleft!.addSubview(leftSlider);
        
        
        let rightSlider = UITextField();
        rightSlider.text = upperbound.stringValue;
        rightSlider.font = UIFont(name: "MarkerFelt-Thin", size: 10);
        rightSlider.contentVerticalAlignment = UIControlContentVerticalAlignment.Center;
        rightSlider.frame = CGRect(x: 0, y: 0, width: 60, height: 31.0);
        cellimageright!.addSubview(rightSlider);
        
        //then i'll create a slider that meets that criteria.
        let rangeSlider = RangeSlider(frame: CGRectZero);
        rangeSlider.firstValue = Double(firstThumbValue!);
        rangeSlider.secondValue = Double(secondThumbValue!);
        rangeSlider.thirdValue = Double(thirdThumbValue!);
        rangeSlider.fourthValue = Double(fourthThumbValue!);
        rangeSlider.minimumValue = Double(lowerbound);
        rangeSlider.maximumValue = Double(upperbound);
        
        let margin: CGFloat = 5
        //hmmm width is tough.
        let width = view.bounds.width - 40.0 //2.0 * margin
        //rangeSlider.frame = CGRect(x: margin, y: margin + topLayoutGuide.length, width: width, height: 31.0)
        rangeSlider.frame = CGRect(x: margin, y: 0,
                                   width: width, height: 31.0)

        cellimageview!.addSubview(rangeSlider)
        //let trailingConstraint = NSLayoutConstraint(item: rangeSlider, attribute: .Leading, relatedBy: .Equal, toItem: leftSlider, attribute: .Trailing, multiplier: 1, constant: 1);
        //let topConstraint = NSLayoutConstraint(item: rangeSlider, attribute: .Baseline, relatedBy: .Equal, toItem: leftSlider, attribute: .Baseline, multiplier: 1, constant: 1);
        //cellimageview!.addConstraint(trailingConstraint);
        //cellimageview!.addConstraint(topConstraint);
        rangeSlider.addTarget(self, action: #selector(DeviceCapability_Slider.rangeSliderValueChanged(_:)), forControlEvents: .ValueChanged)

        
        return cell
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        selected_rule = getJson(rulesList[indexPath.row]);
        //pass you along to the next View... if there is one....
        //performSegueWithIdentifier("remoView", sender: self)
        print(rulesList[indexPath.row]);
        
    }
    
    
    func getJson(data : DeviceCapabilityRule) -> JSONDictionary {
        let json : [String: AnyObject] = ["rule_name": data.rule_name, "current_state_id": data.current_state_id, "date_of_change": data.date_of_change! ]
        return json;
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
