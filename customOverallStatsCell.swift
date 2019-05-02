//
//  customOverallStatsCell.swift
//  
//
//  Created by Greg Brooks on 2019-04-26.
//

import UIKit

class customOverallStatsCell: UITableViewCell {
    
    // used for overall stats page
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var playerStatsLabel: UILabel!
    @IBOutlet weak var goalieNameLabel: UILabel!
    @IBOutlet weak var goalieStatsLabel: UILabel!
    
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
