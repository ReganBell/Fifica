//
//  HeadToHeadViewController.swift
//  
//
//  Created by Ben Griswold on 12/5/15.
//
//

import UIKit
import Firebase

// create class containing head to head stats
class HeadToHeadStats: NSObject {
    var userWins = NSNumber (integer: 0)
    var opponentWins = NSNumber(integer: 0)
    var userGoals = NSNumber(integer: 0)
    var opponentGoals = NSNumber(integer: 0)
    
    // function to keep adding up statistics as they are read in from database
    func add(number: Int, key: String) {
        let numberValue = valueForKey(key)!
        setValue(NSNumber(integer: numberValue.integerValue + number), forKey: key)
    }
}

class HeadToHeadViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    class func instance(username: String, opponent: String, leagueName: String) -> HeadToHeadViewController {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("HeadToHeadViewController") as! HeadToHeadViewController
        controller.username = username
        controller.opponent = opponent
        controller.leagueName = leagueName
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize the table
        headToHeadTableView.registerNib(UINib(nibName: "StatisticsTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        getHeadToHeadStats()
    }
    
    // dictionary of HeadToHeadStats Classes with key of a username
    var headToHeadInfo = Dictionary<String, HeadToHeadStats>()
    @IBOutlet weak var headToHeadTableView: UITableView!
    
    var opponent = ""
    var username = ""
    var leagueName = ""
    var gamesRoot: Firebase { return Firebase(url:"https://fiery-fire-4792.firebaseio.com/leagues/\(leagueName)/games") }

    func getHeadToHeadStats() {
        
        // find all games where the firebase username was the current username logged in
        gamesRoot.queryOrderedByChild("usernameFor").queryEqualToValue("\(username)").observeSingleEventOfType(.Value, andPreviousSiblingKeyWithBlock: { snapshot, string in
            
            // if there are no games, initialize stats to 0
            if self.headToHeadInfo[self.username] == nil {
                self.headToHeadInfo[self.username] = HeadToHeadStats()
            }

            let headToHeadStats = self.headToHeadInfo[self.username]!
            
            // use two arrays to match the Firebase key to the corresponding value in the class
            let HeadToHeadStatsKeys = ["userWins", "userWins", "opponentWins", "opponentWins", "userGoals", "opponentGoals"]
            let firebaseKeys = ["UserWin", "UserPkWin", "UserLoss", "UserPkLoss", "GoalsFor", "GoalsAgainst"]

            if let games = snapshot.value as? NSDictionary {

                // loop through each game in dictionary
                for game in games.allValues {
                    if let userOpponent = game["opponentUsername"] as? String {
                        if (userOpponent == self.opponent) {
                            
                            // use zip function to iterate through 2 arrays at same time, compiling data
                            for pair in zip(HeadToHeadStatsKeys, firebaseKeys) {
                                let(HeadToHeadStatsKey, firebaseKey) = pair
                                if let intValue = game[firebaseKey] as? Int {
                                    headToHeadStats.add(intValue, key: HeadToHeadStatsKey)
                                }
                            }
                        }
                    }
                }
            }
            
            self.getOpponentHeadToHeadData()
        })
    }
    
    func getOpponentHeadToHeadData() {
        
        // now find all the games where the opponent was the one logged in
        gamesRoot.queryOrderedByChild("usernameFor").queryEqualToValue("\(opponent)").observeSingleEventOfType(.Value, andPreviousSiblingKeyWithBlock: { snapshot, string in
            
            if self.headToHeadInfo[self.username] == nil {
                self.headToHeadInfo[self.username] = HeadToHeadStats()
            }
            let headToHeadStats = self.headToHeadInfo[self.username]!
            
            // change the order the keys are paired because a win for the opponent is a loss for the user
            let HeadToHeadStatsKeys = ["userWins", "userWins", "opponentWins", "opponentWins", "userGoals", "opponentGoals"]
            let firebaseKeys = ["UserLoss", "UserPkLoss", "UserWin", "UserPkWin", "GoalsAgainst", "GoalsFor"]
            
            // if there are games in the dictionary...
            if let games = snapshot.value as? NSDictionary {
                
                // loop through each game in dictionary
                for game in games.allValues {
                    if let user = game["opponentUsername"] as? String {
                        
                        // if any of the games were played against the username currently logged in
                        if (user == self.username) {
                            
                            // use zip function to iterate through 2 arrays at same time, compiling data
                            for pair in zip(HeadToHeadStatsKeys, firebaseKeys) {
                                let(HeadToHeadStatsKey, firebaseKey) = pair
                                if let intValue = game[firebaseKey] as? Int {
                                    headToHeadStats.add(intValue, key: HeadToHeadStatsKey)
                                }
                            }
                        }
                    }
                }
                if self.headToHeadInfo[self.username]!.opponentWins == 0 && self.headToHeadInfo[self.username]!.userWins == 0 {
                    let alertController = UIAlertController(title: "Sorry", message: "You have never played \(self.opponent)", preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
            
            
            // reload the table
            self.headToHeadTableView.reloadData()
        })
    }
    
    // create the table
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! StatisticsTableViewCell
        
        // hard code the first row to be labels
        if indexPath.row == 0 {
            cell.nameLabel?.textAlignment = .Center
            cell.nameLabel?.text = "Head to Head Statistics:"
            cell.winsLabel?.text = "W"
            cell.lossesLabel?.text = "L"
            cell.goalsForLabel?.text = "GF"
            cell.goalsAgainstLabel?.text = "GA"
            cell.goalDifferentialLabel?.text = "Dif"
            cell.winningPercentageLabel?.text = "%"
        }
        else {
            var players = ["\(self.username)", "\(self.opponent)"]
            
            // adjust the index due to the labels row
            let player = players[indexPath.row - 1]
            cell.nameLabel?.text = player
            
            // check if there are head-to-head stats
            if let stats = headToHeadInfo[username] {
                
                // if there are, display them in proper cell for each of the two players
                if player == username {
                    cell.nameLabel?.textAlignment = .Left
                    cell.winsLabel?.text = stats.userWins.stringValue
                    cell.lossesLabel?.text = stats.opponentWins.stringValue
                    cell.goalsForLabel?.text = stats.userGoals.stringValue
                    cell.goalsAgainstLabel?.text = stats.opponentGoals.stringValue
                    let goalDifferential = stats.userGoals.integerValue - stats.opponentGoals.integerValue
                    cell.goalDifferentialLabel?.text =  "\(goalDifferential)"
                    let winningPercentage = (stats.userWins.floatValue / (stats.userWins.floatValue + stats.opponentWins.floatValue))
                    cell.winningPercentageLabel?.text = "\(round(winningPercentage * 1000)/1000)"
                }
                if player == opponent {
                    cell.nameLabel?.textAlignment = .Left
                    cell.winsLabel?.text = stats.opponentWins.stringValue
                    cell.lossesLabel?.text = stats.userWins.stringValue
                    cell.goalsForLabel?.text = stats.opponentGoals.stringValue
                    cell.goalsAgainstLabel?.text = stats.userGoals.stringValue
                    let goalDifferential = stats.opponentGoals.integerValue - stats.userGoals.integerValue
                    cell.goalDifferentialLabel?.text =  "\(goalDifferential)"
                    let winningPercentage = (stats.opponentWins.floatValue / (stats.userWins.floatValue + stats.opponentWins.floatValue))
                    cell.winningPercentageLabel?.text = "\(round(winningPercentage * 1000)/1000)"
                }
            }
        }
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
}