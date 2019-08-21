//
//  Player Stats View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-08-19.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

class Locker_Room_Player_Stats_View_Controller: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(myMethod(notification:)), name: NSNotification.Name(rawValue: "homePageRefresh"), object: nil)
        // Do any additional setup after loading the view.
    }
    
    func onLoad(){
        
        
    }
    
    @objc func myMethod(notification: NSNotification){
        onLoad()
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
