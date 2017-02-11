//
//  InformationPostingViewController.swift
//  On the Map
//
//  Created by nekki t on 2015/12/30.
//  Copyright © 2015年 next3. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class InformationPostingViewController: UIViewController, UITextViewDelegate {
    // MARK: - Constants
    let textViewGuideString = "Enter Your Location Here"
    
    // MARK: - Variables
    var tapRecognizer: UITapGestureRecognizer? = nil
    var indicator: UIActivityIndicatorView?

    
    // MARK: - IBOutlets
    @IBOutlet weak var findOnTheMapButton: BorderedButton!
    @IBOutlet weak var locationTextView: UITextView!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardDismissRecognizer()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardDissmissRecognizer()
    }
    
    // MARK: - IBActions
    @IBAction func cancel(sender: UIButton) {
        view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findOnTheMap(sender: UIButton) {
        view.endEditing(true)
        if locationTextView.text == "" || locationTextView.text == textViewGuideString{
            SharedFunctions.showAlert("", message: "Must Enter a Location", targetViewController: self)
            return
        }
        showIndicator()
        let geoCoder = CLGeocoder()
        
        // Geocode Search
        geoCoder.geocodeAddressString(locationTextView.text) {
                placemarks, error in
            
            self.hideIndicator()
            if let placemark = placemarks?.first {
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("FindOnTheMapViewController") as! FindOnTheMapViewController
                controller.placemark = placemark
                self.presentViewController(controller, animated: true, completion: nil)
            } else {
                SharedFunctions.showAlert("", message: "Could Not Geocode the String.", targetViewController: self)
            }            
        }
    }
    
    // MARK: - Local Functions
    func configureUI () {
        SharedFunctions.setPostingButton(findOnTheMapButton)
        locationTextView.text = textViewGuideString
        locationTextView.textAlignment = .Center
        
        locationTextView.delegate = self
        
        /* Configure tap recognizer */
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
    }
    
    // if text is empty, show guide
    func recoverTextViewGuide() {
        locationTextView.textAlignment = .Center
        if locationTextView.text == "" {
            locationTextView.text = textViewGuideString
        }
    }
    
    // MARK: - textView Delegate
    
    // clear if text is the guide text
    func textViewDidBeginEditing(textView: UITextView) {
        locationTextView.textAlignment = .Left
        if textView.text == textViewGuideString {
            textView.text = ""
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            recoverTextViewGuide()
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        recoverTextViewGuide()
    }
    
    // MARK: Keyboard(Show/Hide)
    func addKeyboardDismissRecognizer(){
        view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDissmissRecognizer(){
        view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        recoverTextViewGuide()
        view.endEditing(true)
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
