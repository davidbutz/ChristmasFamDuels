//
//  DeviceCapability_Graph.swift
//  Boat Aware
//
//  Created by Dave Butz on 4/22/16.
//  Copyright © 2016 Thrive Engineering. All rights reserved.
//

import UIKit
import Charts

class DeviceCapability_Graph: UIViewController, ChartViewDelegate  {

    @IBOutlet var lineChartView: LineChartView!
    @IBOutlet weak var capabilityTitle : CapabilityTitleView!;
    @IBOutlet weak var segcntrlFrequency: UISegmentedControl!
    @IBOutlet weak var loadingIndicator : UIActivityIndicatorView!;
    
    typealias JSONArray = Array<AnyObject>
    typealias JSONDictionary = Dictionary<String, AnyObject>
    var remoSelected = JSONDictionary();
    var selectedCapability : Capability?
    var selectedRemoControllerID : String = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the default selected to the first choice.
        segcntrlFrequency.selectedSegmentIndex = 0;
        
        // Do any additional setup after loading the view.
        self.lineChartView.delegate = self
        self.lineChartView.descriptionText = "Tap node for details"
        self.lineChartView.descriptionTextColor = UIColor.whiteColor()
        self.lineChartView.gridBackgroundColor = UIColor.darkGrayColor()
        // disabling the pinchZoom functionality.
        self.lineChartView.pinchZoomEnabled = true;
        self.lineChartView.legend.enabled = false;
        self.lineChartView!.rightAxis.enabled = false;
        self.lineChartView!.xAxis.labelPosition = .Bottom;

        // 4
        self.lineChartView.noDataText = "No data provided"
        // 5
        //setChartData(months)
        
    }
    
    @IBAction func segcntrlOnClick(sender: UISegmentedControl) {
        // todo show loading indicator
        if(sender.selectedSegmentIndex==0){
            getChartData("day");
        }
        else{
            getChartData("1week");
        }
    }
    
    
    func getChartData(timeline: String){
        self.loadingIndicator.startAnimating();
        
        let appvar = ApplicationVariables.applicationvariables;
        let api = APICalls();
        let utcoffset = NSTimeZone.localTimeZone().secondsFromGMT / 60 / 60;
        let JSONObject: [String : AnyObject] = [
            "login_token" : appvar.logintoken ]
        
        api.apicallout("/api/accounts/controllerchartcapability/" + selectedRemoControllerID + "/" + (selectedCapability?.devicecapabilities[0].device_capability_id)! + "/" + timeline + "/" + String(utcoffset) + "/" +  appvar.logintoken , iptype: "localIPAddress", method: "GET", JSONObject: JSONObject, callback: { (response) -> () in
            let chartData = response as! Dictionary<String,AnyObject>;
            let responseLine1Array = chartData["line1data"] as! JSONArray;
            let legenddataArray = chartData["legenddata"] as! JSONArray;
            var labels : Array<String> = [];
            var yVals1 : [ChartDataEntry] = [ChartDataEntry]()
            //1
            for i in 0 ..< responseLine1Array.count {
                let yaxis = responseLine1Array[i] as! JSONDictionary;
                let yaxisvalue = yaxis["yaxis"] as! NSNumber;
                let xaxisvalue = yaxis["xaxis"] as! NSNumber;
                yVals1.append(ChartDataEntry(value: Double(yaxisvalue), xIndex: Int(xaxisvalue)));
            }
            for y in 0 ..< legenddataArray.count{
                labels.append((legenddataArray[y]["groupname"] as! String));
            }
            // 2 - create a data set with our array
            
            //UIColor.blackColor()
            
            //TO DO: Change the "First Set" to something coming from the cloud/node
            let set1: LineChartDataSet = LineChartDataSet(yVals: yVals1, label: "Last Recorded Observation")
            set1.axisDependency = .Left // Line will correlate with left axis values
            set1.setColor(UIColor.blackColor().colorWithAlphaComponent(0.75)) // our line's opacity is 50%
            set1.setCircleColor(UIColor.blackColor()) // our circle will be dark red
            set1.lineWidth = 3.0//2.0
            set1.circleRadius = 3.0//6.0 // the radius of the node circle
            set1.fillAlpha = 65 / 255.0
            set1.fillColor = UIColor.blackColor()
            set1.highlightColor = UIColor.whiteColor()
            set1.drawCircleHoleEnabled = false
            set1.drawValuesEnabled = false;
            
            
            
            //3 - create an array to store our LineChartDataSets
            var dataSets : [LineChartDataSet] = [LineChartDataSet]()
            dataSets.append(set1)
            
            let additionalLines = chartData["additionalLines"] as! Int;
            var additionalLine = 1;
            var additionalLineName = "";
            while(additionalLine <= additionalLines){
                switch(additionalLine){
                case 1:
                    additionalLineName = "line2data";
                    break;
                case 2:
                    additionalLineName = "line3data";
                    break;
                case 3:
                    additionalLineName = "line4data";
                    break;
                case 4:
                    additionalLineName = "line5data";
                    break;
                case 5:
                    additionalLineName = "line6data";
                    break;
                default:
                    break;
                }
                var yValsx : [ChartDataEntry] = [ChartDataEntry]()
                let responseLinexArray = chartData[additionalLineName] as! JSONArray;
                var labelx = "";
                var state_idx = 3;
                for i in 0 ..< responseLinexArray.count {
                    let yaxis = responseLinexArray[i] as! JSONDictionary;
                    let yaxisvalue = yaxis["yaxis"] as! NSNumber;
                    let xaxisvalue = yaxis["xaxis"] as! NSNumber;
                    labelx = yaxis["range_name"] as! String;
                    state_idx = yaxis["state_id"] as! Int;
                    yValsx.append(ChartDataEntry(value: Double(yaxisvalue), xIndex: Int(xaxisvalue)));
                }
                var UICOLOR = UIColor.greenColor();
                switch (state_idx){
                case 1,
                    5:
                    UICOLOR = UIColor.redColor();
                    break;
                case 2,
                    4:
                    UICOLOR = UIColor.yellowColor();
                    break;
                default:
                    break;
                    
                }
                //TO DO: Change the "First Set" to something coming from the cloud/node
                let setx: LineChartDataSet = LineChartDataSet(yVals: yValsx, label: labelx)
                setx.axisDependency = .Left // Line will correlate with left axis values
                setx.setColor(UICOLOR.colorWithAlphaComponent(0.5)) // our line's opacity is 50%
                setx.setCircleColor(UICOLOR) // our circle will be dark red
                setx.lineWidth = 3.0//2.0
                setx.circleRadius = 0.0//6.0 // the radius of the node circle
                setx.fillAlpha = 65 / 255.0
                setx.fillColor = UICOLOR
                setx.highlightColor = UIColor.whiteColor()
                setx.drawCircleHoleEnabled = true
                
                dataSets.insert(setx, atIndex: 0);
//                dataSets.append(setx)
                additionalLine += 1;
            }
            
            //4 - pass our months in for our x-axis label value along with our dataSets
            let data: LineChartData = LineChartData(xVals: labels, dataSets: dataSets)
//            data.setValueTextColor(UIColor.whiteColor())
            data.setDrawValues(false);
            
            //5 - finally set our data
            dispatch_async(dispatch_get_main_queue(),{
                self.lineChartView.data = data;
                self.loadingIndicator.stopAnimating();
            });
        });
    }
    
    
    override func viewWillAppear(animated: Bool) {
        //appvar is needed for login token with API calls (later);
        if let deviceTabBar = self.tabBarController as? DeviceCapabilityTabBarController {
            selectedCapability = deviceTabBar.selectedCapability;
            selectedRemoControllerID = deviceTabBar.selectedRemoControllerID;
            
            //set the name of the text
            self.capabilityTitle.deviceCapability = self.selectedCapability;
            
        }
        getChartData("day");
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
