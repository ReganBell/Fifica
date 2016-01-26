//
//  SubmittedViewController.swift
//  Fifica
//
//  Created by Ben Griswold on 12/1/15.
//  Copyright © 2015 Ben Griswold. All rights reserved.
//

import UIKit

class SubmittedViewController: UIViewController {

    func showLoginPage() {
        let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController")
        presentViewController(loginViewController, animated: true, completion: nil)
    }
    
    // if user logs out clear username and bring up login page
    @IBAction func logoutButtonPressed(button: UIButton) {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "username")
        showLoginPage()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
}
