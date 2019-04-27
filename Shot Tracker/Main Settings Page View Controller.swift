//
//  Main Settings Page View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-19.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

final class Main_Settings_Page_View_Controller: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    
    var rowIndex: Int!
    
    
    // Data model: These strings will be the data for the table view cells
    let settingsName: [String] = ["Backup", "Defaults", "Legal", "About"]
    let imageNames: [String] = ["backup.PNG", "defaults.PNG", "defaults_icon.PNG", "defaults_icon.PNG"]
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
    private lazy var backupViewController: Settings_Backup_View_Controller = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "Settings_Backup_View_Controller") as! Settings_Backup_View_Controller
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    // MARK other view controllers initialked here for future context
    private lazy var defaultsViewController: Settings_Defaults_View_Controller = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "Settings_Default_View_Controller") as! Settings_Defaults_View_Controller
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    // MARK other view controllers initialked here for future context
    private lazy var legalViewController: Settings_Legal_View_Controller = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "Settings_Legal_View_Controller") as! Settings_Legal_View_Controller
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    // MARK other view controllers initialked here for future context
    private lazy var aboutViewController: Settings_About_View_Controller = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "Settings_About_View_Controller") as! Settings_About_View_Controller
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 75.0
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
        setupView()
    }
    
    // MARK: - View Methods
    
    private func setupView() {
        updateView()
    }
    
    private func updateView() {
        switch rowIndex{
        case 0:
            remove(asChildViewController: defaultsViewController)
            remove(asChildViewController: aboutViewController)
            remove(asChildViewController: legalViewController)
            add(asChildViewController: backupViewController)
        case 1:
            remove(asChildViewController: backupViewController)
            remove(asChildViewController: aboutViewController)
            remove(asChildViewController: legalViewController)
            add(asChildViewController: defaultsViewController)
        case 2:
            remove(asChildViewController: backupViewController)
            remove(asChildViewController: aboutViewController)
            remove(asChildViewController: defaultsViewController)
            add(asChildViewController: legalViewController)
        case 3:
            remove(asChildViewController: legalViewController)
            remove(asChildViewController: backupViewController)
            remove(asChildViewController: defaultsViewController)
            add(asChildViewController: aboutViewController)
        default:
            remove(asChildViewController: aboutViewController)
            remove(asChildViewController: defaultsViewController)
            remove(asChildViewController: legalViewController)
            add(asChildViewController: backupViewController)
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
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settingsName.count
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(indexPath.row == 0)
        {
            let rowToSelect:NSIndexPath = NSIndexPath(row: 0, section: 0)
            
            tableView.selectRow(at: rowToSelect as IndexPath, animated: true, scrollPosition: UITableView.ScrollPosition.none)
            
        }
    }
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:customSettingCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! customSettingCell
        
        let image = UIImage(named: self.imageNames[indexPath.row])
        
        cell.settingsLabel!.text = self.settingsName[indexPath.row]
        cell.settingsImageView?.image = image
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rowIndex = indexPath.row
        print("You tapped cell number \(indexPath.row).")
        self.setupView()
    }
}
