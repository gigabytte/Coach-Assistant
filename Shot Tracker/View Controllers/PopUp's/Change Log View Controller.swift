//
//  Change Log View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-06-26.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import PDFKit

class Change_Log_View_Controller: UIViewController {

    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var pdfView: UIView!
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
        roundedCorners().buttonBottomDouble(bottonViewType: closeButton)
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func closeButton(_ sender: UIButton) {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        UserDefaults.standard.set(version, forKey: "versionLogged")
        pdfView.willRemoveSubview(pdfView)
        dismiss(animated: true, completion: nil)
        
     } 
}

