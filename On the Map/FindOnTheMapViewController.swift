//
//  FindOnTheMapViewController.swift
//  On the Map
//
//  Created by nekki t on 2015/12/30.
//  Copyright © 2015年 next3. All rights reserved.
//

import UIKit
import MapKit

class FindOnTheMapViewController: UIViewController, MKMapViewDelegate, UITextViewDelegate {
    // MARK: - Constants
    let textViewGuideString = "Enter a Link to Share Here"
    
    // Variables
    var placemark: CLPlacemark! // Set in the previous view
    var tapRecognizer: UITapGestureRecognizer? = nil

    // MARK: - IBOutlets
    @IBOutlet weak var shareLinkTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: BorderedButton!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardDismissRecognizer()
        dropPin()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardDissmissRecognizer()
    }
    

    // MARK: - IBActions
    // Go back to Map and Table tab view
    @IBAction func cancel(sender: UIButton) {
        view.endEditing(true)
        // close all
        presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitLocation(sender: UIButton) {
        view.endEditing(true)
        if shareLinkTextView.text == "" || shareLinkTextView.text == textViewGuideString{
            SharedFunctions.showAlert("", message: "Must Enter a Link", targetViewController: self)
            return
        } else if !(shareLinkTextView.text.containsString("http://") ||
            shareLinkTextView.text.containsString("https://")) {
                SharedFunctions.showAlert("", message: "Your link is invalid.\nPlease put \"http://\" or \"https://\" at first.", targetViewController: self)
            return
        }
        
        UdacityClient.sharedInstance().registerUserLocation (placemark.location!.coordinate.latitude, lon: placemark.location!.coordinate.longitude, mapString: placemark.name!, mediaURL: shareLinkTextView.text!) {
            success, errorString in
            dispatch_async(dispatch_get_main_queue(), {
                if !success {
                        SharedFunctions.showAlert("", message: errorString, targetViewController: self)
                } else {
                    // close all
                    self.presentingViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                    NSNotificationCenter.defaultCenter().postNotificationName(SharedConstants.RefreshNotification, object: nil)
                }
            })
        }
        
    }
    
    // MARK: - MapView Delegates
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.animatesDrop = true        
        
        return pinView
    }
    
    // MARK: - Local Functions
    func configureUI(){
        mapView.delegate = self
        
        shareLinkTextView.textAlignment = .Center
        shareLinkTextView.text = textViewGuideString
        shareLinkTextView.delegate = self
        /* Configure tap recognizer */
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
        SharedFunctions.setPostingButton(submitButton)

    }
    func dropPin() {
        let point = MKPointAnnotation()
        point.coordinate = placemark.location!.coordinate
        point.title = placemark.name
        point.subtitle = placemark.country
        mapView.addAnnotation(point)
        mapView.showAnnotations([point], animated: true)
    }
    // if text is empty, show guide
    func recoverTextViewGuide() {
        shareLinkTextView.textAlignment = .Center
        if shareLinkTextView.text == "" {
            shareLinkTextView.text = textViewGuideString
        }
    }
    
    // MARK: - textView Delegate
    
    // clear if text is the guide text
    func textViewDidBeginEditing(textView: UITextView) {
        shareLinkTextView.textAlignment = .Left
        if textView.text == textViewGuideString {
            textView.text = "http://"
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
    
}
