//
//  Old Stats Ice Turoial View Analytical View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-07-24.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Gifu

class Old_Stats_Ice_Turoial_View_Analytical_View_Controller: UIViewController {

    @IBOutlet weak var gifView: UIView!
    
    var imageView: GIFImageView!
    var toggle: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set listener for notification after goalie is selected
        NotificationCenter.default.addObserver(self, selector: #selector(myCloseMethod(notification:)), name: NSNotification.Name(rawValue: "closeOldGif"), object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if toggle != true{
            gifProcessing()
            toggle = true
        }
        if imageView.isAnimatingGIF != true{
            imageView.startAnimating()
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if (imageView != nil){
            if imageView.isAnimatingGIF == true{
                imageView.stopAnimating()
            }
        }
    }
    
    func gifProcessing(){
        
        imageView = GIFImageView(frame: CGRect(x: 0, y: 0, width: self.gifView.frame.width, height: self.gifView.frame.height))
        imageView.animate(withGIFNamed: universalValue().oldStatsAnalyticalViewGif) {
            
        }
        imageView.layer.cornerRadius = 10
        gifView.addSubview(imageView)
        imageView.startAnimating()
        
    }
    
    @objc func myCloseMethod(notification: NSNotification){
        
        imageView.removeFromSuperview()
    }
    
}
