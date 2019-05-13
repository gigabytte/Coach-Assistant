//
//  Help_Guide_View_Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-05-12.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

class Help_Guide_View_Controller: UIViewController {

    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // add blur effect to view along with popUpView
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.addSubview(popUpView)
        
        popUpView.layer.cornerRadius = 10
        bottomRoundedCorners()
        // Do any additional setup after loading the view.
    }
    
    // round corners of close button
    func bottomRoundedCorners(){
        
        // round bottom corners of button
        let path = UIBezierPath(roundedRect:closeButton.bounds, byRoundingCorners:[.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 10, height: 10))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        closeButton.layer.mask = maskLayer
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
}
