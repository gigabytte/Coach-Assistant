//
//  Main_Current_Stats_View_Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-30.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

class Main_Game_Stats_View_Controller: UIViewController, UIPopoverPresentationControllerDelegate {

    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var viewTypeSwitch: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    
    var rowIndex: Int = 0
    var homeTeam: Int = UserDefaults.standard.integer(forKey: "homeTeam")
    var awayTeam: Int = UserDefaults.standard.integer(forKey: "awayTeam")

    private lazy var basicStatsView: Basic_Current_Stats_Page = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "Basic_Current_Stats_Page") as! Basic_Current_Stats_Page
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    private lazy var detailedStatsView: Detailed_Current_Stats_View_Controller = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "Detailed_Current_Stats_View_Controller") as! Detailed_Current_Stats_View_Controller
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder() // To get shake gesture
        
        
        navBarProcessing()
        setupView()
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
    
    private func setupView() {
        updateView()
    }
    
    private func updateView() {
        switch rowIndex{
        case 0:
            remove(asChildViewController: detailedStatsView)
            add(asChildViewController: basicStatsView)
        case 1:
            remove(asChildViewController: basicStatsView)
            add(asChildViewController: detailedStatsView)
        default:
            remove(asChildViewController: detailedStatsView)
            add(asChildViewController: detailedStatsView)
        }
    }
    // MARK: - Actions
    
    @objc func selectionDidChange(_ sender: UISegmentedControl) {
        updateView()
    }
    
    // MARK: - Helper Methods
    
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChild(viewController)
        
        // Add Child View as Subview
        containerView.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParent()
    }
    
    func navBarProcessing() {
        if (UserDefaults.standard.bool(forKey: "oldStatsBool") != true){
            navBar.topItem!.title = "Live Game Stats"
            navBar.topItem?.rightBarButtonItem!.title = "Analytical View"
        }else{
             navBar.topItem!.title = "Previous Game Stats"
             navBar.topItem?.rightBarButtonItem!.title = "Ice Surafce View"
        }
    }
    
    @IBAction func viewTypeSwitch(_ sender: UISegmentedControl) {
        if (UserDefaults.standard.bool(forKey: "userPurchaseConf") == true){
            switch viewTypeSwitch.selectedSegmentIndex {
            case 0:
                rowIndex = 0
                self.setupView()
            case 1:
                rowIndex = 1
                self.setupView()
            default:
                break;
            }
        }else{
            // create the alert
            let notPro = UIAlertController(title: "You're Missing Out", message: "Upgrade now and unlock an in depth look into your teams perfrommce. A break down of all your plays along with your goalies and most importantly your team as a whole.", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            notPro.addAction(UIAlertAction(title: "No Thanks", style: UIAlertAction.Style.default, handler: nil))
            // add an action (button)
            notPro.addAction(UIAlertAction(title: "Upgrade Now!", style: UIAlertAction.Style.destructive, handler: { action in
                IAPService.shared.getProducts()
                IAPService.shared.purchase(product: .autoRenewableSubscription)
                
            }))
            // show the alert
            self.present(notPro, animated: true, completion: nil)
            viewTypeSwitch.selectedSegmentIndex = 0
            
        }
    }
    @IBAction func optionsButton(_ sender: UIBarButtonItem) {
        
        if (UserDefaults.standard.bool(forKey: "oldStatsBool") != true){
            self.performSegue(withIdentifier: "analyticalSegue", sender: nil);
            
        }else{
            self.performSegue(withIdentifier: "oldStatsIceView", sender: nil);
        }
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        // check is user came from old stats or a liev game to determine segue
        if (UserDefaults.standard.bool(forKey: "oldStatsBool") != true){
             self.performSegue(withIdentifier: "liveGameStatsBack", sender: nil);
            
        }else{
            // delete user defaults then exit old game stats view
            deleteNewGameUserDefaults.deleteUserDefaults()
            self.performSegue(withIdentifier: "oldGameStatsBack", sender: nil);
        }
        
    }
    
}
