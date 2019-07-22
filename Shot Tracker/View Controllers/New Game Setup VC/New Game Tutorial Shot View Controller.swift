//
//  New Game Tutorial Shot View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-07-20.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Gifu


class New_Game_Tutorial_Shot_View_Controller: UIViewController {

    
    @IBOutlet weak var gifView: UIView!
    
    var toggle: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set listener for notification after goalie is selected
        NotificationCenter.default.addObserver(self, selector: #selector(myMethod(notification:)), name: NSNotification.Name(rawValue: "newGameSetupNotification"), object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if toggle != true{
            if (isKeyPresentInUserDefaults(key: "selectedGoalieID") == true){
                gifProcessing()
                print("view appered")
                toggle = true
            }
        }
    }
    
    @objc func myMethod(notification: NSNotification){
        
        gifProcessing()
        print("heard")
    }
    
    func gifProcessing(){
        
        let imageView = GIFImageView(frame: CGRect(x: 0, y: 0, width: self.gifView.frame.width, height: self.gifView.frame.height))
        imageView.animate(withGIFNamed: universalValue().helpGuidePDFName) {
           
        }
        //imageView.layer.cornerRadius = 10
        gifView.addSubview(imageView)
        gifView.layoutIfNeeded()
       
        
    }
    
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}
