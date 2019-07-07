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

class Add_Player_Page: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIPopoverPresentationControllerDelegate {
    
    let realm = try! Realm()
    
    @IBOutlet weak var linePicker: UIPickerView!
    @IBOutlet weak var teamPicker: UIPickerView!
    @IBOutlet weak var positionPicker: UIPickerView!
    @IBOutlet weak var playerNumber: UITextField!
    @IBOutlet weak var playerName: UITextField!
    @IBOutlet weak var inActivePlayerToggle: UISwitch!
    @IBOutlet weak var visitWebsiteButton: UIButton!
    
    var pickerData:[String] = [String]()
    var positionData:[String] = [String]()
    var positionCodeData:[String] = [String]()
    var selectLine:Int!
    var selectTeamKey: String!
    var selectPosition:String!
    var primaryPlayerID: Int!
    var forwardPositionData: [String] = [String]()
    var defensePositionData: [String] = [String]()
    var goaliePositionData: [String] = [String]()
    
    var teamPickerData: [String] = [String]()
    var teamIDPickerData:[String] = [String]()
    var selectTeam: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder() // To get shake gesture
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.teamPicker.delegate = self
        self.teamPicker.dataSource = self
        
        self.linePicker.delegate = self
        self.linePicker.dataSource = self
        
        self.positionPicker.delegate = self
        self.positionPicker.dataSource = self
        
        playerNumber.delegate = self
       
        // Do any additional setup after loading the view.
        pickerData = ["Forward 1", "Forward 2","Forward 3","Defense 1","Defense 2","Defense 3","Goalie"]
        forwardPositionData = ["Left Wing", "Center", "Right Wing"]
        defensePositionData = ["Left Defence", "Right Defence"]
        goaliePositionData = ["Goalie"]
        positionCodeData = ["LW", "C", "RW", "LD", "RD", "G"]
        teamPickerData = (self.realm.objects(teamInfoTable.self).filter(NSPredicate(format: "activeState == true")).value(forKeyPath: "nameOfTeam") as! [String]).compactMap({String($0)})
        teamIDPickerData = (self.realm.objects(teamInfoTable.self).filter(NSPredicate(format: "activeState == true")).value(forKeyPath: "teamID") as! [Int]).compactMap({String($0)})
        print(teamIDPickerData)
        
        //Sets selected team ID and position is set to position zero
        //of the arrays. Set selected line to 1(forward line 1)
        selectTeamKey = teamIDPickerData[0]
        selectPosition = positionCodeData[0]
        selectLine = 1
    }
    
    // We are willing to become first responder to get shake motion
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    // Enable detection of shake motion
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            /* let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
             let newViewController = storyBoard.instantiateViewController(withIdentifier: "Help_View_Controller") as! Help_Guide_View_Controller
             self.present(newViewController, animated: true, completion: nil)*/
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let popupVC = storyboard.instantiateViewController(withIdentifier: "Help_View_Controller") as! Help_Guide_View_Controller
            popupVC.modalPresentationStyle = .overCurrentContext
            popupVC.modalTransitionStyle = .crossDissolve
            let pVC = popupVC.popoverPresentationController
            pVC?.permittedArrowDirections = .any
            pVC?.delegate = self
            
            present(popupVC, animated: true, completion: nil)
            print("Help Guide Presented!")
        }
    }
    
    @IBAction func visitWebsiteButton(_ sender: Any) {
        
        let actionSheet = UIAlertController(title: "Did you Know?", message: "Tired of adding your players one by one? Coach Assistant allows you to add multiple users with our handy import / backup funciton. We have an easy to follow and quick tutorial online so you can get started!", preferredStyle: .actionSheet)
        
        
        let openAction = UIAlertAction(title: "Open", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            guard let url = URL(string: universalValue().websiteURLHelp) else { return }
            UIApplication.shared.open(url)
        })
        // tapp anywhere outside of popup alert controller
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in
            print("didPress Cancel")
        })
        // Add the actions to your actionSheet
        actionSheet.addAction(openAction)
        actionSheet.addAction(cancelAction)
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.visitWebsiteButton
            
        }
        // Present the controller
        self.present(actionSheet, animated: true, completion: nil)
        
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
        switch pickerView {
        case teamPicker:
            return teamPickerData.count
        case linePicker:
            return pickerData.count

        default:
            
            switch selectLine{
            case  1,2,3:
                return forwardPositionData.count
            case 4,5,6:
                return defensePositionData.count
            default :
                return 1
            }
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView == teamPicker){
            return teamPickerData[row]
        }else if(pickerView == positionPicker){
            switch selectLine{
            case  1,2,3:
                return forwardPositionData[row]
            case 4,5,6:
                return defensePositionData[row]
            default :
                return goaliePositionData[row]
            }
        }else {
            return pickerData[row]
            
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
 
        if(pickerView == teamPicker){
            selectTeamKey = teamIDPickerData[row]
            
        }else if(pickerView == linePicker){
            if(pickerData[row] == "Forward 1"){
                selectLine = 1
                positionPicker.reloadAllComponents()
                selectPosition = "LW"
                
            }else if(pickerData[row] == "Forward 2"){
                selectLine = 2
                positionPicker.reloadAllComponents()
                selectPosition = "LW"
            }else if(pickerData[row] == "Forward 3"){
                selectLine = 3
                positionPicker.reloadAllComponents()
                selectPosition = "LW"
            }else if(pickerData[row] == "Defense 1"){
                selectLine = 4
                positionPicker.reloadAllComponents()
                selectPosition = "LD"
            }else if(pickerData[row] == "Defense 2"){
                selectLine = 5
                positionPicker.reloadAllComponents()
                selectPosition = "LD"
            }else if(pickerData[row] == "Defense 3"){
                selectLine = 6
                positionPicker.reloadAllComponents()
                selectPosition = "LD"
            }else{
                selectLine = 0
                positionPicker.reloadAllComponents()
                selectPosition = "G"
            }
        }else{
            switch selectLine{
            case  1,2,3:
                selectPosition = positionCodeData[row]
                
            case 4,5,6:
                selectPosition = positionCodeData[row + 3]
            default :
                selectPosition = positionCodeData[positionCodeData.count - 1]
            }
            print("Select Position \(selectPosition)")
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
        if (doubleJerseyNumCheck(selectedTeamID: Int(selectTeamKey)!) == false){
            
            // check to see if fields are filled out properly
            // write info to realm and reset all fields
            if (number != nil && nameOfPlayer != ""){
                newPlayer.playerID = primaryPlayerID
                
                try! realm.write{
                    realm.add(newPlayer, update: true)
                    newPlayer.playerName = nameOfPlayer
                    newPlayer.jerseyNum = number!
                    newPlayer.lineNum = line!
                    newPlayer.positionType = position!
                    newPlayer.TeamID = teamID
             
                }
                
                
                playerName.text = ""
                playerNumber.text = ""
                self.teamPicker.reloadAllComponents()
                self.linePicker.reloadAllComponents()

            }else{
                missingFieldAlert()
            }
        }else{
            // double jersey number alrt
            let doubleJersey = UIAlertController(title: "Double Up!", message: "Please make sure each memeber of your team as a unique jersey number", preferredStyle: UIAlertController.Style.alert)
            // add an action (button)
            doubleJersey.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            // show the alert
            self.present(doubleJersey, animated: true, completion: nil)
            
        }
    }
    // if player name or player number is missing create alert notifying user
    func missingFieldAlert(){
        
        // create the alert
        let missingField = UIAlertController(title: "Missing Field Error", message: "Please have Player Name and Number filled before attemtping to add a new player.", preferredStyle: UIAlertController.Style.alert)
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
    
    func doubleJerseyNumCheck(selectedTeamID: Int) -> Bool {
        
        if ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND jerseyNum == %i AND activeState == true", String(selectedTeamID), Int(playerNumber.text!)!)).value(forKeyPath: "playerID") as! [Int]).compactMap({String($0)}).isEmpty == false){
            print("Jersey Double up Failed Test")
            return true
        }else{
            print("Jersey Double up Passed Test")
            return false
        }
        
    }
}
