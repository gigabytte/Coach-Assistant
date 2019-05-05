//
//  Main_Current_Stats_View_Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-30.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

class Main_Game_Stats_View_Controller: UIViewController {

    
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
        navBarProcessing()
        setupView()
        // Do any additional setup after loading the view.
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
