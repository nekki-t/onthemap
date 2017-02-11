//
//  ListViewController.swift
//  On the Map
//
//  Created by nekki t on 2015/12/25.
//  Copyright © 2015年 next3. All rights reserved.
//

import UIKit
import MapKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Local Variables
    var refreshObserver: NSObjectProtocol?
    var indicator: UIActivityIndicatorView?


    // MARK: - IBOutlets
    @IBOutlet weak var studentInformationTable: UITableView!

    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loadStudentInformation()
        registerRefreshObserver()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(refreshObserver!)
    }
    
    // MARK: Data Load Functions
    func registerRefreshObserver(){
        refreshObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            SharedConstants.RefreshNotification,
            object: nil,
            queue: nil,
            usingBlock: {
                notification in
                self.loadStudentInformation()
            }
        )
    }

    func loadStudentInformation() {
        showIndicator()
        UdacityClient.sharedInstance().getStudentLoations(){
            success, error in
            
            dispatch_async(dispatch_get_main_queue(), {
                self.hideIndicator()
                if success {
                    self.studentInformationTable.reloadData()
                } else {
                    SharedFunctions.showAlert("", message: error, targetViewController: self)
                }
            })
        }
    }
    
    //MARK: - TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let arrCount = StudentInformation.StudentInformationArr?.count {
            return arrCount
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let studentInformationArr = StudentInformation.StudentInformationArr else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("StudentInformationCell") as! StudentInformationTableViewCell
        cell.studentInformation = studentInformationArr[indexPath.row]
        
        UdacityClient.sharedInstance().getStudentCountry(studentInformationArr[indexPath.row].mapString) {
            countryName in
            cell.countryName = countryName
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let studentInformationArr = StudentInformation.StudentInformationArr {
            let success = UIApplication.sharedApplication().openURL(NSURL(string:studentInformationArr[indexPath.row].mediaURL!)!)
            if !success {
                SharedFunctions.showAlert("", message: "Invalid Link", targetViewController: self)
            }
        }
    }
    
    
    // MARK: - Visual Effect -> Indicator
    func showIndicator() {
        
        if let window = UIApplication.sharedApplication().keyWindow {
            self.indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
            self.indicator?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
            if let loading = self.indicator {
                loading.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
                loading.color = UIColor.blackColor()
                self.view.userInteractionEnabled = false
                window.addSubview(loading)
                loading.startAnimating()
            }
        }
    }
    
    func hideIndicator() {
        if let loading = self.indicator {
            loading.removeFromSuperview()
            self.view.userInteractionEnabled = true
            self.indicator = nil
        }
    }
    
}
