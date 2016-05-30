//
//  ProfileMenuViewController.swift
//  argent-ios
//
//  Created by Sinan Ulkuatam on 3/19/16.
//  Copyright © 2016 Sinan Ulkuatam. All rights reserved.
//

import Foundation
import SafariServices
import DGElasticPullToRefresh
import CWStatusBarNotification
import StoreKit

class ProfileMenuViewController: UITableViewController, SKStoreProductViewControllerDelegate {
    
    @IBOutlet weak var shareCell: UITableViewCell!

    @IBOutlet weak var rateCell: UITableViewCell!
    
    private var userImageView: UIImageView = UIImageView()

    private var scrollView: UIScrollView!

    private var notification = CWStatusBarNotification()

    private var customersArray = [Customer]()
    
    private var plansArray = [Plan]()
    
    private var customersCountLabel = UILabel()
    
    private var plansCountLabel = UILabel()

    private var locationLabel = UILabel()

    private var splitter = UIView()

    private let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 40, width: UIScreen.mainScreen().bounds.size.width, height: 50))

    private var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureHeader()
    }
    
    func configureView() {
        
        let screen = UIScreen.mainScreen().bounds
        let screenWidth = screen.size.width
        
        self.view.bringSubviewToFront(tableView)
        self.tableView.tableHeaderView = ParallaxHeaderView.init(frame: CGRectMake(0, 100, CGRectGetWidth(self.view.bounds), 220));
        
        userImageView.frame = CGRectMake(screenWidth / 2, -64, 32, 32)
    
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.frame = CGRect(x: 0, y: 100, width: screenWidth, height: 100)
        loadingView.tintColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                self?.tableView.dg_stopLoading()
                self!.loadProfile()
                self!.configureHeader()
                self!.userImageView.frame = CGRectMake(screenWidth / 2-30, -24, 60, 60)
                self!.userImageView.layer.cornerRadius = 30
            })
            }, loadingView: loadingView)
        tableView.dg_setPullToRefreshFillColor(UIColor.clearColor())
        tableView.dg_setPullToRefreshBackgroundColor(UIColor.clearColor())
        
        loadProfile()
        
        // Add action to share cell to return to activity menu
        shareCell.targetForAction(Selector("share:"), withSender: self)
        
        // Add action to rate cell to return to activity menu
        let rateGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.openStoreProductWithiTunesItemIdentifier(_:)))
        rateCell.addGestureRecognizer(rateGesture)
    }
    
    func openStoreProductWithiTunesItemIdentifier(sender: AnyObject) {
        showGlobalNotification("Loading App Store", duration: 1, inStyle: CWNotificationAnimationStyle.Top, outStyle: CWNotificationAnimationStyle.Top, notificationStyle: CWNotificationStyle.NavigationBarNotification, color: UIColor.mediumBlue())
        
        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self
        
        let parameters = [ SKStoreProductParameterITunesItemIdentifier : APP_ID]
        storeViewController.loadProductWithParameters(parameters) { [weak self] (loaded, error) -> Void in
            if loaded {
                // Parent class of self is UIViewContorller
                self?.presentViewController(storeViewController, animated: true, completion: nil)
            }
        }
    }
    
    func productViewControllerDidFinish(viewController: SKStoreProductViewController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }

    func configureHeader() {
        
        let screen = UIScreen.mainScreen().bounds
        let screenWidth = screen.size.width
        
        // let settingsIcon = UIImageView(frame: CGRectMake(0, 0, 32, 32))
        // settingsIcon.image = UIImage(named: "IconSettingsWhite")
        // settingsIcon.contentMode = .ScaleAspectFit
        // settingsIcon.alpha = 0.5
        // settingsIcon.center = CGPointMake(self.view.frame.size.width / 2, 130)
        // settingsIcon.userInteractionEnabled = true
        // let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.goToEdit(_:)))
        // tap.numberOfTapsRequired = 1
        // settingsIcon.addGestureRecognizer(tap)
        // self.view.addSubview(settingsIcon)
        // self.view.bringSubviewToFront(settingsIcon)
        
        splitter.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        splitter.frame = CGRect(x: screenWidth/2-0.5, y: 140, width: 1, height: 50)
        Timeout(0.2) {
            addSubviewWithFade(self.splitter, parentView: self)
        }
        
        let attachment: NSTextAttachment = NSTextAttachment()
        attachment.image = UIImage(named: "IconPinWhiteTiny")
        let attachmentString: NSAttributedString = NSAttributedString(attachment: attachment)
        Account.getStripeAccount { (acct, err) in
            if let address_city = acct?.address_city where address_city != "", let address_country = acct?.address_country {
                let locationStr: NSMutableAttributedString = NSMutableAttributedString(string: address_city + ", " + address_country)
                locationStr.appendAttributedString(attachmentString)
                self.locationLabel.attributedText = locationStr
                Timeout(0.2) {
                    addSubviewWithFade(self.locationLabel, parentView: self)
                }
            } else if let address_city = acct?.address_city, let address_country = acct?.address_country {
                let locationStr: NSMutableAttributedString = NSMutableAttributedString(string: "Unknown, " + address_country)
                    locationStr.appendAttributedString(attachmentString)
                    self.locationLabel.attributedText = locationStr
                    Timeout(0.2) {
                        addSubviewWithFade(self.locationLabel, parentView: self)
                }
            } else {
                let locationStr: NSMutableAttributedString = NSMutableAttributedString(string: "Unknown")
                locationStr.appendAttributedString(attachmentString)
                self.locationLabel.attributedText = locationStr
                Timeout(0.2) {
                    addSubviewWithFade(self.locationLabel, parentView: self)
                }
                showGlobalNotification("Profile Incomplete", duration: 2.5, inStyle: CWNotificationAnimationStyle.Top, outStyle: CWNotificationAnimationStyle.Top, notificationStyle: CWNotificationStyle.StatusBarNotification, color: UIColor.brandYellow())
            }
        }
        self.locationLabel.frame = CGRectMake(0, 70, screenWidth, 70)
        self.locationLabel.textAlignment = NSTextAlignment.Center
        self.locationLabel.font = UIFont(name: "Avenir-Book", size: 12)
        self.locationLabel.numberOfLines = 0
        self.locationLabel.textColor = UIColor(rgba: "#fff")

        self.customersCountLabel.frame = CGRectMake(-20, 130, screenWidth/2, 70)
        self.customersCountLabel.textAlignment = NSTextAlignment.Right
        self.customersCountLabel.font = UIFont(name: "Avenir-Book", size: 12)
        self.customersCountLabel.numberOfLines = 0
        self.customersCountLabel.textColor = UIColor(rgba: "#fff")
        
        self.plansCountLabel.frame = CGRectMake(screenWidth/2+20, 130, screenWidth/2-40, 70)
        self.plansCountLabel.textAlignment = NSTextAlignment.Left
        self.plansCountLabel.font = UIFont(name: "Avenir-Book", size: 12)
        self.plansCountLabel.numberOfLines = 0
        self.plansCountLabel.textColor = UIColor(rgba: "#fff")

        self.loadCustomerList { (customers: [Customer]?, NSError) in
            if(customers!.count == 0) {
                self.customersCountLabel.text = "No customers"
            } else if(customers!.count < 2 && customers!.count > 0) {
                self.customersCountLabel.text = String(customers!.count) + " customer"
            } else {
                self.customersCountLabel.text = String(customers!.count) + " customers"
            }
            Timeout(0.3) {
                addSubviewWithFade(self.customersCountLabel, parentView: self)
            }
        }
        
        self.loadPlanList { (plans: [Plan]?, NSError) in
            if(plans!.count == 0) {
                self.plansCountLabel.text = "No subscriptions"
            } else if(plans!.count < 2 && plans!.count > 0) {
                self.plansCountLabel.text = String(plans!.count) + " subscription"
            } else {
                self.plansCountLabel.text = String(plans!.count) + " subscriptions"
            }
            Timeout(0.3) {
                addSubviewWithFade(self.plansCountLabel, parentView: self)
            }
        }
    }
    
    // Sets up nav
    func configureNav(user: User) {
        let navItem = UINavigationItem()

        // TODO: do a check for first name, and business name
        let f_name = user.first_name
        let l_name = user.last_name
        navItem.title = f_name + " " + l_name
        
        self.navBar.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "Avenir-Light", size: 16.0)!
        ]
        self.navBar.setItems([navItem], animated: false)
        Timeout(0.1) {
            addSubviewWithFade(self.navBar, parentView: self)
        }
    }
    
    //Changing Status Bar
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // Handles logout action controller
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(tableView.cellForRowAtIndexPath(indexPath)!.tag == 865) {
            let activityViewController  = UIActivityViewController(
                activityItems: ["Check out this app!  http://www.argentapp.com/home" as NSString],
                applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
            presentViewController(activityViewController, animated: true, completion: nil)
        }
        if(tableView.cellForRowAtIndexPath(indexPath)!.tag == 534) {
            // 1
            let optionMenu = UIAlertController(title: nil, message: "Are you sure you want to logout?", preferredStyle: .ActionSheet)
            // 2
            let logoutAction = UIAlertAction(title: "Logout", style: .Destructive, handler: {
                (alert: UIAlertAction!) -> Void in
                NSUserDefaults.standardUserDefaults().setBool(false,forKey:"userLoggedIn");
                NSUserDefaults.standardUserDefaults().synchronize();
                // go to login view
                self.performSegueWithIdentifier("loginView", sender: self);
            })
            //
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                (alert: UIAlertAction!) -> Void in
            })
            // 4
            optionMenu.addAction(logoutAction)
            optionMenu.addAction(cancelAction)
            // 5
            self.presentViewController(optionMenu, animated: true, completion: nil)
        }
    }
    
    // Loads profile and sets picture
    func loadProfile() {
        
        let screen = UIScreen.mainScreen().bounds
        let screenWidth = screen.size.width
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(ProfileMenuViewController.goToEditPicture(_:)))
        userImageView.userInteractionEnabled = true
        userImageView.addGestureRecognizer(tapGestureRecognizer)
        userImageView.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin]
        userImageView.center = CGPointMake(self.view.bounds.size.width / 2, 120)
        userImageView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        userImageView.layer.masksToBounds = true
        userImageView.clipsToBounds = true
        userImageView.layer.borderWidth = 3
        userImageView.layer.borderColor = UIColor(rgba: "#fff").colorWithAlphaComponent(0.3).CGColor
        
        User.getProfile({ (user, error) in
            
            if error != nil {
                let alert = UIAlertController(title: "Error", message: "Could not load profile \(error?.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
            self.configureNav(user!)
            
            if user!.picture != "" {
                let img = UIImage(data: NSData(contentsOfURL: NSURL(string: (user!.picture))!)!)!
                self.userImageView.image = img
                addSubviewWithFade(self.userImageView, parentView: self)
            } else {
                let img = UIImage(named: "IconCamera")
                self.userImageView.image = img
                addSubviewWithFade(self.userImageView, parentView: self)
            }
        })
    }
    
    // Opens edit picture
    func goToEditPicture(sender: AnyObject) {
        self.performSegueWithIdentifier("profilePictureView", sender: sender)
    }
    
    
    // Load user data lists for customer and plan
    private func loadCustomerList(completionHandler: ([Customer]?, NSError?) -> ()) {
        Customer.getCustomerList({ (customers, error) in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: "Could not load customers \(error?.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            self.customersArray = customers!
            completionHandler(customers!, error)
        })
    }
    
    private func loadPlanList(completionHandler: ([Plan]?, NSError?) -> ()) {
        Plan.getPlanList({ (plans, error) in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: "Could not load plans \(error?.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            self.plansArray = plans!
            completionHandler(plans!, error)
        })
    }
    
    // User profile image view scroll effects
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let headerView = self.tableView.tableHeaderView as! ParallaxHeaderView
        headerView.scrollViewDidScroll(scrollView)
        
        let offsetY = scrollView.contentOffset.y
        let screen = UIScreen.mainScreen().bounds
        let screenWidth = screen.size.width
                
        if offsetY < 0 && offsetY > -80 && userImageView.frame.size.width > 16 {
            userImageView.layer.cornerRadius = (userImageView.frame.size.width/2)
            userImageView.frame = CGRect(x: screenWidth/2-(-offsetY)/2, y: -24, width: -offsetY, height: -offsetY)
        } else if offsetY < 0 {
            userImageView.layer.cornerRadius = (userImageView.frame.size.width/2)
            userImageView.frame = CGRect(x: screenWidth/2-(-offsetY)/2, y: -24, width: -offsetY, height: -offsetY)
        }
    }
}