//
//  Initial_Setup_More_Info_View_Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-25.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

class Initial_Setup_More_Info_View_Controller: UIViewController {

    @IBOutlet weak var addTeamPlayerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTeamPlayerView.layer.cornerRadius = 10
        
        // gif processing func called
        gifProcessing()
        
        // Do any additional setup after loading the view.
    }
    
    func gifProcessing(){
        
        let jeremyGif = UIImage.gifImageWithName(universalValue().helpGuidePDFName)
        let imageView = UIImageView(image: jeremyGif)
        imageView.layer.cornerRadius = 10
        imageView.frame = CGRect(x: 10, y: 10, width: self.addTeamPlayerView.frame.size.width - 20, height: self.addTeamPlayerView.frame.size.height - 20)
        
        addTeamPlayerView.addSubview(imageView)
    }
}
