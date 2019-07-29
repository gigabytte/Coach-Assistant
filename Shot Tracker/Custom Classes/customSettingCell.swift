//
//  customSettingCell.swift
//  
//
//  Created by Greg Brooks on 2019-05-11.
//

import UIKit

class customSettingCell: UITableViewCell {
    
    @IBOutlet weak var settingsLabel: UILabel?
    @IBOutlet weak var settingsImageView: UIImageView?
    
    
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
