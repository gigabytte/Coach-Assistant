//
//  Old_Stats_Game_Details_Page.swift
//  Shot Tracker
//
//  Created by Ahad Ahmed on 2019-02-22.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

class Old_Stats_Game_Details_Page: UIViewController {

    var SeletedGame: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("Game Id Selected: ", SeletedGame!)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check is appropriate segue is being used
        if (segue.identifier == "iceSurfaceSegue"){
            // set var vc as destination segue
            let vc = segue.destination as! Old_Game_Ice_View
            vc.SeletedGame = SeletedGame
        }
        if (segue.identifier == "statsSegue"){
            // set var vc as destination segue
            let vc = segue.destination as! Old_Stats_Game_Details_Page
            vc.SeletedGame = SeletedGame
        }
    }

}
