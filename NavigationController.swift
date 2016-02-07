//
//  NavigationController.swift
//  Fifica
//
//  Created by Regan Bell on 2/1/16.
//  Copyright © 2016 Ben Griswold. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        navigationBar.barTintColor = greenColor
        navigationBar.tintColor = UIColor.whiteColor()
        navigationBar.opaque = true
        navigationBar.translucent = false
        navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "AvenirNext-DemiBold", size: 14)!, NSForegroundColorAttributeName : UIColor.whiteColor()]
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        view.backgroundColor = greenColor
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}