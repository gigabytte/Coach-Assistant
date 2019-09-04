//
//  customPlayerImportCell.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-09-04.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

class customPlayerImportCell: UITableViewCell {
    
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var playerJerseyNumLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
