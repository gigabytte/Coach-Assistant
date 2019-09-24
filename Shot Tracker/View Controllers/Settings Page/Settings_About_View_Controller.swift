//
//  Settings_About_View_Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-27.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

class Settings_About_View_Controller: UITableViewController {

    @IBOutlet var aboutTableView: UITableView!
    @IBOutlet weak var internalVersionNumberLabel: UILabel!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(myMethod(notification:)), name: NSNotification.Name(rawValue: "darModeToggle"), object: nil)
        // query for build for version nnumber
        if let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
             self.internalVersionNumberLabel.text = "Internal Version #\(versionNumber)"
        }
       tableView.tableFooterView = UIView()
        viewColour()
    }
    
    func viewColour(){
        
        self.tableView.backgroundColor = systemColour().tableViewColor()
    }
    
    @objc func myMethod(notification: NSNotification){
        viewColour()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}
