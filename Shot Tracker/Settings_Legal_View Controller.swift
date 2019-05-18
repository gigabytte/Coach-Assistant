//
//  Settings_Legal_View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-21.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import PDFKit

class Settings_Legal_View_Controller: UIViewController {

    @IBOutlet weak var pdfView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pdfView.layer.cornerRadius = 10
        pdfIntegration()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("Legal View Controller Called")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("Legal View Controller Called")
    }

    func pdfIntegration(){
        
        // Add PDFView to view controller.
        let pdfView = PDFView(frame: self.pdfView.bounds)
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.pdfView.addSubview(pdfView)
        
        // Fit content in PDFView.
        pdfView.autoScales = true
        
        // Load legal pdf file from app bundle.
        let fileURL = Bundle.main.url(forResource: universalValue().appLegalPDF, withExtension: "pdf")
        pdfView.document = PDFDocument(url: fileURL!)
    }

}
