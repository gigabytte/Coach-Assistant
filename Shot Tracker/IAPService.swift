//
//  IAPService.swift
//  app purchase test
//
//  Created by Greg Brooks on 2019-05-11.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Foundation
import StoreKit

class IAPService: NSObject {

    private override init() {}
    static let shared = IAPService()
    
    var products = [SKProduct]()
    let paymentQueue = SKPaymentQueue.default()
    
    func getProducts() {
        let products: Set = [IAPProducts.consumable.rawValue,
                             IAPProducts.nonConsumable.rawValue,
                             IAPProducts.autoRenewableSubscription.rawValue,
                             IAPProducts.nonRenewingSubscription.rawValue]
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
        paymentQueue.add(self)
    }
    
    func purchase(product: IAPProducts) {
        guard let productToPurchase = products.filter({ $0.productIdentifier == product.rawValue }).first else { return }
        let payment = SKPayment(product: productToPurchase)
        paymentQueue.add(payment)
    }
    
    func restorePurchases() {
        print("restore purchases")
        paymentQueue.restoreCompletedTransactions()
    }
    
}

extension IAPService: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
        for product in response.products {
            print(product.localizedTitle)
        }
    }
}

extension IAPService: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print(transaction.transactionState.status(), transaction.payment.productIdentifier)
            
            switch transaction.transactionState {
            case .purchasing: break
            default: queue.finishTransaction(transaction)
            }
        }
    }
}

extension SKPaymentTransactionState {
    func status() -> String {
        switch self {
        case .deferred: return "deferred"
        case .failed:
            UserDefaults.standard.set(false, forKey: "userPurchaseConf")
            //Settings_Subscriptions_View_Controller().loadingIndicator.stopAnimating()
            return "failed"
        case .purchased:
            UserDefaults.standard.set(true, forKey: "userPurchaseConf")
            return "purchased"
        case .purchasing: return "purchasing"
        case .restored: return "restored"
        }
        
    }
}


