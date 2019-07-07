//
//  customOverallStatsCell.swift
//  
//
//  Created by Greg Brooks on 2019-04-26.
//

import UIKit

class customOverallStatsCell: UITableViewCell {
    
    // refrence to label names of goalies and players 
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var playerPositionLabel: UILabel!
    @IBOutlet weak var goalieNameLabel: UILabel!
    
    // refrence to labels used for player stats
    @IBOutlet weak var goalieGoalsAGAVGLabel: UILabel!
    @IBOutlet weak var goalieSavePerLabel: UILabel!
    @IBOutlet weak var goalieSavePerTopLeftLabel: UILabel!
    @IBOutlet weak var goalieSavePerTopRightLabel: UILabel!
    @IBOutlet weak var goalieSavePerBottomLeftLabel: UILabel!
    @IBOutlet weak var goalieSavePerBottomRightLabel: UILabel!
    @IBOutlet weak var goalieSavePerCenterLabel: UILabel!
    
    // refrence to labels used for goalie stats
    @IBOutlet weak var playerGoalCountLabel: UILabel!
    @IBOutlet weak var playerAssistCountLabel: UILabel!
    @IBOutlet weak var playerPlusMinusLabel: UILabel!
    @IBOutlet weak var playerLinePlusMinusLabel: UILabel!
    @IBOutlet weak var playerLineNumberLabel: UILabel!
    @IBOutlet weak var playerPIMLabel: UILabel!
    // refrence to preimum imageviews
    @IBOutlet weak var playerLinePlusMinusImageView: UIImageView!
    @IBOutlet weak var playerPIMIMageView: UIImageView!
    @IBOutlet weak var goalieLocationSavePerImageView: UIImageView!
    @IBOutlet weak var faceoffWinPer: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
