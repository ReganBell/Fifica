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
    var usernames: Set<String> = []
    
    class func instance() -> LoginViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
    }
    
    func displayErrorMessage(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func loginButtonPressed(button: UIButton) {
        
        guard let text = usernameField?.text where !text.isEmpty else {
            displayErrorMessage("Please enter a username")
            return
        }
        
        let userRef = Firebase(url: "https://fiery-fire-4792.firebaseio.com/users")
        userRef.queryOrderedByChild("RegisterUsername").observeSingleEventOfType(.Value) { [weak self] snapshot, string in
            
            guard let usernameDict = snapshot.value as? NSDictionary else {
                self?.displayErrorMessage("Error reaching the server")
                return
            }
            
            let usernames = Set(usernameDict.allValues.map() { return ($0 as! [String:String])["RegisterUsername"]! })
            if let username = self?.usernameField?.text where usernames.contains(username) {
                NSUserDefaults.standardUserDefaults().setObject(username, forKey: "username")
                self?.dismissViewControllerAnimated(true, completion: nil)
            } else {
                self?.displayErrorMessage("Username not found")
            }
        }
    }
}