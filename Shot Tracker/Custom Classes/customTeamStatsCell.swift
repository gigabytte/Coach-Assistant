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

    @IBOutlet weak var pppLabel: UILabel!
    @IBOutlet weak var gfaLabel: UILabel!
    @IBOutlet weak var gaaLabel: UILabel!
    @IBOutlet weak var sfaLabel: UILabel!
    @IBOutlet weak var saaLabel: UILabel!
    @IBOutlet weak var ppgaLabel: UILabel!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var ppgaProImage: UIImageView!
    @IBOutlet weak var pppProImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
   
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
