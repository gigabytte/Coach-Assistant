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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
  
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Override point for customization after application launch.
        // check if user is new before redirecting to pefic page
        /* MARK  Uncomment for testing
       */UserDefaults.standard.set(nil, forKey: "newUser")
      // */
        if (icloudAccountCheck().isICloudContainerAvailable() == true){
            if let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
                if (!FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: nil)) {
                    do {
                        try FileManager.default.createDirectory(at: iCloudDocumentsURL, withIntermediateDirectories: true, attributes: nil)
                    }
                    catch {
                        //Error handling
                        print("Error in creating doc")
                    }
                }
            }
        }else{
            print("iCloud Conatiner could not be made!")
        }
        if ((UserDefaults.standard.object(forKey: "newUser")) != nil){
            deleteNewGameUserDefaults.deleteUserDefaults()
          
            self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Main") as? UIViewController
            
            // Use Firebase library to configure APIs.
            FirebaseApp.configure()
            // Initialize the Google Mobile Ads SDK.
            GADMobileAds.configure(withApplicationID: "ca-app-pub-1292859049443143~4868035029")
            
            
            return true
        }else{
            // redicrt to setup process if user is new
            deleteNewGameUserDefaults.deleteUserDefaults()
            UserDefaults.standard.set(false, forKey: "userPurchaseConf")
            self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Setup") as? UIViewController
            
            return true
        }
        // get Realm Databse file location
        print(Realm.Configuration.defaultConfiguration.fileURL)
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

