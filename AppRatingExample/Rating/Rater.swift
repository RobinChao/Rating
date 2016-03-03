//
//  Rater.swift
//  AppRatingExample
//
//  Created by Robin on 3/3/16.
//  Copyright © 2016 Robin. All rights reserved.
//

import UIKit

let APP_LAUNCHES = "com.robin.applaunches"
let APP_LAUNCHES_CHANGED = "com.applaunches.changed"
let APP_INSTALL_DATE = "com.robin.app.install_date"
let APP_RATING_SHOWN = "com.robin.app_shown"

public class Rater: NSObject, UIAlertViewDelegate {
    var application: UIApplication!
    var userdefaults = NSUserDefaults()
    let requiredLaunchesBeforeRating = 3
    
    public var appId: String!
    
    public static var sharedInstance = Rater()
    
    //MARK: - Initialize
    public override init() {
        super.init()
        
        setup()
    }

    private func setup() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidFinishLaunching:", name: UIApplicationDidFinishLaunchingNotification, object: nil)
    }
    
    func appDidFinishLaunching(notification: NSNotification) {
        if let _application = notification.object as? UIApplication {
            application = _application
            displayRatingPromptIfRequired()
        }
    }
    
    private func displayRatingPromptIfRequired() {
        let launches = getAppLaunchCount()
        if launches > requiredLaunchesBeforeRating {
            if #available(iOS 8.0, *) {
                    rateTheApp()
            }else{
                rateTheAppOldVersion()
            }
        }
        incrementAppLaunches()
    }
    
    @available(iOS 8.0, *)
    private func rateTheApp() {
        let app_name = NSBundle(forClass: application.delegate!.dynamicType).infoDictionary!["CFBundleName"] as? String
        let message = "Do you love the \(app_name) app? Please rate us !"
        let rateAlert = UIAlertController(title:" Rate us", message: message, preferredStyle: .Alert)
        rateAlert.addAction(UIAlertAction(title: "Rate us", style: .Default, handler: { (action) -> Void in
            let url = NSURL(string: "itms-apps://itunes.apple.com/app/id\(self.appId)")
            UIApplication.sharedApplication().openURL(url!)
            
            self.setAppRatingShown()
        }))
        rateAlert.addAction(UIAlertAction(title: "Not Now", style: .Cancel, handler: { (action) -> Void in
           self.resetAppLaunches()
        }))
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let window = self.application.windows[0]
            window.rootViewController?.presentViewController(rateAlert, animated: true, completion: nil)
        }
    }
    
    private func rateTheAppOldVersion() {
        let app_name = NSBundle(forClass: application.delegate!.dynamicType).infoDictionary!["CFBundleName"] as? String
        let message = "Do you love the \(app_name) app? Please rate us !"
        
        let alert = UIAlertView(title: "Rate us", message: message, delegate: self, cancelButtonTitle: "Not Now", otherButtonTitles: "Rate us")
        alert.show()
    }
    
    //MARK: - AlertView Delegate
    public func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        setAppRatingShown()
        let url = NSURL(string: "itms-apps://itunes.apple.com/app/id\(self.appId)")
        UIApplication.sharedApplication().openURL(url!)
    } 
    
    public func alertViewCancel(alertView: UIAlertView) {
        resetAppLaunches()
    }
    
    //MARK: - App Launch Count
    private func getAppLaunchCount()  -> Int{
        return userdefaults.integerForKey(APP_LAUNCHES)
    }
    
    private func incrementAppLaunches() {
        var launches = userdefaults.integerForKey(APP_LAUNCHES)
        launches++
        userdefaults.setInteger(launches, forKey: APP_LAUNCHES)
        userdefaults.synchronize()
    }
    
    
    private func resetAppLaunches() {
        userdefaults.setInteger(0, forKey: APP_LAUNCHES)
        userdefaults.synchronize()
    }
    
    //MARK: - Firset Launch Date
    private func setFirstLaunchDate() {
        userdefaults.setValue(NSDate(), forKey: APP_INSTALL_DATE)
        userdefaults.synchronize()
    }
    
    private func getFirstLaunchDate() -> NSDate {
        if let date = userdefaults.valueForKey(APP_INSTALL_DATE) as? NSDate {
            return date
        }
        return NSDate()
    }
    
    //MARK: - App Rating Shown
    private func setAppRatingShown() {
        userdefaults.setBool(true, forKey: APP_RATING_SHOWN)
        userdefaults.synchronize()
    }
    
    private func hasShownAppRating() -> Bool {
        return userdefaults.boolForKey(APP_RATING_SHOWN)
    }
    
    
}
