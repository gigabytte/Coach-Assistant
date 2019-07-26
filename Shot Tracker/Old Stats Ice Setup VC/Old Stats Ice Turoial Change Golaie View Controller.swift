//
//  Old Stats Ice Turoial Change Golaie View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-07-24.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Gifu

class Old_Stats_Ice_Turoial_Change_Golaie_View_Controller: UIViewController {

    @IBOutlet weak var gifView: UIView!
    
    var imageView: GIFImageView!
    
    var toggle: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set listener for notification after goalie is selected
        NotificationCenter.default.addObserver(self, selector: #selector(myMethod(notification:)), name: NSNotification.Name(rawValue: "oldStatsGoalieSelection"), object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if toggle != true{
            if (isKeyPresentInUserDefaults(key: "selectedGoalieID") == true){
                gifProcessing()
                print("view appered")
                toggle = true
            }
        }else{
            if imageView.isAnimatingGIF != true && (isKeyPresentInUserDefaults(key: "selectedGoalieID") == true){
                imageView.startAnimating()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if (imageView != nil){
            if imageView.isAnimatingGIF == true{
                imageView.stopAnimating()
            }
        }
    }
    
    @objc func myMethod(notification: NSNotification){
        
        gifProcessing()
        print("heard")
    }
    
    func gifProcessing(){
        
        imageView = GIFImageView(frame: CGRect(x: 0, y: 0, width: self.gifView.frame.width, height: self.gifView.frame.height))
        imageView.animate(withGIFNamed: universalValue().shotGif) {
            
        }
        //imageView.layer.cornerRadius = 10
        gifView.addSubview(imageView)
        gifView.layoutIfNeeded()
        imageView.startAnimating()
        
        
    }
    
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}
