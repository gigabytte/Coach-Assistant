//
//  Help_Guide_View_Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-05-12.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import PDFKit

class Help_Guide_View_Controller: UIViewController {

    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var pdfView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pdfIntegration()
        // add blur effect to view along with popUpView
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.addSubview(popUpView)
        
        popUpView.layer.cornerRadius = 10
        roundedCorners().buttonBottomLeftRight(bottonViewType: closeButton)
        // Do any additional setup after loading the view.
    }
    
    func pdfIntegration(){
        
        // Add PDFView to view controller.
        let pdfView = PDFView(frame: self.pdfView.bounds)
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.pdfView.addSubview(pdfView)
        
        // Fit content in PDFView.
        pdfView.autoScales = true
        
        // Load Sample.pdf file from app bundle.
        let fileURL = Bundle.main.url(forResource: universalValue().helpGuidePDFName, withExtension: "pdf")
        pdfView.document = PDFDocument(url: fileURL!)
    }
    

    
    @IBAction func closeButton(_ sender: UIButton) {
        pdfView.willRemoveSubview(pdfView)
        dismiss(animated: true, completion: nil)
        
    }
    
}
