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
    @IBOutlet weak var activeStateTeamSwitch: UISwitch!
    @IBOutlet weak var activeStateTeamLabel: UILabel!
    @IBOutlet weak var activeStatePlayerSwitch: UISwitch!
    @IBOutlet weak var activeStatePLayerLabel: UILabel!
    
    var selectTeamKey:Int = 0
    var homeTeam: Int?
    var scoringPassedTeamID: [Int] = [Int]()
    var selectedTeamID: Int!
    
    //variables for player data retrival from realm
    var mainPlayerPickerData: [String] = [String]()
    var mainPlayerPickerDataID: [Int] = [Int]()
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
    var activeTeamBool: [String] = [String]()
    var activePlayerBool: [String] = [String]()
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        activeStateTeamSwitch.addTarget(self, action: #selector(self.switchValueDidChange), for: .valueChanged)
        activeStatePlayerSwitch.addTarget(self, action: #selector(self.switchValueDidChange), for: .valueChanged)
        
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
        
        scoringPassedTeamID = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "activeState == true OR activeState == false")).value(forKeyPath: "teamID") as! [Int]).compactMap({Int($0)})
        mainPlayerPickerData = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@", String(scoringPassedTeamID[0]))).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)})
        mainPlayerPickerDataID = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@", String(scoringPassedTeamID[0]))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        selectedMainPlayerID = mainPlayerPickerDataID[0]
        
        pickerData = ["Forward 1","Forward 2","Forward 3","Defence 1","Defence 2","Defence 3", "Goalie"]
        positionData = ["Left Wing", "Center", "Right Wing", "Left Defence", "Right Defence", "Goalie"]
        positionCodeData = ["LW", "C", "RW", "LD", "RD", "G"]
        activeTeamBool = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "activeState == true OR activeState == false")).value(forKeyPath: "activeState") as! [Bool]).compactMap({String($0)})
        activePlayerBool = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == true OR activeState == false", String(scoringPassedTeamID[0]))).value(forKeyPath: "activeState") as! [Bool]).compactMap({String($0)})
        
        activeStateTeamSwitch.isOn = Bool(activeTeamBool[0])!
        if (activeStateTeamSwitch.isOn == true) {activeStateTeamLabel.text =
            "Enable " + teamPickerData[0].nameOfTeam;}else{activeStateTeamLabel.text = "Disable " + teamPickerData[0].nameOfTeam;}
        activeStatePlayerSwitch.isOn = Bool(activePlayerBool[0])!
        if (activeStatePlayerSwitch.isOn == true) {activeStatePLayerLabel.text = "Enable \(mainPlayerPickerData[0])"}else{activeStatePLayerLabel.text = "Disable \(mainPlayerPickerData[0])"}

      
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // if keyboard is out push whole view up half the height of the keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height / 2)
            }
        }
    }
    // when keybaord down return view back to y orgin of 0
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc func switchValueDidChange(sender: UISwitch){
        
        if(activeStateTeamSwitch.isOn == true){
            activeStateTeamLabel.text = "Enable \(selectTeam)"
        }else{
            activeStateTeamLabel.text = "Disable \(selectTeam)"
        }
        if(activeStatePlayerSwitch.isOn == true){
            activeStatePLayerLabel.text = "Enable \(selectedMainPlayer)"
        }else{
            activeStatePLayerLabel.text = "Disable \(selectedMainPlayer)"
        }
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
            selectedTeamID = teamPickerSelect[row].teamID
            mainPlayerReterival()
            playersPicker.reloadAllComponents()
            if(activeTeamBool[row] == "true"){
                activeStateTeamSwitch.isOn = true
                activeStateTeamLabel.text = "Enable \(selectTeam)"
            }else{
                activeStateTeamSwitch.isOn = false
                activeStateTeamLabel.text = "Disable \(selectTeam)"
            }
            activeStateTeamSwitch.reloadInputViews()
           
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
            selectedMainPlayerID = mainPlayerPickerDataID[row]
            if(activePlayerBool[row] == "true"){
                activeStatePlayerSwitch.isOn = true
                activeStatePLayerLabel.text = "Enable \(selectedMainPlayer)"
            }else{
                activeStatePlayerSwitch.isOn = false
                activeStatePLayerLabel.text = "Disable \(selectedMainPlayer)"
            }
            activeStatePlayerSwitch.reloadInputViews()
        
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
        
        if (newName != "" && activeStateTeamSwitch.isOn == true){
            newTeam.teamID = teamID!
            newTeam.nameOfTeam = newName
            try! realm.write{
                realm.add(newTeam, update: true)
                succesfulTeamAdd()
                
            }
        }else if (newName != "" && activeStateTeamSwitch.isOn != true){
            newTeam.teamID = teamID!
            newTeam.nameOfTeam = newName
            newTeam.activeState = false
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
        mainPlayerPickerData = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@", String(selectedTeamID))).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)})
        activePlayerBool = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == true OR activeState == false", String(selectedTeamID))).value(forKeyPath: "activeState") as! [Bool]).compactMap({String($0)})
        mainPlayerPickerDataID = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@", String(selectedTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        print(activePlayerBool)
    }
    
    @IBAction func saveEditedPlayer(_ sender: Any) {
        let playerLine = selectLine
        let playerPosition = selectPosition
        let playerName = newPlayerName.text!
        let playerNumber = Int(newPlayerNumber.text!)
        let editedPlayer = self.realm.object(ofType: playerInfoTable.self, forPrimaryKey: selectedMainPlayerID);
        if(selectLine == 0 ){
            if(selectPosition == "G"){
                // check to see if fields are filled out properly
                if(playerName != "" && newPlayerNumber.text! != ""){
                    
                    try! realm.write {
                        editedPlayer!.jerseyNum = playerNumber!
                        editedPlayer!.playerName = playerName
                        editedPlayer!.lineNum = playerLine
                        editedPlayer!.positionType = playerPosition
                        editedPlayer!.activeState = activeStatePlayerSwitch.isOn
                        succesfulPlayerAdd()
                    }
                }else if(playerName != "" && newPlayerNumber.text! == ""){
                    
                    try! realm.write {
                        editedPlayer!.playerName = playerName
                        editedPlayer!.lineNum = playerLine
                        editedPlayer!.positionType = playerPosition
                        editedPlayer!.activeState = activeStatePlayerSwitch.isOn
                        succesfulPlayerAdd()
                    }
                }else if(playerName == "" && newPlayerNumber.text! != ""){
                    
                    try! realm.write {
                        editedPlayer!.jerseyNum = playerNumber!
                        editedPlayer!.lineNum = playerLine
                        editedPlayer!.positionType = playerPosition
                        editedPlayer!.activeState = activeStatePlayerSwitch.isOn
                        succesfulPlayerAdd()
                    }
                }else{
                    
                    try! realm.write {
                        editedPlayer!.lineNum = playerLine
                        editedPlayer!.positionType = playerPosition
                        editedPlayer!.activeState = activeStatePlayerSwitch.isOn
                        succesfulPlayerAdd()
                    }
                }
            }else{
                misMatchAlert()
            }
        }else if(selectLine == 4 || selectLine == 5 || selectLine == 6){
            if(selectPosition == "RD" || selectPosition == "LD"){
                // check to see if fields are filled out properly
                if(playerName != "" && newPlayerNumber.text! != ""){
                    
                    try! realm.write {
                        editedPlayer!.jerseyNum = playerNumber!
                        editedPlayer!.playerName = playerName
                        editedPlayer!.lineNum = playerLine
                        editedPlayer!.positionType = playerPosition
                        editedPlayer!.activeState = activeStatePlayerSwitch.isOn
                        succesfulPlayerAdd()
                    }
                }else if(playerName != "" && newPlayerNumber.text! == ""){
                    
                    try! realm.write {
                        editedPlayer!.playerName = playerName
                        editedPlayer!.lineNum = playerLine
                        editedPlayer!.positionType = playerPosition
                        editedPlayer!.activeState = activeStatePlayerSwitch.isOn
                        succesfulPlayerAdd()
                    }
                }else if(playerName == "" && newPlayerNumber.text! != ""){
                    
                    try! realm.write {
                        editedPlayer!.jerseyNum = playerNumber!
                        editedPlayer!.lineNum = playerLine
                        editedPlayer!.positionType = playerPosition
                        editedPlayer!.activeState = activeStatePlayerSwitch.isOn
                        succesfulPlayerAdd()
                    }
                }else{
                    
                    try! realm.write {
                        editedPlayer!.lineNum = playerLine
                        editedPlayer!.positionType = playerPosition
                        editedPlayer!.activeState = activeStatePlayerSwitch.isOn
                        succesfulPlayerAdd()
                    }
                }
            }else{
                misMatchAlert()
                print("hi")
            }
        }else if(selectLine == 1 || selectLine == 2 || selectLine == 3){
            if(selectPosition == "RW" || selectPosition == "C" || selectPosition == "LW"){
                if(playerName != "" && newPlayerNumber.text! != ""){
                    
                    try! realm.write {
                        editedPlayer!.jerseyNum = playerNumber!
                        editedPlayer!.playerName = playerName
                        editedPlayer!.lineNum = playerLine
                        editedPlayer!.positionType = playerPosition
                        editedPlayer!.activeState = activeStatePlayerSwitch.isOn
                        succesfulPlayerAdd()
                    }
                }else if(playerName != "" && newPlayerNumber.text! == ""){
                    
                    try! realm.write {
                        editedPlayer!.playerName = playerName
                        editedPlayer!.lineNum = playerLine
                        editedPlayer!.positionType = playerPosition
                        editedPlayer!.activeState = activeStatePlayerSwitch.isOn
                        succesfulPlayerAdd()
                    }
                }else if(playerName == "" && newPlayerNumber.text! != ""){
                    
                    try! realm.write {
                        editedPlayer!.jerseyNum = playerNumber!
                        editedPlayer!.lineNum = playerLine
                        editedPlayer!.positionType = playerPosition
                        editedPlayer!.activeState = activeStatePlayerSwitch.isOn
                        succesfulPlayerAdd()
                    }
                }else{
                    
                    try! realm.write {
                        editedPlayer!.lineNum = playerLine
                        editedPlayer!.positionType = playerPosition
                        editedPlayer!.activeState = activeStatePlayerSwitch.isOn
                        succesfulPlayerAdd()
                    }
                }
            }else{
                misMatchAlert()
                print("hi")
            }
        }
        
    }
    
    func succesfulTeamAdd(){
        
        let successfulQuery = UIAlertController(title: "Team \(selectTeam) has been successfully changed to \(newTeamName.text)", message: "", preferredStyle: UIAlertController.Style.alert)
        successfulQuery.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(successfulQuery, animated: true, completion: nil)
    }
    
    func succesfulPlayerAdd(){
        
        let successfulQuery = UIAlertController(title: "Player \(selectedMainPlayer) has been successfully changed to \(newPlayerName.text)", message: "", preferredStyle: UIAlertController.Style.alert)
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
    func misMatchAlert(){
        
        // create the alert
        let missingField = UIAlertController(title: "Mismatch of Position/Line Error", message: "Select the appropriate line for the appropriate position.", preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        missingField.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(missingField, animated: true, completion: nil)
        
    }
}
