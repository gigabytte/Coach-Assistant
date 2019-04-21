//
//  customSettingCell.swift
//  
//
//  Created by Greg Brooks on 2019-04-19.
//

import UIKit

class customSettingCell: UITableViewCell {

    @IBOutlet weak var settingsLabel: UILabel?
    @IBOutlet weak var settingsImageView: UIImageView?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
