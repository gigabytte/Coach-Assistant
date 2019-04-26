//
//  customOverallStatsCell.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-26.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import Foundation
import UIKit

class customOverallStatsCell: UITableViewCell {
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        settingsImageView?.widthAnchor.constraint(equalToConstant: 75.0).isActive = true
        settingsImageView?.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        settingsImageView?.clipsToBounds = true
        settingsImageView?.contentMode = .scaleAspectFit
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}
