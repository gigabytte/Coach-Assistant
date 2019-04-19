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
    let animals: [String] = ["Backup", "Defaults", "Legal"]
    
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
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // (optional) include this line if you want to remove the extra empty cell divider lines
        // self.tableView.tableFooterView = UIView()
        
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
            add(asChildViewController: backupViewController)
        case 1:
            remove(asChildViewController: backupViewController)
            add(asChildViewController: defaultsViewController)
        default:
            remove(asChildViewController: backupViewController)
            add(asChildViewController: defaultsViewController)
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
        return self.animals.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        // set the text from the data model
        cell.textLabel?.text = self.animals[indexPath.row]
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        rowIndex = indexPath.row
        setupView()
    }

   
}
