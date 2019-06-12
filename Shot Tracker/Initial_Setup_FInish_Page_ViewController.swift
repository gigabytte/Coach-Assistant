//
//  Initial_Setup_FInish_Page_ViewController.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-22.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

class Initial_Setup_FInish_Page_ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    // on finish button click
     @IBAction func finishButton(_ sender: UIButton) {
        // set new user as false and dismiss initial setup page
        UserDefaults.standard.set("false", forKey: "newUser")
        self.dismiss(animated: true, completion: nil )
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
