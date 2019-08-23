//
//  Settings Apperance View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-08-21.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

class Settings_Apperance_View_Controller: UITableViewController {

    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet var apperanceTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
        
        onLoad()
    }
    
    func viewColour(){
        
        self.tableView.backgroundColor = systemColour().tableViewColor()
    }

    func onLoad(){
        darkModeSwitch.isOn = UserDefaults.standard.bool(forKey: "darkModeBool")
        viewColour()
    }
    
    @IBAction func darModeSwitch(_ sender: UISwitch) {
        // set defaults based on dark mode switch toggle states
        UserDefaults.standard.set(sender.isOn,forKey: "darkModeBool")
        // send notification to toggle dark mode
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "darModeToggle"), object: nil, userInfo: ["state":sender.isOn])
        
        viewColour()
    }

}
