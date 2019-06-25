//
//  customCurrentStatsCell.swift
//  
//
//  Created by Greg Brooks on 2019-04-30.
//

import UIKit

class customCurrentStatsCell: UITableViewCell {
    
    // used during basic current stats page
    @IBOutlet weak var homePlayerNameLabel: UILabel!
    @IBOutlet weak var homePlayerStatsLabel: UILabel!
    @IBOutlet weak var awayPlayerNameLabel: UILabel!
    @IBOutlet weak var awayPlayerStatsLabel: UILabel!
    
    // used for detailed stats section in current stats during a live game
    @IBOutlet weak var detailedHomePlayerNameLabel: UILabel!
    @IBOutlet weak var detailedHomePlayerStatsLabel: UILabel!
    @IBOutlet weak var detailedAwayPlayerNameLabel: UILabel!
    @IBOutlet weak var detailedAwayPlayerStatsLabel: UILabel!
    @IBOutlet weak var detailedHomeGoalieNameLabel: UILabel!
    @IBOutlet weak var detailedHomeGoalieStatsLabel: UILabel!
    @IBOutlet weak var teamStatNameLabel: UILabel!
    @IBOutlet weak var teamStatValueLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
