//
//  customTeamStatsCell.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-07-29.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

// class is used for custom tableviuew cells in over team stats
class customTeamStatsCell: UITableViewCell {

    @IBOutlet weak var statsLabel: UILabel!
    @IBOutlet weak var proStateLogoImageView: UIImageView!
    
    @IBOutlet weak var playerStatsLabel: UILabel!
    @IBOutlet weak var player_proStateLogoIMageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
   
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
