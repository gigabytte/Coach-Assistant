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
import SwiftyStoreKit

class Settings_Subscriptions_View_Controller: UIViewController {

    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var upgradeButton: UIButton!
    @IBOutlet weak var subView: UIView!
    
    @IBOutlet weak var restoreButton: UIButton!
    
    var productID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        productID = universalValue().coachAssistantProID
        productRetrieve()
        
        upgradeButton.layer.cornerRadius = 10
        restoreButton.layer.cornerRadius = 10
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //super.viewDidLoad()
        view.alpha = 1.0
        loadingIndicator.isHidden = true
        loadingIndicator.stopAnimating()
        
        
        if (UserDefaults.standard.bool(forKey: "userPurchaseConf") == true){
            
            upgradeButton.alpha = 0.5
            //upgradeButton.isUserInteractionEnabled = false
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
        productRestore()
    }
    
    @IBAction func upgradeButton(_ sender: UIButton) {
        if (UserDefaults.standard.bool(forKey: "userPurchaseConf") != true){
            print("Upgrading Now!")
            loadingIndicator.startAnimating()
            view.backgroundColor = UIColor.darkGray
            view.alpha = 0.7
            upgradeButton.isUserInteractionEnabled = false
            restoreButton.isUserInteractionEnabled = false
            productPurchase()
        }else{
            // create the alert
            let alreadyProAlert = UIAlertController(title: "Already a Pro!", message: "Looks like you have already purchased Coach Assistant: Ice Hockey PRO, if you have questions regarding your subscription visit the app store.", preferredStyle: UIAlertController.Style.alert)
            // add an action (button)
            alreadyProAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            // show the alert
            self.present(alreadyProAlert, animated: true, completion: nil)
        }
        
    }
    
    func productRetrieve(){
        
        SwiftyStoreKit.retrieveProductsInfo([productID]) { result in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                print("Product: \(product.localizedDescription), price: \(priceString)")
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
            }
            else {
                print("Error: \(result.error)")
                self.purchaseErrorAlert(alertMsg: "An upgrade cannot be found an unknown error occured. Please contact support.")
            }
        }
    }
    
    func productPurchase(){
        
        SwiftyStoreKit.purchaseProduct(productID, quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                UserDefaults.standard.set(true, forKey: "userPurchaseConf")
                self.uiSuccess()
                
            case .error(let error):
                switch error.code {
                case .unknown:
                    print("Unknown error. Please contact support")
                    self.purchaseErrorAlert(alertMsg: "Unknown error. Please contact support")
                    self.uiCancel()
                case .clientInvalid:
                    print("Not allowed to make the payment")
                    self.uiCancel()
                case .paymentCancelled:
                    self.uiCancel()
                    break
                case .paymentInvalid:
                    print("The purchase identifier was invalid")
                    self.uiCancel()
                case .paymentNotAllowed:
                    print("The device is not allowed to make the payment")
                    self.purchaseErrorAlert(alertMsg: "The device is not allowed to make the payment")
                    self.uiCancel()
                case .storeProductNotAvailable:
                    print("The product is not available in the current storefront")
                    self.purchaseErrorAlert(alertMsg: "The product is not available in the current storefront")
                    self.uiCancel()
                case .cloudServicePermissionDenied:
                    print("Access to cloud service information is not allowed")
                    self.uiCancel()
                case .cloudServiceNetworkConnectionFailed:
                    print("Could not connect to the network")
                    self.purchaseErrorAlert(alertMsg: "Could not connect to the network, please make sure your are connected to the internet")
                    self.uiCancel()
                case .cloudServiceRevoked:
                    print("User has revoked permission to use this cloud service")
                    self.purchaseErrorAlert(alertMsg: "Please update your account premisions or call Apple for furthur assitance regarding your cloud premissions")
                    self.uiCancel()
                default:
                    print((error as NSError).localizedDescription)
                    self.uiCancel()
                }
            }
        }
        
    }
    
    func uiSuccess(){
        
        loadingIndicator.stopAnimating()
        self.view.backgroundColor = UIColor.clear
        self.view.alpha = 1.0
        
        self.upgradeButton.isUserInteractionEnabled = true
        self.restoreButton.isUserInteractionEnabled = true
        self.loadingIndicator.stopAnimating()
        self.restoreButton.alpha = 0.5
        
    }
    
    func uiCancel(){
        loadingIndicator.stopAnimating()
        self.view.backgroundColor = UIColor.clear
        self.view.alpha = 1.0
        self.upgradeButton.isUserInteractionEnabled = true
        self.restoreButton.isUserInteractionEnabled = true
    }
    
    
    func productRestore(){
        
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
            }
            else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
                self.restoreConfAlert()
                UserDefaults.standard.set(true, forKey: "userPurchaseConf")
                self.restoreButton.alpha = 0.5
                self.restoreButton.isUserInteractionEnabled = false
            }
            else {
                print("Nothing to Restore")
            }
        }
    }
    
    func restoreConfAlert(){
        // create the alert
        let alreadyProAlert = UIAlertController(title: "Already a Pro!", message: "We have restored your Coach Assistant: Ice Hockey 'Pro' Membership, thank you again for your previous purchase :)", preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        alreadyProAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(alreadyProAlert, animated: true, completion: nil)
        
    }
    
    func purchaseErrorAlert(alertMsg: String){
        // create the alert
        let alreadyProAlert = UIAlertController(title: "Whoops!", message: alertMsg, preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        alreadyProAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(alreadyProAlert, animated: true, completion: nil)
    }
    
    // delay loop
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}
