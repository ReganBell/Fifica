//
//  LeaguesViewController.swift
//  Fifica
//
//  Created by Regan Bell on 2/1/16.
//  Copyright © 2016 Ben Griswold. All rights reserved.
//

import UIKit
import Cartography
import Firebase

class LeaguesViewController: UIViewController {

    var leagues = [StubLeague]()
    let tableView = UITableView()
    
    func newLeagueButtonPressed() {
        presentViewController(NewLeagueViewController.instance(), animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        leagues = [StubLeague]()
        let ref = Firebase(url:"https://fiery-fire-4792.firebaseio.com/leagues")
        ref.observeSingleEventOfType(.Value, andPreviousSiblingKeyWithBlock: { snapshot, string in
            if let leaguesDict = snapshot.value as? NSDictionary {
                self.leagues = [StubLeague]()
                for key in leaguesDict.allKeys {
                    if let key = key as? String,
                        let leagueDict = leaguesDict[key] as? NSDictionary,
                        let usersDict = leagueDict["users"] as? NSDictionary {
                            self.leagues.append(StubLeague(name: key, users: usersDict.count))
                            
                    }
                }
                self.tableView.reloadData()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Leagues"
        
        let newBarButton = UIBarButtonItem(title: "New", style: .Plain, target: self, action: "newLeagueButtonPressed")
        navigationItem.rightBarButtonItem = newBarButton
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        constrain(tableView) { $0.edges == $0.superview!.edges }
    }
}

extension LeaguesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        navigationController?.pushViewController(InputViewController.instance(leagues[indexPath.row].name), animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") ?? UITableViewCell(style: .Subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = leagues[indexPath.row].name
        let s = leagues[indexPath.row].users == 1 ? "" : "s"
        cell.detailTextLabel?.text = "\(leagues[indexPath.row].users) member\(s)"
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leagues.count
    }
}