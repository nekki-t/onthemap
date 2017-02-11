//
//  LoginViewController.swift
//  On the Map
//
//  Created by nekki t on 2015/12/20.
//  Copyright © 2015年 next3. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    // MARK: - Constants
    let MaxColorValue: CGFloat = 255.0

    // MARK: - Variables
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    var backgroundGradient: CAGradientLayer? = nil
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    /* for smaller resolution device */
    var keyboardAdjusted = false
    var lastKeyboardOffset: CGFloat = 0.0
    
    
    var indicator: UIActivityIndicatorView?

    // MARK: - Properties

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBOutlet weak var headerTextLabel: UILabel!
    @IBOutlet weak var loginButton: BorderedButton!
    @IBOutlet weak var signInWithFacebookButton: FBSDKLoginButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Get the app delegate */
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        configureUI()
        
        // in case facebook session remains, just clear it out.
        self.facebookLogout()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addKeyboardDismissRecognizer()
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeKeyboardDissmissRecognizer()
        unsubscribeToKeyboardNotifications()
    }
    
    // MARK: - IBActions
    
    @IBAction func login(sender: UIButton) {
        
        showIndicator()
        guard(emailTextField.text != "" && passwordTextField.text != "") else {
            SharedFunctions.showAlert("", message: "Empty email or password", targetViewController: self)
            hideIndicator()
            return

        }
        
        
        // Login Execute
        UdacityClient.sharedInstance().postToLogin(emailTextField.text!, password: passwordTextField.text!) {
            (success, errorString) in
            
            if success {
                self.completeLogin()
            } else {
                self.displayError(errorString)
            }
        }
    }
    
    @IBAction func signUp(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string:UdacityClient.Constants.SignUpURL)!)
    }
    
    
    // MARK: Modify UI
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.hideIndicator()
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapListNavigationController") as! UINavigationController
            self.presentViewController(controller, animated: true, completion: nil)
            
        })
    }
    
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            self.hideIndicator()
            SharedFunctions.showAlert("", message: errorString, targetViewController: self)
        })
    }
    
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

    
    func configureUI() {
        /* Configure background gradient */
        view.backgroundColor = UIColor.clearColor()
        let colorTop = UIColor(red: 244/MaxColorValue, green: 134/MaxColorValue, blue: 16/MaxColorValue, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 241/MaxColorValue, green: 90/MaxColorValue, blue: 9/MaxColorValue, alpha: 1.0).CGColor
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, atIndex: 0)
        
        /* Configure header text label */
        headerTextLabel.font = UIFont(name: "AvenirNext-Medium", size: 24.0)
        headerTextLabel.textColor = UIColor.whiteColor()

        // Configure login button
        loginButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
        loginButton.highlightedBackingColor = SharedFunctions.getLightOrangeColor()
        loginButton.backingColor = SharedFunctions.getDarkOrangeColor()
        loginButton.backgroundColor = SharedFunctions.getDarkOrangeColor()
        loginButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        /* Configure email textfield */
        let emailTextFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0)
        let emailTextFieldPaddingView = UIView(frame: emailTextFieldPaddingViewFrame)
        emailTextField.leftView = emailTextFieldPaddingView
        emailTextField.leftViewMode = .Always
        emailTextField.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
        emailTextField.backgroundColor = SharedFunctions.getLightOrangeColor()
        emailTextField.textColor = SharedFunctions.getDarkOrangeColor()
        emailTextField.attributedPlaceholder = NSAttributedString(string: emailTextField.placeholder!,
            attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        emailTextField.tintColor = UIColor(red: 0.0, green: 0.502, blue: 0.839, alpha: 1.0)

        /* Configure password textfield */
        let passwordTextFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0)
        let passwordTextFieldPaddingView = UIView(frame: passwordTextFieldPaddingViewFrame)
        passwordTextField.leftView = passwordTextFieldPaddingView
        passwordTextField.leftViewMode = .Always
        passwordTextField.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
        passwordTextField.backgroundColor = SharedFunctions.getLightOrangeColor()
        passwordTextField.textColor = SharedFunctions.getDarkOrangeColor()
        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!,
            attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        passwordTextField.tintColor = UIColor(red: 0.0, green: 0.502, blue: 0.839, alpha: 1.0)

        /* Configure tap recognizer */
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
        /* Facebook button */
        signInWithFacebookButton.layer.masksToBounds = true
        signInWithFacebookButton.layer.cornerRadius = 4.0
    }   
    
    // MARK: Facebook Login
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!){
        
        if error != nil
        {
            self.displayError("There occured an error!: Something wrong with facebook login.")
            print(error)
            
        }
        else if result.isCancelled {
            // login canceled
            print("Canceled")
        }
        else
        {
            showIndicator()
            
            // Login Execute
            UdacityClient.sharedInstance().postToLogin(FBSDKAccessToken.currentAccessToken().tokenString){
                (success, errorString) in
                if success {
                    self.completeLogin()
                } else {
                    self.displayError(errorString)
                }
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
        showIndicator()
        
        // Logout Execute
        UdacityClient.sharedInstance().deleteToLogout() {
            (success, errorString) in
            
            // logout anyways
            self.facebookLogout()
            
            dispatch_async(dispatch_get_main_queue(), {
                self.hideIndicator()
            })
        }
    }
    
    // MARK: facebook logout
    func facebookLogout() {
        FBSDKAccessToken.currentAccessToken()
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        UdacityClient.sharedInstance().facebookToken = nil
    }
    
    // MARK: Keyboard(Show/Hide)
    func addKeyboardDismissRecognizer(){
        view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDissmissRecognizer(){
        view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            view.superview?.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardAdjusted == true {
            view.superview?.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
}
