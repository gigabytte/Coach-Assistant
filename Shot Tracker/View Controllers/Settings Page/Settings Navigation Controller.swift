//
//  Settings Navigation Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-08-23.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

class Settings_Navigation_Controller: UINavigationController {

    @IBOutlet weak var navBar: UINavigationBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
         NotificationCenter.default.addObserver(self, selector: #selector(myMethod(notification:)), name: NSNotification.Name(rawValue: "darModeToggle"), object: nil)

        // Do any additional setup after loading the view.
        viewColour()
    }
    
    func viewColour(){
        
        self.view.backgroundColor = systemColour().viewColor()
        self.navBar.barTintColor = systemColour().navBarColor()
        // set nav bar propeeties based on prameters layout
        let barView = UIView(frame: CGRect(x:0, y:0, width:view.frame.width, height:UIApplication.shared.statusBarFrame.height))
        barView.backgroundColor = navBar.barTintColor
        view.addSubview(barView)
        
    }
    
    @objc func myMethod(notification: NSNotification){
        viewColour()
    }
    
}
