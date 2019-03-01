//
//  Add_Team_Page.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-02-14.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class Add_Team_Page: UIViewController {

    let realm = try! Realm()
    var primaryTeamID: Int!
    
    @IBOutlet weak var teamName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func saveteamName(_ sender: Any){
        let team: String = teamName.text!
        if (realm.objects(teamInfoTable.self).max(ofProperty: "teamID") as Int? != nil){
            primaryTeamID = (realm.objects(teamInfoTable.self).max(ofProperty: "teamID")as Int? ?? 0) + 1
        }else{
            primaryTeamID = (realm.objects(teamInfoTable.self).max(ofProperty: "teamID")as Int? ?? 0)
        }
        let newTeam = teamInfoTable()
        
        if (team != ""){
            newTeam.teamID = primaryTeamID
            newTeam.nameOfTeam = team
        
            try! realm.write{
                realm.add(newTeam, update:true)
                
                teamName.text = ""
                succesfulTeamAdd()
            }
        }else{
            missingFieldAlert()
        }
    }
    func succesfulTeamAdd(){
        
        let successfulQuery = UIAlertController(title: "Team Added Successfully", message: "", preferredStyle: UIAlertController.Style.alert)
        successfulQuery.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(successfulQuery, animated: true, completion: nil)
    }
        func missingFieldAlert(){
            
            // create the alert
            let missingField = UIAlertController(title: "Missing Field Error", message: "Please have Team Name filled out before attemtping to add a new team.", preferredStyle: UIAlertController.Style.alert)
            // add an action (button)
            missingField.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            // show the alert
            self.present(missingField, animated: true, completion: nil)
    }
}
