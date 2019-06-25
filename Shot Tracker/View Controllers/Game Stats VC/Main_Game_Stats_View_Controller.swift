//
//  Main_Current_Stats_View_Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-30.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

class Main_Game_Stats_View_Controller: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBAction func unwindToMainStats(segue: UIStoryboardSegue) {}
    
    @IBOutlet weak var upgradeView: UIView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var viewTypeSwitch: UISegmentedControl!
    @IBOutlet weak var basic_containerView: UIView!
    @IBOutlet weak var detailed_containerView: UIView!
    
    // defaults
    var rowIndex: Int = 0
    var homeTeam: Int = UserDefaults.standard.integer(forKey: "homeTeam")
    var awayTeam: Int = UserDefaults.standard.integer(forKey: "awayTeam")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder() // To get shake gesture
        /* Un coomment for testing trial period
        UserDefaults.standard.removeObject(forKey: "userTrialPeriod")
        */
        basic_containerView.isHidden = false
        detailed_containerView.isHidden = true
        navBarProcessing()
        
        // Do any additional setup after loading the view.
    }
    
    // We are willing to become first responder to get shake motion
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    // Enable detection of shake motion
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            /* let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
             let newViewController = storyBoard.instantiateViewController(withIdentifier: "Help_View_Controller") as! Help_Guide_View_Controller
             self.present(newViewController, animated: true, completion: nil)*/
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let popupVC = storyboard.instantiateViewController(withIdentifier: "Help_View_Controller") as! Help_Guide_View_Controller
            popupVC.modalPresentationStyle = .overCurrentContext
            popupVC.modalTransitionStyle = .crossDissolve
            let pVC = popupVC.popoverPresentationController
            pVC?.permittedArrowDirections = .any
            pVC?.delegate = self
            
            present(popupVC, animated: true, completion: nil)
            print("Help Guide Presented!")
        }
    }
    
    
    func navBarProcessing() {
        // change nav bar dynamically based on game type
        if (UserDefaults.standard.bool(forKey: "oldStatsBool") != true){
            navBar.topItem!.title = "Live Game Stats"
            navBar.topItem?.rightBarButtonItem!.title = "Analytical View"
        }else{
             navBar.topItem!.title = "Previous Game Stats"
             navBar.topItem?.rightBarButtonItem!.title = "Ice Surafce View"
        }
    }
    
    @IBAction func viewTypeSwitch(_ sender: UISegmentedControl) {
            switch viewTypeSwitch.selectedSegmentIndex {
            case 0:
                rowIndex = 0
                basic_containerView.isHidden = false
                detailed_containerView.isHidden = true
                self.upgradeView.isHidden = true
            case 1:
                // check is user is pro before allowing detailed view access
                if (UserDefaults.standard.bool(forKey: "userPurchaseConf") == true){
                    rowIndex = 1
                    detailed_containerView.isHidden = false
                    basic_containerView.isHidden = true
                }else{
                    // check is user has looked at detailed stats previosuly without pro
                     if (isKeyPresentInUserDefaults(key: "userTrialPeriod") != true){
                        print("Trail Stats Period")
                        rowIndex = 1
                        upgradeView.isHidden = false
                        self.basic_containerView.isHidden = true
                        self.detailed_containerView.isHidden = false
                        // allow user to view detailed stats for a trail amount of time
                        delay(10){
                            self.noUpgradeAlert()
                            UserDefaults.standard.set(false, forKey: "userTrialPeriod")
                            
                            self.basic_containerView.isHidden = false
                            self.detailed_containerView.isHidden = true
                            self.upgradeView.isHidden = true
                            self.viewTypeSwitch.selectedSegmentIndex = 0
                            self.rowIndex = 0
                            
                        }
                        
                     }else{
                        // if user has no free trial and is not pro ask to upgrade
                        noUpgradeAlert()
                        viewTypeSwitch.selectedSegmentIndex = 0
                    }
                   
                }
            default:
                print("FATAL ERROR, SWITCH Statement Failed")
                break
            }
    }
    @IBAction func optionsButton(_ sender: UIBarButtonItem) {
        
        if (UserDefaults.standard.bool(forKey: "oldStatsBool") != true){
            //self.performSegue(withIdentifier: "analyticalSegue", sender: nil);
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let popupVC = storyboard.instantiateViewController(withIdentifier: "Analytical_View_Controller") as! Current_Stats_Ananlytical_View
            popupVC.modalPresentationStyle = .overCurrentContext
            popupVC.modalTransitionStyle = .crossDissolve
            let pVC = popupVC.popoverPresentationController
            pVC?.permittedArrowDirections = .any
            pVC?.delegate = self
            
            present(popupVC, animated: true, completion: nil)
            print("Analytical_View_Controller Presented!")
        }else{
            self.performSegue(withIdentifier: "oldStatsIceView", sender: nil);
           
        }
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        // check is user came from old stats or a liev game to determine segue
        if (UserDefaults.standard.bool(forKey: "oldStatsBool") != true){
            //self.performSegue(withIdentifier: "liveGameStatsBack", sender: nil);
            self.presentingViewController?.dismiss(animated: true, completion: nil)
            
        }else{
            // delete user defaults then exit old game stats view
            deleteNewGameUserDefaults.deleteUserDefaults()
            self.performSegue(withIdentifier: "Back_To_Old_Stats_Game_Satst", sender: nil);
        }
        
    }
    
    func noUpgradeAlert(){
        
        // create the alert
        let notPro = UIAlertController(title: "You're Missing Out", message: "Upgrade now and unlock an in depth look into your teams performance. A break down of all your plays along with your goalies stats and most importantly your team as a whole.", preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        notPro.addAction(UIAlertAction(title: "No Thanks", style: UIAlertAction.Style.default, handler: nil))
        // add an action (button)
        notPro.addAction(UIAlertAction(title: "Upgrade Now!", style: UIAlertAction.Style.destructive, handler: { action in
            IAPService.shared.getProducts()
            IAPService.shared.purchase(product: .nonConsumable)
            
        }))
        // show the alert
        self.present(notPro, animated: true, completion: nil)
        viewTypeSwitch.selectedSegmentIndex = 0
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    // delay loop
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
}
