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
    @IBOutlet weak var newPlayerName: UITextField!
    @IBOutlet weak var newPlayerNumber: UITextField!
    @IBOutlet weak var editPlayerButton: UIButton!
    
    var selectTeamKey:Int = 0
    var homeTeam: Int?
    var scoringPassedTeamID: [Int] = [Int]()
    
    //variables for player data retrival from realm
    var mainPlayerPickerData: [String] = [String]()
    var HomeMainIDArray: [String] = [String]()
    var selectedMainPlayer: String = ""
    var selectedMainPlayerID: Int!
    
    //team data retrival from realm
    var teamPickerData:Results<teamInfoTable>!
    var teamPickerSelect:[teamInfoTable] = []
    
    var selectTeam: String = ""
    var selectPosition:String = ""
    var selectLine:Int = 0
    
    var pickerData:[String] = [String]()
    var positionData:[String] = [String]()
    var positionCodeData:[String] = [String]()
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        scoringPassedTeamID.append(0)
        mainPlayerReterival()
        
        pickerData = ["Forward 1","Forward 2","Forward 3","Defence 1","Defence 2","Defence 3", "Goalie"]
        positionData = ["Left Wing", "Center", "Right Wing", "Left Defence", "Right Defence", "Goalie"]
        positionCodeData = ["LW", "C", "RW", "LD", "RD", "G"]
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
            return mainPlayerPickerData.count
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
            return mainPlayerPickerData[row];
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView == teamPicker){
            selectTeam = teamPickerSelect[row].nameOfTeam
            scoringPassedTeamID[0] = teamPickerSelect[row].teamID
            mainPlayerReterival()
            playersPicker.reloadAllComponents()
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
            selectedMainPlayer = mainPlayerPickerData[row]
        
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == newPlayerNumber){
            guard NSCharacterSet(charactersIn: "0123456789").isSuperset(of: NSCharacterSet(charactersIn: string) as CharacterSet) else {
                return false
            }
        }
        return true
    }
    
    @IBAction func newTeamName(_ sender: Any) {
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
    
    func mainPlayerReterival(){
        
        // Get main Home players on view controller load
        let mainPlayerNameFilter = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@", String(scoringPassedTeamID[0]))).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)})
        print(mainPlayerNameFilter)
        mainPlayerPickerData = mainPlayerNameFilter
    }
    
    @IBAction func saveEditedPlayer(_ sender: Any) {
        let playerLine = selectLine
        let playerPosition = selectPosition
        let playerName = newPlayerName.text!
        let playerNumber = Int(newPlayerNumber.text!)
        let editedPlayer = playerInfoTable()
        
        if(playerName != "" && newPlayerNumber.text! != ""){
            editedPlayer.jerseyNum = playerNumber!
            editedPlayer.playerName = playerName
            editedPlayer.lineNum = playerLine
            editedPlayer.positionType = playerPosition
            
            try! realm.write {
                realm.add(editedPlayer, update: true)
                succesfulPlayerAdd()
            }
        }else if(playerName != "" && newPlayerNumber.text! == ""){
            editedPlayer.playerName = playerName
            editedPlayer.lineNum = playerLine
            editedPlayer.positionType = playerPosition
            
            try! realm.write {
                realm.add(editedPlayer, update: true)
                succesfulPlayerAdd()
            }
        }else if(playerName == "" && newPlayerNumber.text! != ""){
            editedPlayer.jerseyNum = playerNumber!
            editedPlayer.lineNum = playerLine
            editedPlayer.positionType = playerPosition
            
            try! realm.write {
                realm.add(editedPlayer, update: true)
                succesfulPlayerAdd()
            }
        }else{
            editedPlayer.lineNum = playerLine
            editedPlayer.positionType = playerPosition
            
            try! realm.write {
                realm.add(editedPlayer, update: true)
                succesfulPlayerAdd()
            }        }
    }
    
    func succesfulTeamAdd(){
        
        let successfulQuery = UIAlertController(title: "Team changed Successfully", message: "", preferredStyle: UIAlertController.Style.alert)
        successfulQuery.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(successfulQuery, animated: true, completion: nil)
    }
    
    func succesfulPlayerAdd(){
        
        let successfulQuery = UIAlertController(title: "Player changed Successfully", message: "", preferredStyle: UIAlertController.Style.alert)
        successfulQuery.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(successfulQuery, animated: true, completion: nil)
    }
    
    func missingFieldAlert(){
        
        // create the alert
        let missingField = UIAlertController(title: "Missing Field Error", message: "Please have Team Name filled out before attemtping to change a new team name.", preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        missingField.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(missingField, animated: true, completion: nil)
    }
}
