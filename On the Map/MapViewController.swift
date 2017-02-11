//
//  MapViewController.swift
//  On the Map
//
//  Created by nekki t on 2015/12/25.
//  Copyright © 2015年 next3. All rights reserved.
//

import UIKit
import MapKit
class MapViewController: UIViewController, MKMapViewDelegate {

    // MARK: - Variables
    var manager:CLLocationManager!
    var annotations = [MKPointAnnotation]()
    var refreshObserver: NSObjectProtocol?
    var loadIndicator: UIActivityIndicatorView?
    
    var isShown: Bool = false
    
    // MARK: - IBOutlet
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
   
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator.hidden = true
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadStudentInformation()
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
                    self.configureMapView(StudentInformation.StudentInformationArr)
                } else {
                    SharedFunctions.showAlert("", message: error, targetViewController: self)
                }
            })
        }
    }
    
    // MARK: - MapViewDelegate
    // putting pins on the map
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.animatesDrop = true
        }
        else {
            pinView?.annotation = annotation
        }
        
        // set call out
        pinView?.canShowCallout = true
        
        // Information Button
        let rightButton: AnyObject! = UIButton(type: UIButtonType.DetailDisclosure)
        pinView?.rightCalloutAccessoryView = rightButton as? UIView
        
        return pinView
    }
    
    // pin tapped
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? MKPointAnnotation {
            let success = UIApplication.sharedApplication().openURL(NSURL(string:annotation.subtitle!)!)
            if !success {
                SharedFunctions.showAlert("", message: "Invalid Link", targetViewController: self)
            }
        }
    }
    
    // MARK: - Local Functions
    func configureMapView(list: [StudentInformation]?) {
        
        if let studentInformationArr = list as [StudentInformation]! {
            var lats = [Double]()
            var lons = [Double]()
            if self.annotations.count > 0 {
                self.mapView.removeAnnotations(self.annotations)
                self.annotations.removeAll()
            }
            
            for studentInformation in studentInformationArr{
               
                guard let lon = studentInformation.longitude else {
                    return
                }
                
                guard let lat = studentInformation.latitude else {
                    return
                }
                
                // avoid the identical location
                var newLon = lon
                if lats.contains(lat) && lons.contains(lon) {
                    for _ in lons {
                        newLon += 0.05
                        if !lons.contains(newLon){
                            lons.append(newLon)
                            break
                        }
                    }
                } else {
                    lats.append(lat)
                    lons.append(lon)
                }
                let cllc = CLLocationCoordinate2D(latitude: lat, longitude: newLon)
                
                let pin = MKPointAnnotation()
                pin.coordinate = cllc
                pin.title = studentInformation.firstName! + " " + studentInformation.lastName!
                pin.subtitle = studentInformation.mediaURL
                self.annotations.append(pin)
                self.mapView.addAnnotation(pin)                
            }
        }
    }
    
    func showIndicator() {
        self.loadIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
        self.loadIndicator?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        if let loading = self.loadIndicator {
            loading.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
            loading.color = UIColor.blackColor()
            self.view.userInteractionEnabled = false
            self.mapView.addSubview(loading)
            loading.startAnimating()
        }
    }
    
    func hideIndicator() {
        if let loading = self.loadIndicator {
            loading.removeFromSuperview()
            self.view.userInteractionEnabled = true
            self.loadIndicator = nil
        }
    }

}
