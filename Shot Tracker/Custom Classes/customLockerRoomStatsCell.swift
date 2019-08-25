//
//  customLockerRoomStatsCell.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-08-24.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

class customLockerRoomStatsCell: UITableViewCell {

    @IBOutlet weak var playerProfileImage: UIImageView!
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var playerPositionLabel: UILabel!
    @IBOutlet weak var playerNumberLabel: UILabel!
    @IBOutlet weak var deletedPlayerIcon: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        playerProfileImage.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setCircularImageView()
    }
    
    func setCircularImageView() {
        self.playerProfileImage.layer.cornerRadius = CGFloat(roundf(Float(self.playerProfileImage.frame.size.width / 2.0)))
        self.playerProfileImage.layer.borderWidth = 3
        self.playerProfileImage.layer.borderColor = UIColor.black.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
