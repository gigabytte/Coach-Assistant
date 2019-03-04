//
//  Edit_Team_Info_Page.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-01-29.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class Edit_Team_Info_Page: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var teamPicker: UIPickerView!
    @IBOutlet weak var playersPicker: UIPickerView!
    @IBOutlet weak var linePicker: UIPickerView!
    @IBOutlet weak var positionPicker: UIPickerView!
    @IBOutlet weak var newTeamName: UITextField!
    
    var selectTeamKey:Int = 0
    var homeTeam: Int?
    
    //variables for player data retrival from realm
    var playersPickerData: [String] = [String]()
    var tempPlayerIDArray:[String] = [String]()
    var selectedPlayerName: String = ""
    var selectedPlayerID: Int = 0
    
    //team data retrival from realm
    var teamPickerData:Results<teamInfoTable>!
    var teamPickerSelect:[teamInfoTable] = []
    
    var selectTeam: String = ""
    var selectPosition:String = ""
    var selectLine:Int = 0
    
    var pickerData:[String] = [String]()
    var positionData:[String] = [String]()
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerTeamRetervial()
        
        self.teamPicker.delegate = self
        self.teamPicker.dataSource = self
        
        self.playersPicker.delegate = self
        self.playersPicker.dataSource = self
        
        self.linePicker.delegate = self
        self.linePicker.dataSource = self
        
        self.positionPicker.delegate = self
        self.positionPicker.dataSource = self
        
        self.teamPickerData = realm.objects(teamInfoTable.self)
        self.teamPickerSelect = Array(self.teamPickerData)
        
        pickerData = ["Forward 1","Forward 2","Forward 3","Defence 1","Defence 2","Defence 3", "Goalie"]
        positionData = ["Left Wing", "Center", "Right Wing", "Left Defence", "Right Defence", "Goalie"]
        // MUST SET ON EACH VIEW DEPENDENT ON ORIENTATION NEEDS
        // get rotation allowances of device
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // set auto rotation to false
        appDelegate.shouldRotate = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView == teamPicker){
            return teamPickerData.count
        }else if(pickerView == linePicker){
            return pickerData.count
        }else if(pickerView == positionPicker){
            return positionData.count
        }else{
            return playersPickerData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView == teamPicker){
            return teamPickerSelect[row].nameOfTeam
        }else if(pickerView == linePicker){
            return pickerData[row]
        }else if(pickerView == positionPicker){
            return positionData[row]
        }else{
            return playersPickerData[row];
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView == teamPicker){
            selectTeam = teamPickerSelect[row].nameOfTeam
            homeTeam = teamPickerSelect[row].teamID
        }else if(pickerView == linePicker){
            if(pickerData[row] == "Forward 1"){
                selectLine = 1
            }else if(pickerData[row] == "Forward 2"){
                selectLine = 2
            }else if(pickerData[row] == "Forward 3"){
                selectLine = 3
            }else if(pickerData[row] == "Defence 1"){
                selectLine = 4
            }else if(pickerData[row] == "Defence 2"){
                selectLine = 5
            }else if(pickerData[row] == "Defence 3"){
                selectLine = 6
            }else{
                selectLine = 7
            }
        }else if(pickerView == positionPicker){
            selectPosition = positionData[row]
        }else{
            selectedPlayerName = playersPickerData[row]
            selectedPlayerID = Int(tempPlayerIDArray[0])!
        }
    }
    
    @IBAction func newTeamName(_ sender: Any) {
        //let team: String = selectTeam
        let teamID = homeTeam
        let newName = newTeamName.text!
        let newTeam = teamInfoTable()
        
        if (newName != ""){
            newTeam.teamID = teamID!
            newTeam.nameOfTeam = newName
            
            try! realm.write{
                realm.add(newTeam, update: true)
                succesfulTeamAdd()
                
            }
        }else{
            missingFieldAlert()
        }
    }
    
    func teamNameRealmRetrieval(){
        // Get teams based on user slection form the team selection view
        let newestPrimaryID = realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?
        let newGameFilter = realm.object(ofType: newGameTable.self, forPrimaryKey: newestPrimaryID);
        homeTeam = newGameFilter?.homeTeamID
        let homeTeamString = realm.object(ofType: teamInfoTable.self, forPrimaryKey: homeTeam);
        // add home and away teams selected to TeamPickerData array
        //TeamPickerData.append(homeTeamString!.nameOfTeam)
        //tempTeamIDArray.append(realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)!.homeTeamID)
        
        //selectedTeam = homeTeamString!.nameOfTeam
        //selectedTeamID = tempTeamIDArray[0]
        //print("Team's Puilled From Realm: ", TeamPickerData)
    }
    
    func playerTeamRetervial(){
        
        let playerFilter = NSPredicate(format: "TeamID == %@", String(homeTeam!))
        let playerStrings = realm.objects(playerInfoTable.self).filter(playerFilter)
        let playerTeamName =  playerStrings.value(forKeyPath: "playerName")as! [String]
        playersPickerData = playerTeamName.compactMap({String($0)})
        selectedPlayerName = playersPickerData[0]
        
        let playerFilterID = NSPredicate(format: "TeamID == %@ AND playerName == %@", String(homeTeam!))
        let playerID = realm.objects(playerInfoTable.self).filter(playerFilterID)
        let playerTeamID = playerID.value(forKeyPath: "playerID") as! [Int]
        tempPlayerIDArray = playerTeamID.compactMap({String($0)})
        selectedPlayerID = Int(tempPlayerIDArray[0])!
    }
    @IBAction func newerTeamName(_ sender: Any) {
        let team: String = selectTeam
        let teamID = selectTeamKey
        let newName = newTeamName.text!
        let newTeam = teamInfoTable()
        
        if (newName != ""){
            newTeam.teamID = teamID
            newTeam.nameOfTeam = newName
            
            try! realm.write{
                realm.add(newTeam, update: true)
                succesfulTeamAdd()
                
            }
        }else{
            missingFieldAlert()
        }
    }
    func succesfulTeamAdd(){
        
        let successfulQuery = UIAlertController(title: "Team changed Successfully", message: "", preferredStyle: UIAlertController.Style.alert)
        successfulQuery.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(successfulQuery, animated: true, completion: nil)
    }
    func missingFieldAlert(){
        
        // create the alert
        let missingField = UIAlertController(title: "Missing Field Error", message: "Please have Team Name filled out before attemtping to change a new team.", preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        missingField.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(missingField, animated: true, completion: nil)
    }
}
