//
//  New Game Tutorial Faceoff View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-07-20.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Gifu

class New_Game_Tutorial_Faceoff_View_Controller: UIViewController {

    @IBOutlet weak var gifView: UIView!
    var toggle: Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if toggle != true{
            gifProcessing()
            toggle = true
        }
        
    }
    
    func gifProcessing(){
        
        let imageView = GIFImageView(frame: CGRect(x: 0, y: 0, width: self.gifView.frame.width, height: self.gifView.frame.height))
        imageView.animate(withGIFNamed: universalValue().helpGuidePDFName) {
            
        }
        imageView.layer.cornerRadius = 10
        gifView.addSubview(imageView)
        
    }

}
