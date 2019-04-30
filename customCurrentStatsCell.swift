//
//  customCurrentStatsCell.swift
//  
//
//  Created by Greg Brooks on 2019-04-30.
//

import UIKit

class customCurrentStatsCell: UITableViewCell {
    
    @IBOutlet weak var homePlayerNameLabel: UILabel!
    @IBOutlet weak var homePlayerStatsLabel: UILabel!
    @IBOutlet weak var awayPlayerNameLabel: UILabel!
    @IBOutlet weak var awayPlayerStatsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
