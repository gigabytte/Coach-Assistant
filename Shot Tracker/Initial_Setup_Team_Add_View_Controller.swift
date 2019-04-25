//
//  Initial_Setup_Team_Add_View_Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-22.
//  Copyright © 2019 Greg Brooks. All rights reserved.
// View controller will be presented urrin inital setup
// View controller is responsible for adding teams and players to the app

import UIKit
import RealmSwift
import Realm

class Initial_Setup_Team_Add_View_Controller: UIViewController {
    
    //Creates variables for coneceting to the realm database and for the team's ID Number
    let realm = try! Realm()
    var primaryTeamID: Int!
    var primaryPlayerID: Int!
    var noTeamsBool: Bool!
    
    //Connections to the page
    
    @IBOutlet weak var viewControllerLabelTitle: UILabel!
    @IBOutlet weak var addTeamButton: UIButton!
    @IBOutlet weak var teamName: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    //Func for when the add button is clicked
    @IBAction func saveteamName(_ sender: UIButton){
        //Takes user's input and stores it in the userinput variable
        let userInputTeam: String = teamName.text!
        
        // if team name adding functionlity is added
        if (addTeamButton.titleLabel?.text == "Add Team"){
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
            switch userInputTeam {
            case "":
                missingFieldAlert(missingType: "Team")
            default:
                try! realm.write{
                    newTeam.teamID = primaryTeamID
                    newTeam.nameOfTeam = teamName.text!
                    realm.add(newTeam, update:true)
                    teamAddCheck()
                }
            }
            // add team as default team
            UserDefaults.standard.set(primaryTeamID, forKey: "defaultHomeTeamID")
        }else{
            // if player functionality is introduced
            if (realm.objects(playerInfoTable.self).max(ofProperty: "playerID") as Int? != nil){
                primaryPlayerID = (realm.objects(playerInfoTable.self).max(ofProperty: "playerID")as Int? ?? 0) + 1
            }else{
                primaryPlayerID = (realm.objects(playerInfoTable.self).max(ofProperty: "playerID")as Int? ?? 0)
            }
            
            let newplayer = playerInfoTable()
            
            //Checks to see if the text box object is not blank and if the toggle switch is
            //not on then adds the primary team ID and the team name to the new team entry.
            switch userInputTeam {
            case "":
                missingFieldAlert(missingType: "Player")
            default:
                try! realm.write{
                    newplayer.playerID = primaryTeamID
                    newplayer.playerName = teamName.text!
                    realm.add(newplayer, update:true)
                }
            }
        }
       
    }
    
    //func for succesful team add alert
    func succesfulTeamAdd(teamName: String){
        
        // creating a variable to hold alert controller with attached message and also the style of the alert controller
        let successfulQuery = UIAlertController(title: "Success!", message: "Team \(teamName) was Added Successfully", preferredStyle: UIAlertController.Style.alert)
        //adds action button to alert
        successfulQuery.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        
        //show the alert
        self.present(successfulQuery, animated: true, completion: nil)
    }
    
    // function checks if user as addedteam to app properly
    func teamAddCheck(){
        let teamCheck = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "teamID >= %i AND activeState == %@", 0, NSNumber(value: true))).value(forKeyPath: "teamID") as! [Int]).compactMap({Int($0)})
        // check if team has been added to realm
        if (teamCheck.last != nil){
            viewControllerLabelTitle.text = "Add Player"
            addTeamButton.setTitle("Add Player", for: .normal)
            teamName.placeholder = "Player Name ..."
            teamName.text = ""
            print("Team is present in App, proceed to player adding functionlity.")
           
            
        }
        
    }
    
    //function for missing field alert
    func missingFieldAlert(missingType: String){
        
        // create the alert
        let missingField = UIAlertController(title: "Missing Field Error", message: "Please have \(missingType) Name filled out before attemtping to add a new \(missingType).", preferredStyle: UIAlertController.Style.alert)
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

