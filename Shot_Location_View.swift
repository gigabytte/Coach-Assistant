//
//  Shot_Location_View.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-01-24.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

class Shot_Location_View: UIViewController {
    
    @IBOutlet weak var shotLocationView: UIView!
    
    var xShotSegueCords: Int = 0
    var yShotSegueCords: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        shotLocationView.layer.cornerRadius = 10
        shotLocationView.layer.masksToBounds = true
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
