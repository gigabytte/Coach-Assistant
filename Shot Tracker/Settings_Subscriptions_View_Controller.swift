//
//  Settings_Subscriptions_View_Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-05-12.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import RealmSwift
import Realm
import Firebase

class Settings_Subscriptions_View_Controller: UIViewController {

    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var upgradeButton: UIButton!
    @IBOutlet weak var subView: UIView!
    
    @IBOutlet weak var restoreButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        upgradeButton.layer.cornerRadius = 10
        restoreButton.layer.cornerRadius = 10
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //super.viewDidLoad()
        view.alpha = 1.0
        loadingIndicator.isHidden = true
        loadingIndicator.stopAnimating()
        IAPService.shared.getProducts()
        
        if (UserDefaults.standard.bool(forKey: "userPurchaseConf") == true){
            
            upgradeButton.alpha = 0.5
            upgradeButton.isUserInteractionEnabled = false
            print("User Bought Pro")
            
        }else{
            upgradeButton.alpha = 1.0
            print("User DOES NOT HAVE Pro")
            
            
            
        }
        
        loadingIndicator.stopAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadingIndicator.stopAnimating()
    }
   
    @IBAction func restoreButton(_ sender: UIButton) {
        
        print("Lets Restore!")
        IAPService.shared.restorePurchases()
        
    }
    
    @IBAction func upgradeButton(_ sender: UIButton) {
        print("Upgrading Now!")
       //IAPService.shared.getProducts()
        loadingIndicator.startAnimating()
        view.backgroundColor = UIColor.darkGray
        view.alpha = 0.7
        upgradeButton.isUserInteractionEnabled = false
        restoreButton.isUserInteractionEnabled = false
        IAPService.shared.purchase(product: .autoRenewableSubscription)
        delay(8){
            self.view.backgroundColor = UIColor.clear
            self.view.alpha = 1.0
            self.upgradeButton.isUserInteractionEnabled = true
            self.restoreButton.isUserInteractionEnabled = true
            self.loadingIndicator.stopAnimating()
        }
        
        
        
        
        
    }
    
    // delay loop
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}
