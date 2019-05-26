//
//  Initial_Setup_More_Info_View_Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-25.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import SwiftyGif

class Initial_Setup_More_Info_View_Controller: UIViewController {

    @IBOutlet weak var addTeamPlayerView: UIView!
    
    var error: Error!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTeamPlayerView.layer.cornerRadius = 10
        
        // gif processing func called
        gifProcessing()
        
        // Do any additional setup after loading the view.
    }
    
    
    
    func gifProcessing(){
       
            let gif = try! UIImage(gifName: universalValue().helpGuidePDFName)
            let imageview = UIImageView(gifImage: gif, loopCount: -1) // Use -1 for infinite loop
            imageview.frame = CGRect(x: 5, y: 5, width: self.addTeamPlayerView.frame.size.width - 10, height: self.addTeamPlayerView.frame.size.height - 10)
            addTeamPlayerView.addSubview(imageview)
        
        
    }
}
