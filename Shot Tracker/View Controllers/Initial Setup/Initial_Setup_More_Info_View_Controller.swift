//
//  Initial_Setup_More_Info_View_Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-25.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Gifu

class Initial_Setup_More_Info_View_Controller: UIViewController {

    @IBOutlet weak var addTeamPlayerView: UIView!
    var imageView: GIFImageView!
    
    var toggleBool: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toggleBool = false
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        if (toggleBool == false){
            gifProcessing()
            toggleBool = true
        }
        if imageView.isAnimatingGIF == false{
            imageView.startAnimating()
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if imageView != nil{
            if (imageView.isAnimatingGIF == true){
                imageView.stopAnimating()
            }
        }
    }
    
    
    func gifProcessing(){
        
        imageView = GIFImageView(frame: CGRect(x: 0, y: 0, width: self.addTeamPlayerView.frame.width, height: self.addTeamPlayerView.frame.height))
        imageView.layer.cornerRadius = 10
        imageView.animate(withGIFNamed: universalValue().helpGuideGIF) {
        }
        
        addTeamPlayerView.addSubview(imageView)
        
        
    }
}
