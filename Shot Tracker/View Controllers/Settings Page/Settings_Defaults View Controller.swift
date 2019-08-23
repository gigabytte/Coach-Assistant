//
//  Settings_Defaults View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-19.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

final class Settings_Defaults_View_Controller: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet var defaultsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(myMethod(notification:)), name: NSNotification.Name(rawValue: "darModeToggle"), object: nil)
        viewColour()
        
    }

    func viewColour(){
        
        self.tableView.backgroundColor = systemColour().tableViewColor()
    }
    
    @objc func myMethod(notification: NSNotification){
        viewColour()
    }
    
    func noTeamAlert(){
        
        // create the alert
        let noTeamsAlert = UIAlertController(title: localizedString().localized(value:"Data Error"), message: localizedString().localized(value:"Please add atleast one team before attempting to change your default team."), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        noTeamsAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(noTeamsAlert, animated: true, completion: nil)
    }
    
    func openDefaultTeam(){
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let popupVC = storyboard.instantiateViewController(withIdentifier: "Settings_Default_Team") as! Settings_Defaults_Team_Defaults
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = .crossDissolve
        let pVC = popupVC.popoverPresentationController
        pVC?.permittedArrowDirections = .any
        pVC?.delegate = self
        
        present(popupVC, animated: true, completion: nil)
        print("Defaul Team Presented!")
        
    }
    
    func openDefaultPenalty(){
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let popupVC = storyboard.instantiateViewController(withIdentifier: "Settings_Default_Penalty") as! Settings_Defaults_Penalty_Defaults
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = .crossDissolve
        let pVC = popupVC.popoverPresentationController
        pVC?.permittedArrowDirections = .any
        pVC?.delegate = self
        
        present(popupVC, animated: true, completion: nil)
        print("Default Penalty Presented!")
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        switch indexPath.row {
        case 0:
            //openDefaultTeam()
            break
        case 1:
            //openDefaultPenalty()
            break
        default:
            print("Fatal Error opening sub settiung menu")
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}
