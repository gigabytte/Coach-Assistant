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
    @IBOutlet weak var playerNumber: UITextField!
    @IBOutlet weak var playerName: UITextField!
    
    var pickerData:[String] = [String]()
    var selectLine:Int = 0
    var selectTeamKey:Int = 0
    var primaryPlayerID: Int!
    
    var teamPickerData:Results<teamInfoTable>!
    var teamPickerSelect:[teamInfoTable] = []
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
        
        self.teamPickerData = realm.objects(teamInfoTable.self)
        self.teamPickerSelect = Array(self.teamPickerData)
        
        playerNumber.delegate = self
        // MUST SET ON EACH VIEW DEPENDENT ON ORIENTATION NEEDS
        // get rotation allowances of device
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // set auto rotation to false
        appDelegate.shouldRotate = true
        // Do any additional setup after loading the view.
        pickerData = ["1","2","3","4","5","6"]
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
        }else{
            return pickerData.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == teamPicker){
            return teamPickerSelect[row].nameOfTeam
        }else{
            return pickerData[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == teamPicker){
            selectTeamKey = teamPickerSelect[row].teamID
        }else{
            selectLine = Int(pickerData[row])!
        }
    }
    
    // on add player button click
    @IBAction func savePlayer(_ sender: Any) {
        
        let player: String = playerName.text!
        let number = Int(playerNumber.text!)
        let line = selectLine
        let team = String(selectTeamKey)
        let newPlayer = playerInfoTable()
        
        if (realm.objects(playerInfoTable.self).max(ofProperty: "playerID") as Int? != nil){
            
             primaryPlayerID = (realm.objects(playerInfoTable.self).max(ofProperty: "playerID")as Int? ?? 0) + 1
        }else{
             primaryPlayerID = (realm.objects(playerInfoTable.self).max(ofProperty: "playerID")as Int? ?? 0)
            
        }
        
        // check to see if fields are filled out properly
        if (number != nil && player != nil){
            newPlayer.playerID = primaryPlayerID
            newPlayer.playerName = player
            newPlayer.jerseyNum = number!
            newPlayer.lineNum = line
            newPlayer.TeamID = team
            
            try! realm.write{
                // write info to realm and reset all fields
                realm.add(newPlayer, update: true)
                playerName.text = ""
                playerNumber.text = ""
                self.teamPicker.reloadAllComponents()
                self.linePicker.reloadAllComponents()
                succesfulPlayerAdd()
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
    func succesfulPlayerAdd(){
        
        // create the alert
        let successfulQuery = UIAlertController(title: "Player Added Successfully", message: "", preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        successfulQuery.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(successfulQuery, animated: true, completion: nil)
    }
    
}
