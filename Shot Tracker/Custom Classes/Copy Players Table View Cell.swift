//
//  Copy Players Table View Cell.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-08-30.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

class Copy_Players_Table_View_Cell: UITableViewCell {

    @IBOutlet weak var playerPositionLabel: UILabel!
    @IBOutlet weak var playerNumberLabel: UILabel!
    @IBOutlet weak var playerNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
