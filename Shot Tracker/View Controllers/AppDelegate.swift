//
//  AppDelegate.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-01-10.
//  Copyright © 2019 MAG Industries. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift
import Fabric
import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        //UserDefaults.standard.set(true, forKey: "userPurchaseConf")
        //UserDefaults.standard.set(false, forKey: "uiUpdateBool")
        // Use Firebase library to configure APIs.
        FirebaseApp.configure()
        // Initialize the Google Mobile Ads SDK.
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        // Initialize the Fabric Crashlytics SDK.
        Fabric.sharedSDK().debug = true
        
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: universalValue().realmSchemeValue,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < universalValue().realmSchemeValue) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config

        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }
        
        if (icloudAccountCheck().isICloudContainerAvailable() == true){
            if let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
                if (!FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: nil)) {
                    do {
                        try FileManager.default.createDirectory(at: iCloudDocumentsURL, withIntermediateDirectories: true, attributes: nil)
                    }
                    catch {
                        //Error handling
                        print("Error in creating iCloud Doc folder")
                    }
                }
            }
        }else{
            print("iCloud Conatiner could not be made!")
        }
        
        // Override point for customization after application launch.
        // check if user is new before redirecting to pefic page
        if checkUserDefaults().isKeyPresentInUserDefaults(key: "newUser") == true{
            if UserDefaults.standard.bool(forKey: "newUser") != true{
                deleteNewGameUserDefaults.deleteUserDefaults()
                
                createImportantDirectories()
                
                self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Main")
                
                return true
            }else{
             
                createImportantDirectories()
                // redicrt to setup process if user is new
                deleteNewGameUserDefaults.deleteUserDefaults()
                UserDefaults.standard.set(false, forKey: "userPurchaseConf")
                self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Setup")
                
                return true
            }
           
        }else{
            createImportantDirectories()
            // redicrt to setup process if user is new
            deleteNewGameUserDefaults.deleteUserDefaults()
            UserDefaults.standard.set(false, forKey: "userPurchaseConf")
            self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Setup")
            
            return true
        }
        
    }
    
    func createImportantDirectories(){

        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)!
        let teamlogo_dataPath = docURL.appendingPathComponent("TeamLogo")
        let playerlogo_dataPath = docURL.appendingPathComponent("PlayerImages")
        let gamesaves_dataPath = docURL.appendingPathComponent("Backups")
        let drawboardsaves_dataPath = docURL.appendingPathComponent("DrawboardSaves")
        // check and creat apporate directories for team logo images
        if !FileManager.default.fileExists(atPath: teamlogo_dataPath.absoluteString) {
            do {
                try FileManager.default.createDirectory(atPath: teamlogo_dataPath.absoluteString, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription);
            }
        }
        if !FileManager.default.fileExists(atPath: playerlogo_dataPath.absoluteString) {
            do {
                try FileManager.default.createDirectory(atPath: playerlogo_dataPath.absoluteString, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription);
            }
        }
        if !FileManager.default.fileExists(atPath: gamesaves_dataPath.absoluteString) {
            do {
                try FileManager.default.createDirectory(atPath: gamesaves_dataPath.absoluteString, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription);
            }
        }
        
        if !FileManager.default.fileExists(atPath: drawboardsaves_dataPath.absoluteString) {
            do {
                try FileManager.default.createDirectory(atPath: gamesaves_dataPath.absoluteString, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription);
            }
        }
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

