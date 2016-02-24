//
//  NewLeagueViewController.swift
//  Fifica
//
//  Created by Regan Bell on 2/19/16.
//  Copyright © 2016 Ben Griswold. All rights reserved.
//

import UIKit
import Firebase

class NewLeagueViewController: UIViewController {

    @IBOutlet var leagueTitleField: UITextField?
    
    @IBAction func createButtonPressed(button: UIButton) {
        let ref = Firebase(url:"https://fiery-fire-4792.firebaseio.com/leagues")
        let child = ref.childByAppendingPath("/\(leagueTitleField!.text!)/users")
        button.setTitle("Creating...", forState: .Normal)
        child.setValue(["Ben": true, "Alvaro": true, "Regan": true, "Akshay": true]) {error, firebase in
            if !(error is NSNull) {
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                button.setTitle("Create league", forState: .Normal)
            }
        }
    }
    
    class func instance() -> NewLeagueViewController {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("NewLeagueViewController") as! NewLeagueViewController
        return controller
    }
}