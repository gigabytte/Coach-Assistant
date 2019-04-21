//
//  Settings_Legal_View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-21.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

class Settings_Legal_View_Controller: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("Legal View Controller Called")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("Legal View Controller Called")
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
