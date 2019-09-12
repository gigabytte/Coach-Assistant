//
//  Marker_Info_Page.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-01-17.
//  Copyright © 2019 MAG Industries. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class Marker_Info_Page: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBAction func unwindToMarkerInfo(segue: UIStoryboardSegue) {}
    
    // connection refrence to shot goal picker view
    @IBOutlet weak var shot_goalPickerView: UIPickerView!
    @IBOutlet weak var assitantsPickerView: UIPickerView!
    @IBOutlet weak var goalTypePickerView: UIPickerView!
    @IBOutlet weak var forwardLinePicker: UIPickerView!
    @IBOutlet weak var defenseLinePicker: UIPickerView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var powerPlayToggleSwitch: UISwitch!
    
    var homeTeam: Int = UserDefaults.standard.integer(forKey: "homeTeam")
    var awayTeam:Int = UserDefaults.standard.integer(forKey: "awayTeam")
    var currentGameID: Int = UserDefaults.standard.integer(forKey: "gameID")
    var scoringPassedTeamID: Int!
    var opposingTeamID: Int!
    var periodNumSelected: Int = UserDefaults.standard.integer(forKey: "periodNumber")
    
    let realm = try! Realm()
    
    // vars for team data retrieval from Realm
    var TeamPickerData: [String] = [String]()
    var selectedTeam: String = ""
    
    //vars for shot type
    var goalTypePickerData: [String] = [String]()
    var selectedGoalType: String = ""
    
    // vars for player data retrieval from Realm
    var mainPlayerPickerData: [String] = [String]()
    var tempHomeMainIDArray: [Int] = [Int]()
    var selectedMainPlayer: String = ""
    var selectedMainPlayerID: Int!
    
    // vars in relation to assiant player picking
    var assitPlayerPickerData: [[String]] = [[String]]()
    var temp_assitPlayerID: [[Int]] = [[Int]]()
    var selectedAssitantPlayerOne: String = ""
    var selectedAssitantPlayerTwo: String = ""
    var selectedAssitantPlayerOneID: Int!
    var selectedAssitantPlayerTwoID: Int!
    
    // vars in relation to assiant player picking
    var forwardLinePickerData: [[String]] = [[String]]()
    var defenseLinePickerData: [[String]] = [[String]]()
    var selectedForForwardLine: String = ""
    var selectedAgainstForwardLine: String = ""
    var selectedForDefenseLine: String = ""
    var selectedAgainstDefenseLine: String = ""
    
    var selectedPenaltyID: Int = 0
    
    // get X, Y cords from New_Game_Page View controller
    var xCords: Int = 0
    var yCords: Int = 0
    
    var shotLocationValue: Int!
    var goalieSelectedID: Int!
    var goal_primaryID: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set power play toggle to off by default
        powerPlayToggleSwitch.isOn = false
        // call team data from realm
        teamSelectedProcessing()
        navBarProcessing()
        lowDataWarning()
        // process goal type info on VC load
        goalTypeProcessing()
        //call main player data from realm
        mainPlayerRealmRetrieval()
        //call assitant player data from Realm
        assitantPlayerRealmRetrieval()
        // process line info data from Realm
        linePlayerRealmRetrieval()
        
        // Data Connections for picker views:
        self.shot_goalPickerView.delegate = self
        self.shot_goalPickerView.dataSource = self
        
        self.assitantsPickerView.delegate = self
        self.assitantsPickerView.dataSource = self
        
        self.goalTypePickerView.delegate = self
        self.goalTypePickerView.dataSource = self
        
        self.forwardLinePicker.delegate = self
        self.forwardLinePicker.dataSource = self
    
        
        self.defenseLinePicker.delegate = self
        self.defenseLinePicker.dataSource = self
        
        // set listener for notification after goalie is selected
        NotificationCenter.default.addObserver(self, selector: #selector(myCancelMethod(notification:)), name: NSNotification.Name(rawValue: "noPenaltyToggle"), object: nil)
        
    }
    
    func navBarProcessing() -> String {
        
        navBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.semibold)]
        
        if (String(homeTeam) != "" && String(awayTeam) != ""){
            let home_teamNameFilter = realm.object(ofType: teamInfoTable.self, forPrimaryKey: homeTeam)?.nameOfTeam
            let away_teamNameFilter = realm.object(ofType: teamInfoTable.self, forPrimaryKey: awayTeam)?.nameOfTeam
            if (scoringPassedTeamID == homeTeam){
                navBar.topItem!.title = home_teamNameFilter! + " Goal Info"
                return (home_teamNameFilter!)
            }else if (scoringPassedTeamID == awayTeam){
                navBar.topItem!.title = away_teamNameFilter! + " Goal Info"
                return (away_teamNameFilter!)
            }
        }else{
            print("Error Unable to Gather Team Name, Nav Bar Has Defualted")
            
        }
        return("Default Team")
        
    }
    
    func lowDataWarning(){
        delay(0.5){
            if (self.mainPlayerPickerData.count <= 1){
                let onePlayerAlert = UIAlertController(title: localizedString().localized(value: "Small Data Set Warning"), message: localizedString().localized(value: "For Maximum Analytical Support we recommend Adding more than one Player to ") + self.navBarProcessing(), preferredStyle: UIAlertController.Style.alert)
                // add Ok action (button)
                onePlayerAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
                self.present(onePlayerAlert, animated: true, completion: nil)
            }
        }
    }
    
    func teamSelectedProcessing() -> ([String]){
       
        // Get teams based on user slection form shot location view generating a goal
        scoringPassedTeamID = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", goalieSelectedID!)).value(forKeyPath: "TeamID") as! [String]).compactMap({Int($0)})).first
    
        if (scoringPassedTeamID == homeTeam){
            let teamName = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "teamID == %i AND activeState == true", goalieSelectedID)).value(forKeyPath: "nameOfTeam") as! [String]).compactMap({String($0)})
            scoringPassedTeamID = awayTeam
            opposingTeamID = homeTeam
            return(teamName)
        }else{
            let teamName = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "teamID == %i AND activeState == true", goalieSelectedID)).value(forKeyPath: "nameOfTeam") as! [String]).compactMap({String($0)})
            scoringPassedTeamID = homeTeam
            opposingTeamID = awayTeam
            return(teamName)
        }
    }
    
    func goalTypeProcessing(){
        // populate picker view with hardcodeddefault gola types
        goalTypePickerData = ["Regular Goal", "Breakaway", "Screen", "Tip", "Point Shot", "Scramble", "Slot"]
        selectedGoalType = goalTypePickerData[0]
        
    }
    
    func mainPlayerRealmRetrieval(){
        
        // Get main Home players on view controller load
        let mainPlayerNumFilter = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType != %@ AND activeState == true", String(scoringPassedTeamID), "G")).value(forKeyPath: "jerseyNum") as! [Int]).compactMap({String($0)})
        let mainPlayerNameFilter = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType != %@ AND activeState == true", String(scoringPassedTeamID), "G")).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)})
 
        for index in 0..<mainPlayerNameFilter.count {
            mainPlayerPickerData.append("\(mainPlayerNameFilter[index]) #\(mainPlayerNumFilter[index])")
        }

        // default value set
        selectedMainPlayer = mainPlayerNameFilter[0]
        tempHomeMainIDArray = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType != %@ AND activeState == true", String(scoringPassedTeamID), "G")).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        // get default goal score id
        selectedMainPlayerID = tempHomeMainIDArray[0]
    }
    
    func assitantPlayerRealmRetrieval(){
        
        // get assitant away players on view controller load
        let assitPlayerNameStrings = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType != %@ AND activeState == true", String(scoringPassedTeamID), "G")).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)})
        let assitPlayerNumStrings = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType != %@ AND activeState == true", String(scoringPassedTeamID), "G")).value(forKeyPath: "jerseyNum") as! [Int]).compactMap({String($0)})
        
        var temp_assitPlayerPickerData: [String] = [String]()
        
        for index in 0..<assitPlayerNameStrings.count {
            temp_assitPlayerPickerData.append("\(assitPlayerNameStrings[index]) #\(assitPlayerNumStrings[index])")
        }
        assitPlayerPickerData.insert(temp_assitPlayerPickerData, at: 0)
        assitPlayerPickerData.insert(temp_assitPlayerPickerData, at: 1)
        // default value set
        selectedAssitantPlayerOne = assitPlayerNameStrings[0]
        selectedAssitantPlayerTwo = assitPlayerNameStrings[0]
        
        temp_assitPlayerID.insert((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType != %@ AND activeState == true", String(scoringPassedTeamID), "G")).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)}), at: 0)
        temp_assitPlayerID.insert((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType != %@ AND activeState == true", String(scoringPassedTeamID), "G")).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)}), at: 1)
        // get default assitant players IDs
        selectedAssitantPlayerOneID = temp_assitPlayerID[0][0]
        selectedAssitantPlayerTwoID = temp_assitPlayerID[1][0]
    }
    
    func linePlayerRealmRetrieval(){
        
        forwardLinePickerData = [["1", "2", "3"], ["1", "2", "3"]]
        defenseLinePickerData = [["1", "2", "3"], ["1", "2", "3"]]
        // default value set
        selectedForForwardLine = forwardLinePickerData[0][0]
        selectedAgainstForwardLine = forwardLinePickerData[1][0]
        selectedForDefenseLine = defenseLinePickerData[0][0]
        selectedAgainstDefenseLine = defenseLinePickerData[1][0]
    
        
    }
    
    func savingErrorChecking(){
        if(mainPlayerPickerData.count <= 1){
            print("All Selections Passed the Test and are safe to be saved")
        }else{
            if(selectedMainPlayer == selectedAssitantPlayerOne || selectedMainPlayer == selectedAssitantPlayerTwo ){
                let doubleEntry = UIAlertController(title: localizedString().localized(value:"Double Selection"), message: localizedString().localized(value:"Please make sure you Goal scorer and your two Assitants are 3 diffrent players."), preferredStyle: UIAlertController.Style.alert)
                // add Ok action (button)
                doubleEntry.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
                self.present(doubleEntry, animated: true, completion: nil)
            }
        }
        
    }
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        let dictionary = ["key":"value"]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "shotLocationRefresh"), object: nil, userInfo: dictionary)
        performSegue(withIdentifier: "backToIceMarker", sender: nil)
        
    }
    
    @IBAction func saveMarkerDataButton(_ sender: UIBarButtonItem) {
        savingErrorChecking()
        // create the alert
        let saveButtonAlert = UIAlertController(title: localizedString().localized(value:"Back to Ice Surafce"), message: localizedString().localized(value:"Would you like this info to be saved?"), preferredStyle: UIAlertController.Style.alert)
        // add Cancel action (button)
        saveButtonAlert.addAction(UIAlertAction(title: localizedString().localized(value:"Cancel"), style: UIAlertAction.Style.cancel, handler: nil))
        // add Save action (button)
        // redirect to dashboard on button click
        saveButtonAlert.addAction(UIAlertAction(title: localizedString().localized(value:"Save"), style: UIAlertAction.Style.default, handler: {action in self.performSegue(withIdentifier: "saveMarkerSeague", sender: nil);
            // save marker data to realm
            try! self.realm.write{
                // check if it's a shot or goal and update appropriate table
                // if marker is a shot then run shot table update
                if (self.realm.objects(goalMarkersTable.self).max(ofProperty: "cordSetID") as Int? != nil){
                    self.goal_primaryID = (self.realm.objects(goalMarkersTable.self).max(ofProperty: "cordSetID") as Int? ?? 0) + 1;
                }else{
                    self.goal_primaryID = (self.realm.objects(goalMarkersTable.self).max(ofProperty: "cordSetID") as Int? ?? 0);
                }
                self.realm.create(goalMarkersTable.self, value: ["cordSetID": self.goal_primaryID!, "gameID": self.currentGameID]);
                let goalMarkerTableID = self.realm.object(ofType: goalMarkersTable.self, forPrimaryKey: self.goal_primaryID);
                let mainPlayerUpdateID = self.realm.object(ofType: playerInfoTable.self, forPrimaryKey: self.selectedMainPlayerID);
                let assitPlayerUpdateID = self.realm.object(ofType: playerInfoTable.self, forPrimaryKey: self.selectedAssitantPlayerOneID);
                let assitTwoPlayerUpdateID = self.realm.object(ofType: playerInfoTable.self, forPrimaryKey:
                    self.selectedAssitantPlayerTwoID);
                
                
                // update current stats table with plus minus for each player
                self.realm.object(ofType: overallStatsTable.self, forPrimaryKey: ((self.realm.objects(overallStatsTable.self).filter(NSPredicate(format: "gameID == %i AND playerID == %i AND activeState == true", self.currentGameID, self.selectedMainPlayerID)).value(forKeyPath: "overallStatsID") as! [Int]).compactMap({Int($0)})).first)?.plusMinus += 1
                self.realm.object(ofType: overallStatsTable.self, forPrimaryKey: ((self.realm.objects(overallStatsTable.self).filter(NSPredicate(format: "gameID == %i AND playerID == %i AND activeState == true", self.currentGameID, self.selectedAssitantPlayerOneID)).value(forKeyPath: "overallStatsID") as! [Int]).compactMap({Int($0)})).first)?.plusMinus += 1
                self.realm.object(ofType: overallStatsTable.self, forPrimaryKey: ((self.realm.objects(overallStatsTable.self).filter(NSPredicate(format: "gameID == %i AND playerID == %i AND activeState == true", self.currentGameID, self.selectedAssitantPlayerTwoID)).value(forKeyPath: "overallStatsID") as! [Int]).compactMap({Int($0)})).first )?.plusMinus += 1
                 // update current stats table with awared goal or assit for each player
                self.realm.object(ofType: overallStatsTable.self, forPrimaryKey: ((self.realm.objects(overallStatsTable.self).filter(NSPredicate(format: "gameID == %i AND playerID == %i AND activeState == true", self.currentGameID,  self.selectedMainPlayerID)).value(forKeyPath: "overallStatsID") as! [Int]).compactMap({Int($0)})).first)?.goalCount += 1
                self.realm.object(ofType: overallStatsTable.self, forPrimaryKey: ((self.realm.objects(overallStatsTable.self).filter(NSPredicate(format: "gameID == %i AND playerID == %i AND activeState == true", self.currentGameID, self.selectedAssitantPlayerOneID)).value(forKeyPath: "overallStatsID") as! [Int]).compactMap({Int($0)})).first )?.assistCount += 1
                self.realm.object(ofType: overallStatsTable.self, forPrimaryKey: ((self.realm.objects(overallStatsTable.self).filter(NSPredicate(format: "gameID == %i AND playerID == %i AND activeState == true", self.currentGameID, self.selectedAssitantPlayerTwoID)).value(forKeyPath: "overallStatsID") as! [Int]).compactMap({Int($0)})).first )?.assistCount += 1
                
                // update plus minus line stats for players on ice
                let forForwardLinePlayers = (self.realm.objects(playerInfoTable.self).filter(NSPredicate(format: "lineNum == %i  AND TeamID == %@ AND activeState == true", Int(self.selectedForForwardLine)!, String(self.scoringPassedTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
                for i in 0..<forForwardLinePlayers.count{
                   
                    switch forForwardLinePlayers[i]{
                        
                    case self.selectedMainPlayerID, self.selectedAssitantPlayerOneID, self.selectedAssitantPlayerTwoID:
                        print("Must be the same F")
                        break
                    default:
                        self.realm.object(ofType: overallStatsTable.self, forPrimaryKey: forForwardLinePlayers[i])?.plusMinus += 1
                        break
                        
                    }
                    
                }
                let forDefenseLinePlayers = (self.realm.objects(playerInfoTable.self).filter(NSPredicate(format: "lineNum == %i AND TeamID == %@ AND activeState == true", Int(self.selectedForDefenseLine)! + 3, String(self.scoringPassedTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
                print(forDefenseLinePlayers)
                for i in 0..<forDefenseLinePlayers.count{
                    
                    switch forDefenseLinePlayers[i]{
                    case self.selectedMainPlayerID, self.selectedAssitantPlayerOneID, self.selectedAssitantPlayerTwoID:
                        print("Must be the same D")
                        break
                    default:
                        self.realm.object(ofType: overallStatsTable.self, forPrimaryKey: ((self.realm.objects(overallStatsTable.self).filter(NSPredicate(format: "gameID == %i AND playerID == %i AND activeState == true", self.currentGameID, forDefenseLinePlayers[i])).value(forKeyPath: "overallStatsID") as! [Int]).compactMap({Int($0)})).first )?.plusMinus += 1
                        break
                        
                    }
                }
                
                let againstForwardLinePlayers = (self.realm.objects(playerInfoTable.self).filter(NSPredicate(format: "lineNum == %i AND TeamID == %@ AND activeState == true", Int(self.selectedAgainstForwardLine)!, String(self.opposingTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
                for i in 0..<againstForwardLinePlayers.count{
                    self.realm.object(ofType: overallStatsTable.self, forPrimaryKey: ((self.realm.objects(overallStatsTable.self).filter(NSPredicate(format: "gameID == %i AND playerID == %i AND activeState == true", self.currentGameID, againstForwardLinePlayers[i])).value(forKeyPath: "overallStatsID") as! [Int]).compactMap({Int($0)})).first )?.plusMinus -= 1
                }
                let againsDefenseLinePlayers = (self.realm.objects(playerInfoTable.self).filter(NSPredicate(format: "lineNum == %i AND TeamID == %@ AND activeState == true", Int(self.selectedAgainstDefenseLine)! + 3, String(self.opposingTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
                for i in 0..<againsDefenseLinePlayers.count{
                    self.realm.object(ofType: overallStatsTable.self, forPrimaryKey: ((self.realm.objects(overallStatsTable.self).filter(NSPredicate(format: "gameID == %i AND playerID == %i AND activeState == true", self.currentGameID, againsDefenseLinePlayers[i])).value(forKeyPath: "overallStatsID") as! [Int]).compactMap({Int($0)})).first )?.plusMinus -= 1
                }
                
                print("Penaty id \(self.selectedPenaltyID)")
                
                if (self.powerPlayToggleSwitch.isOn == true){
                    goalMarkerTableID?.powerPlay = true
                    goalMarkerTableID?.powerPlayID = self.selectedPenaltyID
                }else{
                    goalMarkerTableID?.powerPlay = false
                    goalMarkerTableID?.powerPlayID = 0
                }
                goalMarkerTableID?.activeState = true
                goalMarkerTableID?.goalType = self.selectedGoalType
                goalMarkerTableID?.goalieID = self.goalieSelectedID
                goalMarkerTableID?.xCordGoal = self.xCords
                goalMarkerTableID?.yCordGoal = self.yCords
                goalMarkerTableID?.periodNum = self.periodNumSelected
                goalMarkerTableID?.shotLocation = self.shotLocationValue
                goalMarkerTableID?.TeamID = self.scoringPassedTeamID
                goalMarkerTableID?.goalPlayerID = self.selectedMainPlayerID!
                goalMarkerTableID?.assitantPlayerID = self.selectedAssitantPlayerOneID!
                goalMarkerTableID?.sec_assitantPlayerID = self.selectedAssitantPlayerTwoID!
                mainPlayerUpdateID?.goalCount += 1
                assitPlayerUpdateID?.assitsCount += 1
                assitTwoPlayerUpdateID?.assitsCount += 1
            }
            let dictionary = ["key":"value"]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "shotLocationRefresh"), object: nil, userInfo: dictionary)
            self.performSegue(withIdentifier: "backToIceMarker", sender: nil)
        }))
        // show the alert
        self.present(saveButtonAlert, animated: true, completion: nil)
        
        
        
    }

    @IBAction func powerPlayToggle(_ sender: Any) {
        if powerPlayToggleSwitch.isOn == true{
           // self.performSegue(withIdentifier: "PenaltyInfoPopUp", sender: nil)
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let popupVC = storyboard.instantiateViewController(withIdentifier: "Penalty_Popup_Info_VC") as! Penalty_Info_View_Controller
            
            popupVC.modalPresentationStyle = .overCurrentContext
            popupVC.modalTransitionStyle = .crossDissolve
            let pVC = popupVC.popoverPresentationController
            pVC?.permittedArrowDirections = .any
            pVC?.delegate = self as! UIPopoverPresentationControllerDelegate
            
             popupVC.againstTeamID = opposingTeamID
            
            present(popupVC, animated: true, completion: nil)
            print("Penalty Info VC Presented!")
        }
        
    }
    
    @objc func myCancelMethod(notification: NSNotification){
        // toggle off power play switch if marker info page is notified that user has cancelled request
        powerPlayToggleSwitch.isOn = false
        
    }

//----------------------------------------------------------------------------------------------------------
    // Picker View Functions for Main Player and Assitant Picking
    // Number of columns of data
    func numberOfComponents(in numberOfComponents: UIPickerView) -> Int  {
        
        if (numberOfComponents == forwardLinePicker || numberOfComponents == defenseLinePicker || numberOfComponents == assitantsPickerView ){
            
            return 2;
        }else{
            
            return 1;
        }
    }
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == goalTypePickerView){
            
            return goalTypePickerData.count;
            
        }else if (pickerView == shot_goalPickerView){
                return mainPlayerPickerData.count;
        }else if (pickerView == assitantsPickerView){
            return assitPlayerPickerData[component].count;
        }else if(component == 0){
            return forwardLinePickerData[0].count;
        }else{
            return forwardLinePickerData[1].count;
        }
    }
  func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var attributedString: NSAttributedString!
    if (pickerView == forwardLinePicker || pickerView == defenseLinePicker){
            switch component {
            case 0:
                let attributedString = NSAttributedString(string: forwardLinePickerData[0][row], attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
                return attributedString
            case 1:
                let attributedString = NSAttributedString(string: forwardLinePickerData[1][row], attributes: [NSAttributedString.Key.foregroundColor : UIColor.red])
                return attributedString
            default:
                attributedString = nil
            }
        }
        return attributedString
    }

    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if (pickerView == goalTypePickerView){
            
            return goalTypePickerData[row];
            
        }else if (pickerView == shot_goalPickerView){
            return mainPlayerPickerData[row];
        }else if (pickerView == assitantsPickerView){
            if(component == 0){
                return assitPlayerPickerData[0][row];
            }else{
                 return assitPlayerPickerData[1][row];
            }
            // return number of players associated with said team picked
        }else if(component == 0){
            return forwardLinePickerData[0][row];
        }else{
                return forwardLinePickerData[1][row];
            }
        }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        if (pickerView == goalTypePickerView){
            selectedGoalType = goalTypePickerData[row]
            
        }else if (pickerView == shot_goalPickerView){
            selectedMainPlayer = mainPlayerPickerData[row]
            selectedMainPlayerID = tempHomeMainIDArray[row]
            
        }else if (pickerView == assitantsPickerView){
            // check if selected team is == to the home team oulled from realm
            if(component == 0){
                 selectedAssitantPlayerOne = assitPlayerPickerData[0][row]
                selectedAssitantPlayerOneID = temp_assitPlayerID[0][row]
            }else{
                selectedAssitantPlayerTwo = assitPlayerPickerData[1][row]
                selectedAssitantPlayerTwoID = temp_assitPlayerID[1][row]
            }
        } else if pickerView == forwardLinePicker{
            if(component == 0){
                selectedForForwardLine = forwardLinePickerData[0][row]
                
            }else{
                selectedAgainstForwardLine = forwardLinePickerData[1][row]
                
            }
        }else{
            if(component == 0){
                selectedForDefenseLine = defenseLinePickerData[0][row]
                print("for defendive line \(selectedForDefenseLine)")
            }else{
                selectedAgainstDefenseLine = defenseLinePickerData[1][row]
                print("against defendive line \(selectedAgainstDefenseLine)")
            }
        }
    }
//______________________________________________________________________________________________________________

    // delay loop
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
}
