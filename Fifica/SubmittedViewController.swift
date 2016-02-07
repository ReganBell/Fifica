//
//  SubmittedViewController.swift
//  Fifica
//
//  Created by Ben Griswold on 12/1/15.
//  Copyright © 2015 Ben Griswold. All rights reserved.
//

import UIKit

class SubmittedViewController: UIViewController {
    
    var leagueName = ""
    
    class func instance(leagueName: String) -> SubmittedViewController {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SubmittedViewController") as! SubmittedViewController
        controller.leagueName = leagueName
        return controller
    }
    
    @IBAction func statisticsButtonPressed(button: UIButton) {
        presentViewController(StatisticsViewController.instance(leagueName), animated: true, completion: nil)
    }
    
    // if user logs out clear username and bring up login page
    @IBAction func logoutButtonPressed(button: UIButton) {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "username")
        presentViewController(LoginViewController.instance(), animated: true, completion: nil)
    }
}