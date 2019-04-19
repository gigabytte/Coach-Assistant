//
//  Settings_Defaults View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-19.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

final class Settings_Defaults_View_Controller: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("Defaults View Controller Called")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("Defaults View Controller Called")
    }

}
