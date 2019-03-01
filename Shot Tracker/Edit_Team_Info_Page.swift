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
    @IBOutlet weak var newTeamName: UITextField!
    
    var selectTeamKey:Int = 0
    
    var teamPickerData:Results<teamInfoTable>!
    var teamPickerSelect:[teamInfoTable] = []
    var selectTeam: String = ""
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.teamPicker.delegate = self
        self.teamPicker.dataSource = self
        
        self.teamPickerData = realm.objects(teamInfoTable.self)
        self.teamPickerSelect = Array(self.teamPickerData)
        
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
        return teamPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return teamPickerSelect[row].nameOfTeam
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectTeam = teamPickerSelect[row].nameOfTeam
        selectTeamKey = teamPickerSelect[row].teamID
    }
    
    @IBAction func newTeamName(_ sender: Any) {
        //let team: String = selectTeam
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
