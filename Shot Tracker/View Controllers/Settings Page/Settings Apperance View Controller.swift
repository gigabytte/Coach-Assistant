//
//  Settings Apperance View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-08-21.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

class Settings_Apperance_View_Controller: UIViewController {

    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    func onLoad(){
        darkModeSwitch.isOn = UserDefaults.standard.bool(forKey: "darkModeBool")
    }
    
    @IBAction func darModeSwitch(_ sender: UISwitch) {
        // set defaults based on dark mode switch toggle states
        UserDefaults.standard.set(sender.isOn,forKey: "darkModeBool")
        // send notification to toggle dark mode
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "darModeToggle"), object: nil, userInfo: ["state":sender.isOn])
    }
}
