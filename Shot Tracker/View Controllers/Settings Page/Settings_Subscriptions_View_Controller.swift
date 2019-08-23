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

class Settings_Subscriptions_View_Controller: UITableViewController {

    
    @IBOutlet var subTableView: UITableView!
  
    
    var productID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(myMethod(notification:)), name: NSNotification.Name(rawValue: "darModeToggle"), object: nil)
        productID = universalValue().coachAssistantProID
      
        tableView.tableFooterView = UIView()
        viewColour()
        // Do any additional setup after loading the view.
    }
    
    func viewColour(){
        
        self.tableView.backgroundColor = systemColour().tableViewColor()
    }
    
    @objc func myMethod(notification: NSNotification){
        viewColour()
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
                self.purchaseErrorAlert(localizedString().localized(value: "An upgrade cannot be found an unknown error occured. Please contact support."))
            }
        }
    }
    
  
    func productPurchase(){
        
        SwiftyStoreKit.purchaseProduct(productID, quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                self.view.viewWithTag(100)?.removeFromSuperview()
                self.view.viewWithTag(200)?.removeFromSuperview()
                UserDefaults.standard.set(true, forKey: "userPurchaseConf")
                
            case .error(let error):
                switch error.code {
                case .unknown:
                    print("Unknown error. Please contact support")
                    self.purchaseErrorAlert("Unknown error. Please contact support")
                    self.view.viewWithTag(100)?.removeFromSuperview()
                    self.view.viewWithTag(200)?.removeFromSuperview()
                case .clientInvalid:
                    self.view.viewWithTag(100)?.removeFromSuperview()
                    self.view.viewWithTag(200)?.removeFromSuperview()
                    print("Not allowed to make the payment")
                case .paymentCancelled:
                    self.view.viewWithTag(100)?.removeFromSuperview()
                    self.view.viewWithTag(200)?.removeFromSuperview()
                    break
                case .paymentInvalid:
                    self.view.viewWithTag(100)?.removeFromSuperview()
                    self.view.viewWithTag(200)?.removeFromSuperview()
                    print("The purchase identifier was invalid")
                case .paymentNotAllowed:
                    print("The device is not allowed to make the payment")
                    self.purchaseErrorAlert("The device is not allowed to make the payment")
                case .storeProductNotAvailable:
                    print("The product is not available in the current storefront")
                    self.purchaseErrorAlert("The product is not available in the current storefront")
                case .cloudServicePermissionDenied:
                    print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed:
                    print("Could not connect to the network")
                    self.purchaseErrorAlert("Could not connect to the network, please make sure your are connected to the internet")
                case .cloudServiceRevoked:
                    print("User has revoked permission to use this cloud service")
                    self.purchaseErrorAlert("Please update your account premisions or call Apple for furthur assitance regarding your cloud premissions")
                default:
                    self.view.viewWithTag(100)?.removeFromSuperview()
                    self.view.viewWithTag(200)?.removeFromSuperview()
                    print((error as NSError).localizedDescription)
                }
            }
        }
        
    }
    
    func loadingView(addOrRemoveBool: Bool){
        if addOrRemoveBool == true{
            let loadingView = UIView()
            loadingView.backgroundColor = UIColor.lightGray
            loadingView.alpha = 0.5
            loadingView.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height)
            loadingView.tag = 100
            
            let loadingIndicator = UIActivityIndicatorView()
            loadingIndicator.frame = CGRect(x: self.view.center.x, y: self.view.center.y, width: 0, height: 0)
            loadingIndicator.startAnimating()
            loadingIndicator.tag = 200
            
            self.view.addSubview(loadingView)
            self.view.addSubview(loadingIndicator)
        }else{
            
            if self.view.viewWithTag(100) != nil{
                self.view.viewWithTag(100)?.removeFromSuperview()
                
            }
            if self.view.viewWithTag(200) != nil{
                self.view.viewWithTag(200)?.removeFromSuperview()
            }
        }
    }
    
    
    func productRestore(){
        
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
                self.loadingView(addOrRemoveBool: false)
            }
            else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
                self.loadingView(addOrRemoveBool: false)
                UserDefaults.standard.set(true, forKey: "proUser")
                
            }
            else {
                print("Nothing to Restore")
                self.loadingView(addOrRemoveBool: false)
            }
        }
    }
    
    func restoreConfAlert(){
        // create the alert
        let alreadyProAlert = UIAlertController(title: localizedString().localized(value:"Already a Pro!"), message: localizedString().localized(value:"We have restored your Coach Assistant: Ice Hockey 'Pro' Membership, thank you again for your previous purchase :)"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        alreadyProAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(alreadyProAlert, animated: true, completion: nil)
        
    }
    
    func purchaseErrorAlert(_ alertMsg: String){
        // create the alert
        let alreadyProAlert = UIAlertController(title: "Whoops!", message: alertMsg, preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        alreadyProAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(alreadyProAlert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        switch indexPath.row {
        case 0:
            // present upgrade IAP
            if (UserDefaults.standard.bool(forKey: "userPurchaseConf") != true){
                print("Upgrading Now!")
                loadingView(addOrRemoveBool: true)
                productRetrieve()
                productPurchase()
            }else{
                restoreConfAlert()
            }
            break
        case 1:
            // present upgrade IAP
            if (UserDefaults.standard.bool(forKey: "userPurchaseConf") != true){
                // create the alert
                loadingView(addOrRemoveBool: true)
                productRetrieve()
                productRestore()
            }else{
                restoreConfAlert()
            }
            break
        default:
            self.purchaseErrorAlert("Unknown error. Please contact support")
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // delay loop
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}
