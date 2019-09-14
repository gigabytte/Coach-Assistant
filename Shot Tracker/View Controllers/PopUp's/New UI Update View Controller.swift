//
//  New UI Update View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-09-12.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Gifu

class New_UI_Update_View_Controller: UIViewController {

    @IBOutlet weak var gifView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    
    var gifImageView: GIFImageView!
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
        if gifImageView.isAnimatingGIF == false{
            gifImageView.startAnimating()
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if gifImageView != nil{
            if (gifImageView.isAnimatingGIF == true){
                gifImageView.stopAnimating()
            }
        }
    }
    
    func gifProcessing(){
        
        gifImageView = GIFImageView(frame: CGRect(x: 0, y: 0, width: self.gifView.frame.width, height: self.gifView.frame.height))
        gifImageView.layer.cornerRadius = 10
        gifImageView.animate(withGIFNamed: universalValue().uiUpdateGif) {
        }
        
        gifView.addSubview(gifImageView)
        
        
    }

    @IBAction func closeButton(_ sender: UIButton) {
        // dismiss and set userdefaults as true noted for completion
        UserDefaults.standard.set(true, forKey: "uiUpdateBool")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dismissedUIUpdate"), object: nil, userInfo: ["key":"value"])
        self.dismiss(animated: true, completion: nil)
       
    }
}
