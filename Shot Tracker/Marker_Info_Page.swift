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
    // connection refrence to shot goal picker view
    @IBOutlet weak var shot_goalPickerView: UIPickerView!
    @IBOutlet weak var assitantsPickerView: UIPickerView!
    @IBOutlet weak var goalTypePickerView: UIPickerView!
    @IBOutlet weak var linePickerView: UIPickerView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var powerPlayToggleSwitch: UISwitch!
    
    var homeTeam: Int?
    var awayTeam:Int?
    var scoringPassedTeamID: [Int] = [Int]()
    var opposingTeamID: Int!
    var periodNumSelected: Int!
    
    let realm = try! Realm()
    
    // vars for team data retrieval from Realm
    var TeamPickerData: [String] = [String]()
    var selectedTeam: String = ""
    var pickedTeamID: Int!
    var selectedTeamID: Int!
    var tempTeamIDArray: [Int] = [Int]()
    
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
    var linePickerData: [[String]] = [[String]]()
    var selectedForwardLine: String = ""
    var selectedDefenseLine: String = ""
    
    // get X, Y cords from New_Game_Page View controller
    var xCords: Int = 0
    var yCords: Int = 0
    
    var xCoordinate = goalMarkersTable();
    var yCoordinate = goalMarkersTable();
    var cordSetIDNum = goalMarkersTable();
    
    var markerType: Bool!
    var tempMarkerType: Bool!
    var periodSelectionNum: Int!
    var shotLocationValue: String!
    var goalieSelectedID: Int!
    var shot_primaryID: Int!
    var goal_primaryID: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        self.linePickerView.delegate = self
        self.linePickerView.dataSource = self
    
        // MUST SET ON EACH VIEW DEPENDENT ON ORIENTATION NEEDS
        // get rotation allowances of device
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // set auto rotation to false
        appDelegate.shouldRotate = true
        
    }
    
    func navBarProcessing() -> String {
        if (periodNumSelected != nil && homeTeam != nil && awayTeam != nil){
            let home_teamNameFilter = realm.object(ofType: teamInfoTable.self, forPrimaryKey: homeTeam)?.nameOfTeam
            let away_teamNameFilter = realm.object(ofType: teamInfoTable.self, forPrimaryKey: awayTeam)?.nameOfTeam
            if (scoringPassedTeamID[0] == homeTeam){
                navBar.topItem!.title = home_teamNameFilter! + " Goal"
                return (home_teamNameFilter!)
            }else if (scoringPassedTeamID[0] == awayTeam){
                navBar.topItem!.title = away_teamNameFilter! + " Goal"
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
                let onePlayerAlert = UIAlertController(title: "Small Data Set Warning", message: "For Maximum Analytical Support we recommend Adding more than one Player to " + self.navBarProcessing(), preferredStyle: UIAlertController.Style.alert)
                // add Ok action (button)
                onePlayerAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil))
                self.present(onePlayerAlert, animated: true, completion: nil)
            }
        }
    }
    
    func teamSelectedProcessing() -> ([String]){
       
        print("Goalie Selected ID: ", goalieSelectedID)
        // Get teams based on user slection form shot location view generating a goal
        scoringPassedTeamID = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", goalieSelectedID!)).value(forKeyPath: "TeamID") as! [String]).compactMap({Int($0)})
        print(scoringPassedTeamID)
        if (scoringPassedTeamID[0] == homeTeam){
            let teamName = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "teamID == %i AND activeState == true", goalieSelectedID)).value(forKeyPath: "nameOfTeam") as! [String]).compactMap({String($0)})
            scoringPassedTeamID[0] = awayTeam!
            opposingTeamID = homeTeam!
            return(teamName)
        }else{
            let teamName = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "teamID == %i AND activeState == true", goalieSelectedID)).value(forKeyPath: "nameOfTeam") as! [String]).compactMap({String($0)})
            scoringPassedTeamID[0] = homeTeam!
            opposingTeamID = awayTeam!
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
        let mainPlayerNumFilter = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType != %@ AND activeState == true", String(scoringPassedTeamID[0]), "G")).value(forKeyPath: "jerseyNum") as! [Int]).compactMap({String($0)})
        let mainPlayerNameFilter = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType != %@ AND activeState == true", String(scoringPassedTeamID[0]), "G")).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)})
 
        for index in 0..<mainPlayerNameFilter.count {
            mainPlayerPickerData.append("\(mainPlayerNameFilter[index]) \(mainPlayerNumFilter[index])")
        }
        print("Main Home Players Are: ", mainPlayerPickerData)

        // default value set
        selectedMainPlayer = mainPlayerNameFilter[0]
        tempHomeMainIDArray = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType != %@ AND activeState == true", String(scoringPassedTeamID[0]), "G")).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        // get default goal score id
        selectedMainPlayerID = tempHomeMainIDArray[0]
        print("Selected Main Player ID: ", tempHomeMainIDArray)
    }
    
    func assitantPlayerRealmRetrieval(){
        
        // get assitant away players on view controller load
        let assitPlayerNameStrings = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType != %@ AND activeState == true", String(scoringPassedTeamID[0]), "G")).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)})
        let assitPlayerNumStrings = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType != %@ AND activeState == true", String(scoringPassedTeamID[0]), "G")).value(forKeyPath: "jerseyNum") as! [Int]).compactMap({String($0)})
        
        var temp_assitPlayerPickerData: [String] = [String]()
        
        for index in 0..<assitPlayerNameStrings.count {
            temp_assitPlayerPickerData.append("\(assitPlayerNameStrings[index]) \(assitPlayerNumStrings[index])")
        }
        assitPlayerPickerData.insert(temp_assitPlayerPickerData, at: 0)
        assitPlayerPickerData.insert(temp_assitPlayerPickerData, at: 1)
        // default value set
        selectedAssitantPlayerOne = assitPlayerNameStrings[0]
        selectedAssitantPlayerTwo = assitPlayerNameStrings[0]
        
        temp_assitPlayerID.insert((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType != %@ AND activeState == true", String(scoringPassedTeamID[0]), "G")).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)}), at: 0)
        temp_assitPlayerID.insert((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType != %@ AND activeState == true", String(scoringPassedTeamID[0]), "G")).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)}), at: 1)
        // get default assitant players IDs
        selectedAssitantPlayerOneID = temp_assitPlayerID[0][0]
        selectedAssitantPlayerTwoID = temp_assitPlayerID[1][0]
        print("tempo assit player id", temp_assitPlayerID)
    }
    
    func linePlayerRealmRetrieval(){
        
        linePickerData = [["1", "2", "3"], ["1", "2", "3"]]
        // default value set
        selectedForwardLine = linePickerData[0][0]
        selectedDefenseLine = linePickerData[1][0]
        
    }
    
    // radio button action control
    @IBAction func radioButtonAction(_ sender: DLRadioButton) {
        // check the result of said selected button with the use of it's tag
        if (sender.tag == 1){
            print("Period 1 Selected")
            periodSelectionNum = 1
        }else if(sender.tag == 2){
            print("Period 2 Selected")
            periodSelectionNum = 2
        }else{
            print("Period 3 Selected")
            periodSelectionNum = 3
        }
    }
    
    func savingErrorChecking(){
        if(mainPlayerPickerData.count <= 1){
            print("All Selections Passed the Test and are safe to be saved")
        }else{
            if(selectedMainPlayer == selectedAssitantPlayerOne || selectedMainPlayer == selectedAssitantPlayerTwo ){
                let doubleEntry = UIAlertController(title: "Double Selection", message: "Please make sure you Goal scorer and your two Assitants are 3 diffrent players.", preferredStyle: UIAlertController.Style.alert)
                // add Ok action (button)
                doubleEntry.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil))
                self.present(doubleEntry, animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func saveMarkerDataButton(_ sender: UIBarButtonItem) {
        savingErrorChecking()
        // check if period was selected
         if (periodSelectionNum != nil){
            // create the alert
            let saveButtonAlert = UIAlertController(title: "Back to Dashboard", message: "Would you like to save this as a new game?", preferredStyle: UIAlertController.Style.alert)
            // add Cancel action (button)
            saveButtonAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            // add Save action (button)
            // redirect to dashboard on button click
            saveButtonAlert.addAction(UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: {action in self.performSegue(withIdentifier: "saveMarkerSeague", sender: nil); print("X Cord of Marker: ", self.xCords); print("Y Cord of Marker:", self.yCords);
                // save marker data to realm
                try! self.realm.write{
                    // check if it's a shot or goal and update appropriate table
                    // if marker is a shot then run shot table update
                    if (self.realm.objects(goalMarkersTable.self).max(ofProperty: "cordSetID") as Int? != nil){
                        self.goal_primaryID = (self.realm.objects(goalMarkersTable.self).max(ofProperty: "cordSetID") as Int? ?? 0) + 1;
                    }else{
                        self.goal_primaryID = (self.realm.objects(goalMarkersTable.self).max(ofProperty: "cordSetID") as Int? ?? 0);
                    }
                    let currentGameID = self.realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?
                    self.realm.create(goalMarkersTable.self, value: ["cordSetID": self.goal_primaryID!, "gameID": currentGameID!]);
                    let goalMarkerTableID = self.realm.object(ofType: goalMarkersTable.self, forPrimaryKey: self.goal_primaryID);
                    let mainPlayerUpdateID = self.realm.object(ofType: playerInfoTable.self, forPrimaryKey: self.selectedMainPlayerID);
                    let assitPlayerUpdateID = self.realm.object(ofType: playerInfoTable.self, forPrimaryKey: self.selectedAssitantPlayerOneID);
                    let assitTwoPlayerUpdateID = self.realm.object(ofType: playerInfoTable.self, forPrimaryKey:
                        self.selectedAssitantPlayerTwoID);
                    // calc plus minus of scoring lines based on user interaction with pickerviews
                    var mainPlayerSelectedLine = (self.realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND TeamID == %@ AND positionType != %@ AND activeState == true", Int(self.selectedMainPlayerID), String(self.scoringPassedTeamID[0]), "G")).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
                    print("main player seclected", mainPlayerSelectedLine)
                    var one_assitPlayerSelectedLine = (self.realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND TeamID == %@ AND positionType != %@ AND activeState == true", Int(self.selectedAssitantPlayerOneID), String(self.scoringPassedTeamID[0]), "G")).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
                    var two_assitPlayerSelectedLine = (self.realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND TeamID == %@ AND positionType != %@ AND activeState == true", Int(self.selectedAssitantPlayerTwoID), String(self.scoringPassedTeamID[0]), "G")).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
                    for i in 0..<mainPlayerSelectedLine.count{
                        self.realm.object(ofType: playerInfoTable.self, forPrimaryKey: mainPlayerSelectedLine[i])?.plusMinus += 1
                    }
                    for i in 0..<one_assitPlayerSelectedLine.count{
                        self.realm.object(ofType: playerInfoTable.self, forPrimaryKey: one_assitPlayerSelectedLine[i])?.plusMinus += 1
                    }
                    for i in 0..<two_assitPlayerSelectedLine.count{
                        self.realm.object(ofType: playerInfoTable.self, forPrimaryKey: two_assitPlayerSelectedLine[i])?.plusMinus += 1
                    }
                    // calc plus minus for opposing team on ice
                      if (self.mainPlayerPickerData.count > 1){
                        var againstForwardLine = (self.realm.objects(playerInfoTable.self).filter(NSPredicate(format: "lineNum == %i AND TeamID == %@ AND positionType != %@ AND activeState == true", Int(self.selectedForwardLine)!, String(self.opposingTeamID), "G")).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
                        var againstDefenseLine = (self.realm.objects(playerInfoTable.self).filter(NSPredicate(format: "lineNum == %i AND TeamID == %@ AND positionType != %@ AND activeState == true", Int(self.selectedDefenseLine)! + 3, String(self.opposingTeamID), "G")).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
                        for i in 0..<againstForwardLine.count{
                            self.realm.object(ofType: playerInfoTable.self, forPrimaryKey: againstForwardLine[i])?.plusMinus -= 1
                        }
                        for i in 0..<againstDefenseLine.count{
                            self.realm.object(ofType: playerInfoTable.self, forPrimaryKey: againstDefenseLine[i])?.plusMinus -= 1
                        }
                      }else{
                        var againstForwardLine = (self.realm.objects(playerInfoTable.self).filter(NSPredicate(format: "lineNum == %i AND TeamID == %@ AND positionType != %@ AND activeState == true", 1, String(self.opposingTeamID), "G")).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
                        self.realm.object(ofType: playerInfoTable.self, forPrimaryKey: againstForwardLine[0])?.plusMinus -= 1
                    }
                    if (self.powerPlayToggleSwitch.isOn){
                        goalMarkerTableID?.powerPlay = true
                    }else{
                        goalMarkerTableID?.powerPlay = false
                    }
                    goalMarkerTableID?.activeState = true
                    goalMarkerTableID?.goalType = self.selectedGoalType
                    goalMarkerTableID?.goalieID = self.goalieSelectedID
                    goalMarkerTableID?.xCordGoal = (self.xCords)
                    goalMarkerTableID?.yCordGoal = (self.yCords)
                    goalMarkerTableID?.periodNum = (self.periodSelectionNum)
                    goalMarkerTableID?.shotLocation = (Int(self.shotLocationValue)!)
                    goalMarkerTableID?.TeamID = (self.scoringPassedTeamID[0])
                    goalMarkerTableID?.goalPlayerID = (self.selectedMainPlayerID!)
                    print("realm sees main player id, ", self.selectedMainPlayerID!)
                    goalMarkerTableID?.assitantPlayerID = (self.selectedAssitantPlayerOneID!)
                    goalMarkerTableID?.sec_assitantPlayerID = (self.selectedAssitantPlayerTwoID!)
                    mainPlayerUpdateID?.goalCount += 1
                    assitPlayerUpdateID?.assitsCount += 1
                    assitTwoPlayerUpdateID?.assitsCount += 1
                }
            }))
            // show the alert
            self.present(saveButtonAlert, animated: true, completion: nil)
        }else{
            // display an alert if period option was not selected
            let incompleteAlert = UIAlertController(title: "Missing Field", message: "Please select a Period when this event occured", preferredStyle: UIAlertController.Style.alert)
            // add Ok action (button)
            incompleteAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(incompleteAlert, animated: true, completion: nil)
        }
    }
    
//----------------------------------------------------------------------------------------------------------
    // Picker View Functions for Main Player and Assitant Picking
    // Number of columns of data
    func numberOfComponents(in numberOfComponents: UIPickerView) -> Int  {
        
        if (numberOfComponents == linePickerView || numberOfComponents == assitantsPickerView ){
            
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
            return linePickerData[0].count;
        }else{
            return linePickerData[1].count;
        }
    }
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if (pickerView == goalTypePickerView){
            
            return goalTypePickerData[row];
            
        }else if (pickerView == shot_goalPickerView){
            return mainPlayerPickerData[row];
        }else if (pickerView == assitantsPickerView){
            return assitPlayerPickerData[component][row];
            // return number of players associated with said team picked
        }else if(component == 0){
            return linePickerData[0][row];
        }else{
                return linePickerData[1][row];
            }
        }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        if (pickerView == goalTypePickerView){
            selectedGoalType = goalTypePickerData[row]
            /*self.shot_goalPickerView.reloadAllComponents()
            self.assitantsPickerView.reloadAllComponents()
            print("Picker View Reload Happened")*/
        }else if (pickerView == shot_goalPickerView){
            selectedMainPlayer = mainPlayerPickerData[row]
            selectedMainPlayerID = tempHomeMainIDArray[row]
            print("Goal Scorer Selected" + selectedMainPlayer)
            print("Goal Scorer Selected ID", selectedMainPlayerID)
        }else if (pickerView == assitantsPickerView){
            // check if selected team is == to the home team oulled from realm
                selectedAssitantPlayerOne = assitPlayerPickerData[0][row]
                selectedAssitantPlayerTwo = assitPlayerPickerData[1][row]
                selectedAssitantPlayerOneID = temp_assitPlayerID[0][row]
                selectedAssitantPlayerTwoID = temp_assitPlayerID[1][row]
                print("Assitant Players Selected" + selectedAssitantPlayerOne + selectedAssitantPlayerTwo)
        } else{
            if(component == 0){
                return selectedForwardLine = linePickerData[0][row]
            }else{
                selectedDefenseLine = linePickerData[1][row]
            }
            print("Lines Selected: " + selectedForwardLine + selectedDefenseLine)
        }
    }
//______________________________________________________________________________________________________________

    // delay loop
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    // func used to pass varables on segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check is appropriate segue is being used
        if (segue.identifier == "saveMarkerSeague" || segue.identifier == "backToIceSurfaceSegue"){
            // set var vc as destination segue
            let markerInfoVC = segue.destination as! New_Game_Page
            markerInfoVC.homeTeam = homeTeam
            markerInfoVC.awayTeam = awayTeam
            markerInfoVC.newGameStarted = false
            markerInfoVC.periodNumSelected = periodNumSelected
            markerInfoVC.goalieSelectedID = goalieSelectedID

        }
    }
}
