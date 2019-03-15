//
//  Old Stats Type Pop Up.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-03-15.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

class Old_Stats_Type_Pop_Up: UIViewController {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var popUpView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // round corners of popup view
        popUpView.layer.cornerRadius = 10
        // round bottom corners of button
        let path = UIBezierPath(roundedRect:cancelButton.bounds, byRoundingCorners:[.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 10, height: 10))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        cancelButton.layer.mask = maskLayer
        // Do any additional setup after loading the view.
    }
}
