//
//  StatisticsTableViewCell.swift
//  Fifica
//
//  Created by Ben Griswold on 12/5/15.
//  Copyright © 2015 Ben Griswold. All rights reserved.
//

import UIKit

// create the names for the table cells
class StatisticsTableViewCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var winsLabel: UILabel?
    @IBOutlet var goalsForLabel: UILabel?
    @IBOutlet var goalsAgainstLabel: UILabel?
    @IBOutlet var lossesLabel: UILabel?
    @IBOutlet var goalDifferentialLabel: UILabel?
    @IBOutlet var winningPercentageLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}