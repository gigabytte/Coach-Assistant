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

    //Creates variables for coneceting to the realm database and for the team's ID Number
    let realm = try! Realm()
    var primaryTeamID: Int!
    var noTeamsBool: Bool!
    
    //Connections to the page
    @IBOutlet weak var teamName: UITextField!
    @IBOutlet weak var inActiveTeamToggle: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        if((UserDefaults.standard.object(forKey: "defaultHomeTeamID")) == nil){
            delay(0.5){
                
                // create the alert
                let noTeams = UIAlertController(title: "New to the App?", message: "Please add at least one team before adding a default team or import a team from settings.", preferredStyle: UIAlertController.Style.alert)
                // add an action (button)
                noTeams.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                // add an action (button)
                noTeams.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.destructive,  handler: {action in
                    self.performSegue(withIdentifier: "noTeamSettingsSegue", sender: nil);
                }))
                // show the alert
                self.present(noTeams, animated: true, completion: nil)
            }
        }

    }

    @IBAction func addPlayerButton(_ sender: UIButton) {
     
        if (realm.objects(teamInfoTable.self).max(ofProperty: "teamID") as Int? != nil){
            self.performSegue(withIdentifier: "addPlayerSegue", sender: nil);
        }else{
            noTeamAlert()
        }
        
    }
    //Func for when the add button is clicked
    @IBAction func saveteamName(_ sender: UIButton){
        //Takes user's input and stores it in the userinput variable
        let userInputTeam: String = teamName.text!
        
        //Checks to see if the database table has an entry in it or not. If not
        //adds the first entry with team ID equal to zero. If there are entries, it
        //finds the one with the higest ID number and then add one.
        if (realm.objects(teamInfoTable.self).max(ofProperty: "teamID") as Int? != nil){
            primaryTeamID = (realm.objects(teamInfoTable.self).max(ofProperty: "teamID")as Int? ?? 0) + 1
        }else{
            primaryTeamID = (realm.objects(teamInfoTable.self).max(ofProperty: "teamID")as Int? ?? 0)
        }
        
        let newTeam = teamInfoTable()
        
        //Checks to see if the text box object is not blank and if the toggle switch is
        //not on then adds the primary team ID and the team name to the new team entry.
        if (userInputTeam != "" && inActiveTeamToggle.isOn != true){
            newTeam.teamID = primaryTeamID
            newTeam.nameOfTeam = userInputTeam
        
            //writes new team information to database, resets the textbox view and outputs
            //a notification of success
            try! realm.write{
                realm.add(newTeam, update:true)
                teamName.text = ""
                succesfulTeamAdd(teamName: userInputTeam)
            }
        //Checks to see if the text box object is not blank and if the toggle switch is
        //on then adds the primary team ID and the team name to the new team entry.
        }else if(userInputTeam != "" && inActiveTeamToggle.isOn == true){
                newTeam.teamID = primaryTeamID
                newTeam.nameOfTeam = userInputTeam
                newTeam.activeState = false
            
            //writes new team information to database, resets the textbox view and outputs
            //a notification of success
            try! realm.write{
                realm.add(newTeam, update:true)
                teamName.text = ""
                succesfulTeamAdd(teamName: userInputTeam)
            }
        }else{
            //If team name text box is empty it calls an alert
            missingFieldAlert()
        }
    }
    
    //func for succesful team add alert
    func succesfulTeamAdd(teamName: String){
        
        // creating a variable to hold alert controller with attached message and also the style of the alert controller
        let successfulQuery = UIAlertController(title: "Team \(teamName) was Added Successfully", message: "", preferredStyle: UIAlertController.Style.alert)
        //adds action button to alert
        successfulQuery.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        
        //show the alert
        self.present(successfulQuery, animated: true, completion: nil)
    }
    //function for missing field alert
    func missingFieldAlert(){
            
        // create the alert
        let missingField = UIAlertController(title: "Missing Field Error", message: "Please have Team Name filled out before attemtping to add a new team.", preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        missingField.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(missingField, animated: true, completion: nil)
    }
    //function for missing field alert
    func noTeamAlert(){
        
        // create the alert
        let noTeamAlert = UIAlertController(title: "Whoops!", message: "Please add a team before attempting to add players.", preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        noTeamAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(noTeamAlert, animated: true, completion: nil)
    }

    // delay loop
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
}
