//
//  StatisticsViewController.swift
//  Fifica
//
//  Created by Ben Griswold on 12/2/15.
//  Copyright © 2015 Ben Griswold. All rights reserved.
//

import UIKit

// create a class to hold user stats (like a struct in C)
class UserStats: NSObject {
    var goalsFor = NSNumber(integer: 0)
    var goalsAgainst = NSNumber(integer: 0)
    var wins = NSNumber(integer: 0)
    var pkWins = NSNumber(integer: 0)
    var losses = NSNumber(integer: 0)
    var pkLosses = NSNumber(integer: 0)
    
    // function to keep adding up statistics as they are read in from database
    func add(number: Int, key: String) {
        let numberValue = valueForKey(key)!
        setValue(NSNumber(integer: numberValue.integerValue + number), forKey: key)
    }
}

class StatisticsViewController: UIViewController {
    
    // create a dictionary holding all the classes with each username as a key
    var allInfo = Dictionary<String, UserStats>()
    var usernames: [String] = []
    @IBOutlet weak var tableView: UITableView!
    
    // initialize the table cells
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "StatisticsTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")

    }
    override func viewDidAppear(animated:Bool) {
        // query for all the registered usernames
        let userRef = Firebase(url: "https://fiery-fire-4792.firebaseio.com/users")
        userRef.queryOrderedByChild("RegisterUsername").observeSingleEventOfType(.Value, andPreviousSiblingKeyWithBlock: { snapshot, string in
            
            // if there are some registered usernames, appened them to the usernames array
            if !(snapshot.value is NSNull) {
                for value in (snapshot.value as! NSDictionary).allValues {
                    if let value = value as? [String: String] {
                        self.usernames.append(value["RegisterUsername"]!)
                    }
                }
            }
            // itererate through the usernames
            for username in self.usernames {
                // find all the games each user has played
                let ref = Firebase(url:"https://fiery-fire-4792.firebaseio.com/games")
                ref.queryOrderedByChild("usernameFor").queryEqualToValue("\(username)").observeSingleEventOfType(.Value, andPreviousSiblingKeyWithBlock: { snapshot, string in

                    // if a player has no stats yet, use the default class values to initialize to 0.
                    if self.allInfo[username] == nil {
                        self.allInfo[username] = UserStats()
                    }
                    
                    let userStats = self.allInfo[username]!
                    
                    // create two arrays of keys, the database keys and the values in the UserStats class
                    let UserStatsKeys = ["goalsFor", "goalsAgainst", "wins", "wins", "losses", "losses", "pkLosses"]
                    let firebaseKeys = ["GoalsFor", "GoalsAgainst", "UserWin", "UserPkWin", "UserLoss", "UserPkLoss", "UserPkLoss"]
                    
                    // if there are games in the dictionary
                    if let games = snapshot.value as? NSDictionary {
                        
                        // loop through each game in dictionary
                        for game in games.allValues {
                            
                            // use zip function to iterate through 2 arrays at same time, compiling data
                            for pair in zip(UserStatsKeys, firebaseKeys) {
                                let(UserStatsKey, firebaseKey) = pair
                                
                                // use add function to keep updating the values in the UserStats Class
                                if let intValue = game[firebaseKey] as? Int {
                                    userStats.add(intValue, key: UserStatsKey)
                                }
                            }
                        }
                    }
                    
                    // add in data where each username was the opponent
                    self.getOpponentData(username)
                })
            }
        })
    }
    
    func getOpponentData(username: String) {
            // find all games where each username was the opponent
            let ref = Firebase(url:"https://fiery-fire-4792.firebaseio.com/games")
            ref.queryOrderedByChild("opponentUsername").queryEqualToValue("\(username)").observeSingleEventOfType(.Value, andPreviousSiblingKeyWithBlock: { snapshot, string in
                
                // initialize values to zero if empty
                if self.allInfo[username] == nil {
                    self.allInfo[username] = UserStats()
                }
                let userStats = self.allInfo[username]!
                
                // these arrays now match up differently because a win for the username is a userloss when username is opponent
                let UserStatsKeys = ["goalsFor", "goalsAgainst", "wins", "wins", "losses", "losses", "pkLosses"]
                let firebaseKeys = ["GoalsAgainst", "GoalsFor", "UserLoss", "UserPkLoss", "UserWin", "UserPkWin", "UserPkWin"]
                
                if let games = snapshot.value as? NSDictionary {
                    
                    // loop through each game in dictionary
                    for game in games.allValues {
                        
                        // use zip function to iterate through 2 arrays at same time, compiling data
                        for pair in zip(UserStatsKeys, firebaseKeys) {
                            let(UserStatsKey, firebaseKey) = pair
                            if let intValue = game[firebaseKey] as? Int {
                                userStats.add(intValue, key: UserStatsKey)
                            }
                        }
                    }
                }
                // sort the general standings by winning percentage using sortInPlace function
                self.usernames.sortInPlace({a,b in
                    let astats = self.allInfo[a]!
                    let bstats = self.allInfo[b]!
                    return (astats.wins.floatValue/(astats.wins.floatValue + astats.losses.floatValue) > bstats.wins.floatValue/(bstats.wins.floatValue + bstats.losses.floatValue))
                    
                })
                
                // reload the table now that all the data is set
                self.tableView.reloadData()
            })
    }
    
    // brings up head to head stats view when button is pressed
    @IBAction func seeHeadToHeadButtonPressed(button: UIButton) {
        let headToHeadViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("HeadToHeadViewController")
        presentViewController(headToHeadViewController, animated: true, completion: nil)
    }
}


extension StatisticsViewController: UITableViewDelegate, UITableViewDataSource {
    
    // create the table
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! StatisticsTableViewCell
        
            // hard code labels as the first row in the table
            if indexPath.row == 0 {
                cell.nameLabel?.textAlignment = .Center
                cell.nameLabel?.text = "Statistics:"
                cell.winsLabel?.text = "W"
                cell.lossesLabel?.text = "L"
                cell.goalsForLabel?.text = "GF"
                cell.goalsAgainstLabel?.text = "GA"
                cell.goalDifferentialLabel?.text = "Dif"
                cell.winningPercentageLabel?.text = "%"
            }
            else {
                // adjsut the array index due to the labels row
                let username = usernames[indexPath.row - 1]
                cell.nameLabel?.text = username
                
                // set the value for each table cell to its corresponding value in the UserStats class for each username
                if let stats = allInfo[username] {
                    cell.nameLabel?.textAlignment = .Left
                    cell.winsLabel?.text = stats.wins.stringValue
                    cell.lossesLabel?.text = stats.losses.stringValue
                    cell.goalsForLabel?.text = stats.goalsFor.stringValue
                    cell.goalsAgainstLabel?.text = stats.goalsAgainst.stringValue
                    let goalDifferential = stats.goalsFor.integerValue - stats.goalsAgainst.integerValue
                    cell.goalDifferentialLabel?.text =  "\(goalDifferential)"
                    let winningPercentage = (stats.wins.floatValue / (stats.wins.floatValue + stats.losses.floatValue))
                    cell.winningPercentageLabel?.text = "\(round(winningPercentage * 1000)/1000)"
                    }
            }
            return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count + 1
    }
    
}
