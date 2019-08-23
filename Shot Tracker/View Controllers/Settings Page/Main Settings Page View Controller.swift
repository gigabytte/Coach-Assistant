//
//  Main Settings Page View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-19.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

final class Main_Settings_Page_View_Controller: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate{
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var apperanceConatiner: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backupContainer: UIView!
    @IBOutlet weak var defaultConatiner: UIView!
    @IBOutlet weak var subConatiner: UIView!
    @IBOutlet weak var legalConatiner: UIView!
    @IBOutlet weak var aboutContainer: UIView!
    @IBAction func unwindBackToMainSettings(segue: UIStoryboardSegue) {}
    
    var rowIndex: Int!
    
    
    // Data model: These strings will be the data for the table view cells
    let settingsName: [String] = [localizedString().localized(value:"Backup"), localizedString().localized(value:"Defaults"), localizedString().localized(value:"Apperance"),localizedString().localized(value:"Subscriptions"), localizedString().localized(value:"Legal"), localizedString().localized(value:"About")]
    lazy var imageNames: [String] = ["backup.PNG", "defaults.PNG", "apperance_icon", "sub_icon","legal_icon", "about_icon", ""]
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder() // To get shake gesture
        
        NotificationCenter.default.addObserver(self, selector: #selector(myMethod(notification:)), name: NSNotification.Name(rawValue: "darModeToggle"), object: nil)
        
        self.tableView.rowHeight = 75.0
        tableView.tableFooterView = UIView()
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
        rowIndex = 0
        updateView()
        viewColour()
        
    }
    
    func viewColour(){
        
        tableView.backgroundColor = systemColour().tableViewColor()
        backButton.tintColor = systemColour().navBarButton()
        
    }
    @objc func myMethod(notification: NSNotification){
        viewColour()
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
    
    // MARK: - View Methods
    
    @IBAction func backButton(_ sender: Any) {
        imageNames = []
        backupContainer.removeFromSuperview()
        defaultConatiner.removeFromSuperview()
        subConatiner.removeFromSuperview()
        legalConatiner.removeFromSuperview()
        aboutContainer.removeFromSuperview()
        
        let dictionary = ["key":"value"]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "homePageRefresh"), object: nil, userInfo: dictionary)
        //self.performSegue(withIdentifier: "backtoHome_Settings", sender: nil);
        
    }
    
    func updateView() {
        switch rowIndex{
        case 0:
            backupContainer.isHidden = false
            defaultConatiner.isHidden = true
            apperanceConatiner.isHidden = true
            subConatiner.isHidden = true
            legalConatiner.isHidden = true
            aboutContainer.isHidden = true
            
        case 1:
            backupContainer.isHidden = true
            defaultConatiner.isHidden = false
            apperanceConatiner.isHidden = true
            subConatiner.isHidden = true
            legalConatiner.isHidden = true
            aboutContainer.isHidden = true
            
        case 2:
            backupContainer.isHidden = true
            defaultConatiner.isHidden = true
            apperanceConatiner.isHidden = false
            subConatiner.isHidden = true
            legalConatiner.isHidden = true
            aboutContainer.isHidden = true
            
        case 3:
            backupContainer.isHidden = true
            defaultConatiner.isHidden = true
            apperanceConatiner.isHidden = true
            subConatiner.isHidden = false
            legalConatiner.isHidden = true
            aboutContainer.isHidden = true
           
        case 4:
            backupContainer.isHidden = true
            defaultConatiner.isHidden = true
            apperanceConatiner.isHidden = true
            subConatiner.isHidden = true
            legalConatiner.isHidden = false
            aboutContainer.isHidden = true
            
        case 5:
            backupContainer.isHidden = true
            defaultConatiner.isHidden = true
            apperanceConatiner.isHidden = true
            subConatiner.isHidden = true
            legalConatiner.isHidden = true
            aboutContainer.isHidden = false
            
        default:
            backupContainer.isHidden = false
            defaultConatiner.isHidden = true
            apperanceConatiner.isHidden = true
            subConatiner.isHidden = true
            legalConatiner.isHidden = true
            aboutContainer.isHidden = true
        }
    }
    // MARK: - Actions
    
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
        self.updateView()
    }
}
