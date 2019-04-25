//
//  Initial_Setup_More_Info_View_Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-25.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

class Initial_Setup_More_Info_View_Controller: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // gif processing func called
        gifProcessing()

        // Do any additional setup after loading the view.
    }
   
    func gifProcessing(){
        
        let jeremyGif = UIImage.gifImageWithName("funny")
        let imageView = UIImageView(image: jeremyGif)
        imageView.frame = CGRect(x: 20.0, y: 50.0, width: self.view.frame.size.width - 40, height: 150.0)
        view.addSubview(imageView)
    }
}
