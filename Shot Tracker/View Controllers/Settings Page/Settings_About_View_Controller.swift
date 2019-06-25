//
//  Settings_About_View_Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-27.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

class Settings_About_View_Controller: UIViewController {

    @IBOutlet weak var versionNumberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // query for build for version nnumber
        if let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.versionNumberLabel.text = "Version #\(versionNumber)"
        }
        // Do any additional setup after loading the view.
    }
 

}
