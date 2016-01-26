//
//  RegisterViewController.swift
//  Fifica
//
//  Created by Ben Griswold on 12/1/15.
//  Copyright © 2015 Ben Griswold. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet var usernameField: UITextField?
    
    // empty array to hold taken usernames
    var takenUsernames:[String] = []
    
    @IBAction func registerButtonPressed(button: UIButton) {
        
        // make sure all fields are filled in
        if (usernameField!.text! != "") {
            
            // make sure username has not been used
            let userRef = Firebase(url: "https://fiery-fire-4792.firebaseio.com/users")
            userRef.queryOrderedByChild("RegisterUsername").observeSingleEventOfType(.Value, andPreviousSiblingKeyWithBlock: { snapshot, string in
                
                // only check against other usernames if there are other usernames in database
                if !(snapshot.value is NSNull) {
                    for value in (snapshot.value as! NSDictionary).allValues {
                        if let value = value as? [String: String] {
                            self.takenUsernames.append(value["RegisterUsername"]!)
                        }
                    }
                    
                    // compare username to all registered usernames
                    for (var i = 0; i < self.takenUsernames.count; i++)
                    {
                        // if the name is already in the database, alert the user
                        if (self.usernameField!.text == self.takenUsernames[i]) {
                            let takenUsernameAlertController = UIAlertController(title: "Name already taken", message: "Add your last name or use a nickname", preferredStyle: .Alert)
                            takenUsernameAlertController.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
                            self.presentViewController(takenUsernameAlertController, animated: true, completion: nil)
                            return
                        }
                    }
                }
                
                // remember the username so the app doesn't make you log in again
                NSUserDefaults.standardUserDefaults().setObject(self.usernameField!.text!, forKey: "username")
                
                // save username to database
                let root = Firebase(url: "https://fiery-fire-4792.firebaseio.com/users")
                let child = root.childByAutoId()
                child.setValue(["RegisterUsername" : self.usernameField!.text!])
                
                // render the score submitting page
                let ViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ViewController")
                self.presentViewController(ViewController, animated: true, completion: nil)
            })
            
                
        }
        
        // if all fields are not filled in
        else
        {
            // alert user
            let fieldsAlertController = UIAlertController(title: "Error", message: "Please fill in username field", preferredStyle: .Alert)
            fieldsAlertController.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
            presentViewController(fieldsAlertController, animated: true, completion: nil)
            
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
