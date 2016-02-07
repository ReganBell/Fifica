//
//  LoginViewController.swift
//  Fifica
//
//  Created by Ben Griswold on 11/30/15.
//  Copyright © 2015 Ben Griswold. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    // create variables for username and password
    @IBOutlet var usernameField: UITextField?
    var usernames:[String] = []
    
    class func instance() -> LoginViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
    }
    
    @IBAction func submitButtonPressed(button: UIButton) {
        
        // make sure login field is filled in
        if usernameField!.text != "" {
            var validUsername = false
            
            // query Firebase to get all the registered usernames
            let userRef = Firebase(url: "https://fiery-fire-4792.firebaseio.com/users")
            userRef.queryOrderedByChild("RegisterUsername").observeSingleEventOfType(.Value, andPreviousSiblingKeyWithBlock: { snapshot, string in
                
                // if there are usernames, append them to the usernames array
                if !(snapshot.value is NSNull) {
                    for value in (snapshot.value as! NSDictionary).allValues {
                        if let value = value as? [String: String] {
                            self.usernames.append(value["RegisterUsername"]!)
                        }
                    }
                    
                    // make sure login username matches a registered username
                    for (var i = 0; i < self.usernames.count; i++)
                    {
                        if (self.usernameField!.text! == self.usernames[i]) {
                            validUsername = true
                        }
                    }
                }
                // if the username has already been registered bring up the main view controller
                if (validUsername == true) {
                    
                    NSUserDefaults.standardUserDefaults().setObject(self.usernameField!.text!, forKey: "username")
                    let ViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ViewController")
                    self.presentViewController(ViewController, animated: true, completion: nil)
                    
                }
                // if the username has not been registered, display an error message
                else {
                    let validUsernameAlertController = UIAlertController(title: "Error", message: "Username not found", preferredStyle: .Alert)
                    validUsernameAlertController.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
                    self.presentViewController(validUsernameAlertController, animated: true, completion: nil)
                }
                
            })
        }
        // if the username field has not been filled in, display an error message
        else {
            let alertController = UIAlertController(title: "Error", message: "Please enter username", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
            presentViewController(alertController, animated: true, completion: nil)
        }
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
