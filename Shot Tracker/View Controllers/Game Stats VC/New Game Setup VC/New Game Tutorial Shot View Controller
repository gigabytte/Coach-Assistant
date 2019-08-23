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
    
    var imageView: GIFImageView!
    
    var toggle: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set listener for notification after goalie is selected
        NotificationCenter.default.addObserver(self, selector: #selector(myMethod(notification:)), name: NSNotification.Name(rawValue: "newGameSetupNotification"), object: nil)
        // set listener for notification after goalie is selected
        NotificationCenter.default.addObserver(self, selector: #selector(myCloseMethod(notification:)), name: NSNotification.Name(rawValue: "closeGif"), object: nil)
        
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
                print("View Disppered")
            }
        }
    }
    
    @objc func myMethod(notification: NSNotification){
        
        gifProcessing()
        print("heard")
    }
    
    @objc func myCloseMethod(notification: NSNotification){
        
        imageView.removeFromSuperview()
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
