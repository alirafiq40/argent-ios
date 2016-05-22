//
//  LoginBoxTableViewController.swift
//  argent-ios
//
//  Created by Sinan Ulkuatam on 3/21/16.
//  Copyright © 2016 Sinan Ulkuatam. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import JGProgressHUD
import WatchConnectivity

class LoginBoxTableViewController: UITableViewController, UITextFieldDelegate, WCSessionDelegate {

    var window:UIWindow = UIWindow()
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet var loginTableView: UITableView!
    
    @IBOutlet weak var usernameCell: UITableViewCell!
    
    @IBOutlet weak var passwordCell: UITableViewCell!
    
    private let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screen = UIScreen.mainScreen().bounds
        let _ = screen.size.width

        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        
       // usernameTextField.becomeFirstResponder()
        
        usernameTextField.tag = 63631
        let str = NSAttributedString(string: "username or email", attributes: [NSForegroundColorAttributeName:UIColor(rgba: "#fff")])
        usernameTextField.attributedPlaceholder = str
        usernameTextField.textRectForBounds(CGRectMake(0, 0, 0, 0))
        usernameTextField.tintColor = UIColor.whiteColor()
        
        passwordTextField.tag = 63632
        let str2 = NSAttributedString(string: "password", attributes: [NSForegroundColorAttributeName:UIColor(rgba: "#fff")])
        passwordTextField.attributedPlaceholder = str2
        passwordTextField.textRectForBounds(CGRectMake(0, 0, 0, 0))
        passwordTextField.tintColor = UIColor.whiteColor()

        loginTableView.separatorColor = UIColor(rgba: "#ccc3")
        loginTableView.backgroundColor = UIColor(rgba: "#2221")

        usernameCell.backgroundColor = UIColor.clearColor()
        usernameCell.textLabel?.textColor = UIColor.whiteColor()
        
        passwordCell.backgroundColor = UIColor.clearColor()
        passwordCell.textLabel?.textColor = UIColor.whiteColor()
        
        // Blurview
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        visualEffectView.frame = CGRectMake(0, 0, 600, 500)
        self.view.addSubview(visualEffectView)
        self.view.sendSubviewToBack(visualEffectView)
    }
    
    func login(sender: AnyObject) {
        
        activityIndicator.center = tableView.center
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        
        if(usernameTextField.text == "" || passwordTextField.text == "") {
            displayAlertMessage("Fields cannot be empty")
            activityIndicator.stopAnimating()
            activityIndicator.hidden = true
        }
        Auth.login(usernameTextField.text!, username: usernameTextField.text!, password: passwordTextField.text!) { (token, grant, err) in
            if(grant == true && token != "") {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
                self.performSegueWithIdentifier("homeView", sender: self)
                // Send access token and Stripe key to Apple Watch
                if WCSession.isSupported() { //makes sure it's not an iPad or iPod
                    let watchSession = WCSession.defaultSession()
                    watchSession.delegate = self
                    watchSession.activateSession()
                    if watchSession.paired && watchSession.watchAppInstalled {
                        do {
                            try watchSession.updateApplicationContext(
                                [
                                    "user_token": token
                                ]
                            )
                            print("setting watch data")
                        } catch let error as NSError {
                            print(error.description)
                        }
                    }
                }
            } else {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
                self.displayAlertMessage("Error logging in")
            }
        }
    }
    
    func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 0, 10)
    }
    // text position
    
    func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 0, 10)
    }
    
    override func viewWillDisappear(animated: Bool) {

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // IMPORTANT: This allows the rootViewController to be prepared upon login when preparing for segue (transition) to the HomeViewController
        // Without this the side nav menu will not work!
        switch sender?.tag {
        case 1?:
            // Login button pressed
            print("logging in")
        case 2?:
            // Signup button pressed
            print("signup pressed")
        case 3?:
            // New signup button pressed
            print("new signup pressed")
        default:
            // Sent root view controller (default is login) otherwise send to register page
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let rootViewController = (sb.instantiateViewControllerWithIdentifier("RootViewController")) as UIViewController
            self.presentViewController(rootViewController, animated: true, completion: nil)
            self.window.rootViewController = rootViewController
            UIApplication.sharedApplication().keyWindow?.rootViewController = rootViewController
            // critical: ensures rootViewController is set on login
        }
    }
    
    // Allow use of next and join on keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let nextTag: Int = textField.tag + 1
        let nextResponder: UIResponder? = textField.superview?.superview?.viewWithTag(nextTag)
        if let nextR = nextResponder
        {
            // Found next responder, so set it.
            //nextR.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            self.login(self)
            textField.resignFirstResponder()
            return true
        }
        return false
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func displayDefaultErrorAlertMessage(alertMessage:String) {
        let alertView: UIAlertController = UIAlertController(title: "Error", message: alertMessage, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    func displayAlertMessage(alertMessage:String) {
        let alertView: UIAlertController = UIAlertController(title: "Error", message: alertMessage, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    func displayErrorAlertMessage(alertMessage:String) {
        let alertView: UIAlertController = UIAlertController(title: "Error", message: alertMessage, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        self.presentViewController(alertView, animated: true, completion: nil)
    }
}