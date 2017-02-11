//
//  MapListParentTabBarController.swift
//  On the Map
//
//  Created by nekki t on 2015/12/27.
//  Copyright © 2015年 next3. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class MapListParentTabBarController: UITabBarController {

    var indicator: UIActivityIndicatorView?
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationItems()
        loadLoginUserInformation()
    }
    
    // Shared Actions are set on the navigation bar
    func setNavigationItems () {
        navigationItem.leftBarButtonItem =  UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logoutTapped")
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refreshDataTapped")
        let pinImage = UIImage(named: "pin")
        let changeLocationButton = UIBarButtonItem(image: pinImage, style: .Plain, target: self, action: "changeLocationTapped")
        navigationItem.rightBarButtonItems = [refreshButton, changeLocationButton]
    }
    
    func loadLoginUserInformation() {
        UdacityClient.sharedInstance().getPublicUserData(){
           success, errorString in
            if !success {
                dispatch_async(dispatch_get_main_queue(), {
                    SharedFunctions.showAlert("", message: errorString, targetViewController: self)
                })
            }
            print(UdacityClient.sharedInstance().publicUserData)
            print(UdacityClient.sharedInstance().userID)
        }
    }
    
    // MARK: shared navigation item actions    
    func logoutTapped() {
        showIndicator()
        
        // Logout Execute
        UdacityClient.sharedInstance().deleteToLogout() {
            (success, errorString) in
            
            if success {
                UdacityClient.sharedInstance().userID = nil
                
                if UdacityClient.sharedInstance().facebookToken != nil {
                    FBSDKAccessToken.currentAccessToken()
                    let loginManager = FBSDKLoginManager()
                    loginManager.logOut()
                    UdacityClient.sharedInstance().facebookToken = nil
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.hideIndicator()
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController")
                    self.presentViewController(controller, animated: true, completion: nil)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                 SharedFunctions.showAlert("", message: "Logout from server failed, but return to login view.", targetViewController: self)
                })
            }
        }
    }
    func refreshDataTapped() {
        NSNotificationCenter.defaultCenter().postNotificationName(SharedConstants.RefreshNotification, object: nil)
    }
    func changeLocationTapped() {
        
        // this will set login user's parse objectId -> means already posted once
        UdacityClient.sharedInstance().postedObjectId() {
            success, error in
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController
            dispatch_async(dispatch_get_main_queue(), {
                if success {
                    // Login User has already posted
                    var message = "User \"\(UdacityClient.sharedInstance().publicUserData!.firstName!) \(UdacityClient.sharedInstance().publicUserData!.lastName!)\""
                    message = message + " Has Already\nPosted a Student Location. Would You Like to Overwrite Their Location?"
                    let alert = UIAlertController(title: "", message: message, preferredStyle: .Alert)
                    
                    // Button - Overwrite
                    alert.addAction(
                        UIAlertAction(title: "Overwrite",
                            style: .Default,
                            handler: {
                                action in
                                self.presentViewController(controller, animated: true, completion: nil)
                            }
                        )
                    )
                    
                    // Button - Cancel
                    alert.addAction(
                        UIAlertAction(title:"Cancel", style: .Default, handler: nil)
                    )                    
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    // First time to post information
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            })
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
