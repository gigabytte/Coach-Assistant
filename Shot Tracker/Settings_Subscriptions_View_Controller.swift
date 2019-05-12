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

    
    @IBOutlet weak var upgradeButton: UIButton!
    
    @IBOutlet weak var restoreButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IAPService.shared.getProducts()
       // IAPService.shared.getProducts()
        //IAPService.shared.restorePurchases()
        
        if (UserDefaults.standard.bool(forKey: "userPurchaseConf") == true){
            
            upgradeButton.alpha = 0.5
            upgradeButton.isUserInteractionEnabled = false
            print("User Bought Pro")
            
        }else{
            upgradeButton.alpha = 1.0
            print("User DOES NOT HAVE Pro")
            
            
            
        }
        // Do any additional setup after loading the view.
    }
    

   
    @IBAction func restoreButton(_ sender: UIButton) {
        
        print("Lets Restore!")
        IAPService.shared.restorePurchases()
        
    }
    
    @IBAction func upgradeButton(_ sender: UIButton) {
        print("Upgrading Now!")
       //IAPService.shared.getProducts()
    IAPService.shared.purchase(product: .autoRenewableSubscription)
        
        
    }
}
