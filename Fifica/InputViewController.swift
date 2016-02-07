//
//  ViewController.swift
//  Fifica
//
//  Created by Ben Griswold on 11/15/15.
//  Copyright © 2015 Ben Griswold. All rights reserved.
//

import UIKit
import Firebase

class InputViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // create variables for inputed score
    @IBOutlet var goalsForField: UITextField?
    @IBOutlet var goalsAgainstField: UITextField?
    @IBOutlet var pickerView: UIPickerView?
    @IBOutlet var loggedInAsLabel: UILabel?
    
    var leagueName: String = ""
    
    var goalsFor: Int { return (goalsForField!.text! as NSString).integerValue }
    var goalsAgainst: Int { return (goalsAgainstField!.text! as NSString).integerValue }
    
    var usersRoot: Firebase { return Firebase(url: "https://fiery-fire-4792.firebaseio.com/leagues/\(leagueName)/users") }
    var gamesRoot: Firebase { return Firebase(url:"https://fiery-fire-4792.firebaseio.com/leagues/\(leagueName)/games") }
    
    // create variables for wins
    var winForUser = 0
    var winForOpponent = 0
    var pkWin = 0
    var pkLoss = 0
    
    var opponents:[String] = []
    
    class func instance(leagueName: String) -> InputViewController {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("InputViewController") as! InputViewController
        controller.leagueName = leagueName
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let username = NSUserDefaults.standardUserDefaults().stringForKey("username") {
            loggedInAsLabel?.text = "Logged in as \(username)"
        } else {
            showLoginPage()
        }
        
        // if there are no opponents in the array query fire base so the pickerview can load
        if (opponents.count == 0) {
            usersRoot.observeSingleEventOfType(.Value, andPreviousSiblingKeyWithBlock: {snapshot, string in
                if let dict = snapshot.value as? NSDictionary, let opponents = dict.allKeys as? [String] {
                    self.opponents = opponents
                }
                self.pickerView?.reloadAllComponents()
            })
        }
    }
    
    // brings up the login page
    func showLoginPage() {
        presentViewController(LoginViewController.instance(), animated: true, completion: nil)
    }
    
    // functions needed to set up PickerView
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return opponents.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(opponents[row])"
        
    }
    
    // update pkWin or pkLoss in case of a tie game
    func pkWinButtonPressed() {
        pkWin = 1
    }
    
    func pkLossButtonPressed() {
        pkLoss = 1
    }

    // save data to firebase
    func saveToFirebase() {
        // save selected opponent
        let opponentSelected = opponents[pickerView!.selectedRowInComponent(0)]
        NSUserDefaults.standardUserDefaults().setObject(opponentSelected, forKey: "opponent")
        let username = NSUserDefaults.standardUserDefaults().stringForKey("username")!
        let child = gamesRoot.childByAutoId()
        // store all necessary statistics
        child.setValue(["GoalsFor" : goalsFor, "GoalsAgainst" : goalsAgainst, "usernameFor": username, "opponentUsername": opponentSelected, "UserWin": winForUser, "UserLoss": winForOpponent, "UserPkWin": pkWin, "UserPkLoss": pkLoss])
        
        // bring up page asking if you want to submit more data
        presentViewController(SubmittedViewController.instance(leagueName), animated: true, completion: nil)
    }
    
    
    // when submit button pressed, store score in database
    @IBAction func submitButtonPressed(button: UIButton) {
        
        // make sure scores fields are filled in, if not yell at user
        if (goalsForField!.text!.isEmpty || goalsAgainstField!.text!.isEmpty) {
            let scoreAlertController = UIAlertController(title: "Error", message: "Please enter score", preferredStyle: .Alert)
            scoreAlertController.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
            presentViewController(scoreAlertController, animated: true, completion: nil)

        }
        
        // use scores to figure out who won and save that data to firebase
        if (goalsFor > goalsAgainst) {
            winForUser = 1
            winForOpponent = 0
            saveToFirebase()
        }
        
        else if (goalsFor < goalsAgainst) {
            winForUser = 0
            winForOpponent = 1
            saveToFirebase()
        }
        
        // if there is a tie ask the user who won
        else {
            let tieAlertController = UIAlertController(title: "It's a tie", message: "Select penalty kick winner", preferredStyle: .Alert)
            
            // depending on whether the user won or lost save it to firebase
            tieAlertController.addAction(UIAlertAction(title: "I won", style: .Default, handler: { action in self.pkWinButtonPressed()
                self.saveToFirebase()
                }))
            tieAlertController.addAction(UIAlertAction(title: "I lost", style: .Default, handler: { action in self.pkLossButtonPressed()
                self.saveToFirebase()
            }))
            // create a cancel button for the alert and display it
            tieAlertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            presentViewController(tieAlertController, animated: true, completion: nil)
        }
    }
    
    // if user logs out clear username and bring up login page
    @IBAction func logoutButtonPressed(button: UIButton) {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "username")
        showLoginPage()
    }
    
    // if no game score is submitted but the see statistics button is pressed...
    @IBAction func statisticsButtonPressed(button: UIButton) {
        // save the opponent
        let opponentSelected = opponents[pickerView!.selectedRowInComponent(0)]
        NSUserDefaults.standardUserDefaults().setObject(opponentSelected, forKey: "opponent")
        
        // show statistics view
        navigationController?.pushViewController(StatisticsViewController.instance(leagueName), animated: true)
    }
}