//
//  Settings_Subscriptions_View_Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-05-12.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import RealmSwift
import StoreKit
import Realm

class Settings_Subscriptions_View_Controller: UITableViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {

    
    @IBOutlet var subTableView: UITableView!
  
    
    var productID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(myMethod(notification:)), name: NSNotification.Name(rawValue: "darModeToggle"), object: nil)
      
        tableView.tableFooterView = UIView()
        viewColour()
        
        productID = universalValue().coachAssistantProID
        SKPaymentQueue.default().add(self)
        // Do any additional setup after loading the view.
    }
    
    func viewColour(){
        
        self.tableView.backgroundColor = systemColour().tableViewColor()
    }
    
    @objc func myMethod(notification: NSNotification){
        viewColour()
    }
    
   
    
    // MARK: - SKProductRequest Delegate
    
    func buyProduct(product: SKProduct) {
        print("Sending the Payment Request to Apple");
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment);
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {

        print(response.products)
        let count : Int = response.products.count
        if (count>0) {

            let validProduct: SKProduct = response.products[0] as SKProduct
            if (validProduct.productIdentifier == self.productID! as String) {
                print(validProduct.localizedTitle)
                print(validProduct.localizedDescription)
                print(validProduct.price)
                self.buyProduct(product: validProduct)
            } else {
                print(validProduct.productIdentifier)
            }
        } else {
            purchaseErrorAlert("Could not locate products, please contact support")
            print("nothing")
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction{


                switch trans.transactionState {
                case .purchased:
                    print("Product Purchased")
                    //Do unlocking etc stuff here in case of new purchase
                    UserDefaults.standard.set(true, forKey: "userPurchaseConf")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    self.view.viewWithTag(100)?.removeFromSuperview()
                    self.view.viewWithTag(200)?.removeFromSuperview()
                    break;
                case .failed:
                    print("Purchased Failed");
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    self.view.viewWithTag(100)?.removeFromSuperview()
                    self.view.viewWithTag(200)?.removeFromSuperview()
                    purchaseErrorAlert("Failed to request product from Apple, please contact support")
                    break;
                case .restored:
                    print("Already Purchased")
                    UserDefaults.standard.set(true, forKey: "userPurchaseConf")
                    self.view.viewWithTag(100)?.removeFromSuperview()
                    self.view.viewWithTag(200)?.removeFromSuperview()
                    restoreConfAlert()
                    //Do unlocking etc stuff here in case of restor

                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                default:
                   
                    break;
                }
            }
        }
    }


    //If an error occurs, the code will go to this function
        func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
            // Show some alert
            print("Fata storkit error: \(error)")
            purchaseErrorAlert("Failed to restore product from Apple, please contact support")
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
                if (SKPaymentQueue.canMakePayments()) {
                    let productID:NSSet = NSSet(array: [self.productID! as NSString]);
                    let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>);
                    productsRequest.delegate = self;
                    productsRequest.start();
                    print("Fetching Products");
                } else {
                    print("can't make purchases");
                    purchaseErrorAlert("Failed to make purchase, please make sure you can make purchases in the App Store before continuing. If problem persits please contact support")
                    self.view.viewWithTag(100)?.removeFromSuperview()
                    self.view.viewWithTag(200)?.removeFromSuperview()
                }
            }else{
                restoreConfAlert()
            }
            break
        case 1:
            // present upgrade IAP
            if (UserDefaults.standard.bool(forKey: "userPurchaseConf") != true){
                // create the alert
                loadingView(addOrRemoveBool: true)
                if (SKPaymentQueue.canMakePayments()) {
                    SKPaymentQueue.default().add(self)
                    SKPaymentQueue.default().restoreCompletedTransactions()
                } else {
                    purchaseErrorAlert("You cannot make payments to the app store, please setup a payment method with the App Store before continuing. If problem persits please contact support")
                    self.view.viewWithTag(100)?.removeFromSuperview()
                    self.view.viewWithTag(200)?.removeFromSuperview()
                    // show error
                }
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
