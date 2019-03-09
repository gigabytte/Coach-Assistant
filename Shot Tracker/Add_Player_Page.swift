//
//  Add_Team_Info_Page.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-01-29.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class Add_Player_Page: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    let realm = try! Realm()
    @IBOutlet weak var linePicker: UIPickerView!
    @IBOutlet weak var teamPicker: UIPickerView!
    @IBOutlet weak var positionPicker: UIPickerView!
    @IBOutlet weak var playerNumber: UITextField!
    @IBOutlet weak var playerName: UITextField!
    @IBOutlet weak var inActivePlayerToggle: UISwitch!
    
    var pickerData:[String] = [String]()
    var positionData:[String] = [String]()
    var positionCodeData:[String] = [String]()
    var selectLine:Int!
    var selectTeamKey: String!
    var selectPosition:String!
    var primaryPlayerID: Int!
    
    var teamPickerData: [String] = [String]()
    var teamIDPickerData:[String] = [String]()
    var selectTeam: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = try! Realm()
        
        playerName.delegate = self as? UITextFieldDelegate
        playerNumber.delegate = self as? UITextFieldDelegate
        
        self.teamPicker.delegate = self
        self.teamPicker.dataSource = self
        
        self.linePicker.delegate = self
        self.linePicker.dataSource = self
        
        self.positionPicker.delegate = self
        self.positionPicker.dataSource = self
        
        playerNumber.delegate = self
        // MUST SET ON EACH VIEW DEPENDENT ON ORIENTATION NEEDS
        // get rotation allowances of device
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // set auto rotation to false
        appDelegate.shouldRotate = true
        // Do any additional setup after loading the view.
        pickerData = ["Forward 1","Forward 2","Forward 3","Defence 1","Defence 2","Defence 3", "Goalie"]
        positionData = ["Left Wing", "Center", "Right Wing", "Left Defence", "Right Defence", "Goalie"]
        positionCodeData = ["LW", "C", "RW", "LD", "RD", "G"]
        teamPickerData = (self.realm.objects(teamInfoTable.self).filter(NSPredicate(format: "activeState == true")).value(forKeyPath: "nameOfTeam") as! [String]).compactMap({String($0)})
        teamIDPickerData = (self.realm.objects(teamInfoTable.self).filter(NSPredicate(format: "activeState == true")).value(forKeyPath: "teamID") as! [Int]).compactMap({String($0)})
        print(teamIDPickerData)
        selectTeamKey = teamIDPickerData[0]
        selectPosition = positionCodeData[0]
        selectLine = 1
    }
    // restrict player number field to decimal degots only
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == playerNumber){
            guard NSCharacterSet(charactersIn: "0123456789").isSuperset(of: NSCharacterSet(charactersIn: string) as CharacterSet) else {
                return false
            }
        }
        return true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == teamPicker){
            return teamPickerData.count
        }else if(pickerView == linePicker){
            return pickerData.count
        }else{
            return positionData.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == teamPicker){
            return teamPickerData[row]
        }else if(pickerView == linePicker){
            return pickerData[row]
        }else{
            return positionData[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == teamPicker){
            selectTeamKey = teamIDPickerData[row]
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
        }else{
            selectPosition = positionCodeData[row]
        }
    }
    
    // on add player button click
    @IBAction func savePlayer(_ sender: Any) {
        
        let nameOfPlayer: String = playerName.text!
        let number = Int(playerNumber.text!)
        let line = selectLine
        let position = selectPosition
        let teamID = selectTeamKey!
        let newPlayer = playerInfoTable()
        
        if (realm.objects(playerInfoTable.self).max(ofProperty: "playerID") as Int? != nil){
            
            primaryPlayerID = (realm.objects(playerInfoTable.self).max(ofProperty: "playerID")as Int? ?? 0) + 1
        }else{
            primaryPlayerID = (realm.objects(playerInfoTable.self).max(ofProperty: "playerID")as Int? ?? 0)
            
        }
        
        // check to see if fields are filled out properly
        if (number != nil && nameOfPlayer != "" && inActivePlayerToggle.isOn != true){
            newPlayer.playerID = primaryPlayerID
            newPlayer.playerName = nameOfPlayer
            newPlayer.jerseyNum = number!
            newPlayer.lineNum = line!
            newPlayer.positionType = position!
            newPlayer.TeamID = teamID
            
            try! realm.write{
                // write info to realm and reset all fields
                realm.add(newPlayer, update: true)
                playerName.text = ""
                playerNumber.text = ""
                self.teamPicker.reloadAllComponents()
                self.linePicker.reloadAllComponents()
                succesfulPlayerAdd(playerName: nameOfPlayer)
            }
        }else if(number != nil && nameOfPlayer != "" && inActivePlayerToggle.isOn == true){
            newPlayer.playerID = primaryPlayerID
            newPlayer.playerName = nameOfPlayer
            newPlayer.jerseyNum = number!
            newPlayer.lineNum = line!
            newPlayer.positionType = position!
            newPlayer.TeamID = teamID
            newPlayer.activeState = false
            
            try! realm.write{
                // write info to realm and reset all fields
                realm.add(newPlayer, update: true)
                playerName.text = ""
                playerNumber.text = ""
                self.teamPicker.reloadAllComponents()
                self.linePicker.reloadAllComponents()
                succesfulPlayerAdd(playerName: nameOfPlayer)
            }
        }else{
            // alert user if missing fields are present
            missingFieldAlert()
        }
    }
    // if player name or player number is missing create alert notifying user
    func missingFieldAlert(){
        
        // create the alert
        let missingField = UIAlertController(title: "Missing Field Error", message: "Please have Player Name and Number filled out before attemtping to add a new player.", preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        missingField.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(missingField, animated: true, completion: nil)
        
    }
    // if player was addded succesfully notify user
    func succesfulPlayerAdd(playerName: String){
        
        // create the alert
        let successfulQuery = UIAlertController(title: "\(playerName) Added Successfully", message: "", preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        successfulQuery.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(successfulQuery, animated: true, completion: nil)
    }
}
