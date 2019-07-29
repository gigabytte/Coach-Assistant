//
//  New Game Tutorial Menu Options View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-07-24.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Gifu

class New_Game_Tutorial_Menu_Options_View_Controller: UIViewController {

    @IBOutlet weak var gifView: UIView!
    
    var imageView: GIFImageView!
    var toggle: Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (imageView != nil){
            if toggle != true{
                gifProcessing()
                toggle = true
            }
            if imageView.isAnimatingGIF != true{
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
    
    
    func gifProcessing(){
     
        imageView = GIFImageView(frame: CGRect(x: 0, y: 0, width: self.gifView.frame.width, height: self.gifView.frame.height))
        imageView.animate(withGIFNamed: universalValue().newGameSettingsGif) {
            
        }
        imageView.layer.cornerRadius = 10
        gifView.addSubview(imageView)
        imageView.startAnimating()
 
    }
 
}
