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

class Edit_Team_Info_Page: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIPopoverPresentationControllerDelegate {
    
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
    @IBOutlet weak var visitWebsiteButton: UIButton!
    
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
    var forwardPositionData:[String] = [String]()
    var defensePositionData:[String] = [String]()
    var goaliePositionData:[String] = [String]()
    var positionCodeData:[String] = [String]()
    var activeTeamBool: [String] = [String]()
    var activePlayerBool: [String] = [String]()
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder() // To get shake gesture
        
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
        
        pickerData = ["Forward 1", "Forward 2","Forward 3","Defense 1","Defense 2","Defense 3","Goalie"]
        forwardPositionData = ["Left Wing", "Center", "Right Wing"]
        defensePositionData = ["Left Defence", "Right Defence"]
        goaliePositionData = ["Goalie"]
        positionCodeData = ["LW", "C", "RW", "LD", "RD", "G"]
        selectTeam = teamPickerSelect[0].nameOfTeam
        selectedTeamID = teamPickerSelect[0].teamID
        selectPosition = positionCodeData[0]
        selectedMainPlayer = mainPlayerPickerData[0]
        selectLine = 1
        activeTeamBool = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "activeState == true OR activeState == false")).value(forKeyPath: "activeState") as! [Bool]).compactMap({String($0)})
        activePlayerBool = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == true OR activeState == false", String(scoringPassedTeamID[0]))).value(forKeyPath: "activeState") as! [Bool]).compactMap({String($0)})
        
        activeStateTeamSwitch.isOn = Bool(activeTeamBool[0])!
        if (activeStateTeamSwitch.isOn == true) {activeStateTeamLabel.text =
            "Enable " + teamPickerData[0].nameOfTeam;}else{activeStateTeamLabel.text = "Disable " + teamPickerData[0].nameOfTeam;}
        activeStatePlayerSwitch.isOn = Bool(activePlayerBool[0])!
        if (activeStatePlayerSwitch.isOn == true) {activeStatePLayerLabel.text = "Enable \(mainPlayerPickerData[0])"}else{activeStatePLayerLabel.text = "Disable \(mainPlayerPickerData[0])"}

      
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        
         dismiss(animated: true, completion: nil)
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
        switch pickerView {
        case teamPicker:
            return teamPickerData.count
        case linePicker:
             return pickerData.count
        case positionPicker:
            switch selectLine{
            case  1,2,3:
                return forwardPositionData.count
            case 4,5,6:
                return defensePositionData.count
            default :
                return 1
            }
        default:
            
             return mainPlayerPickerData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView == teamPicker){
            return teamPickerSelect[row].nameOfTeam
        }else if(pickerView == positionPicker){
            switch selectLine{
            case  1,2,3:
                return forwardPositionData[row]
            case 4,5,6:
                return defensePositionData[row]
            default :
                return goaliePositionData[row]
            }
        }else if(pickerView == linePicker){
                return pickerData[row]
            
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
           activeTeamBoolFunc()
           
        }else if(pickerView == linePicker){
            if(pickerData[row] == "Forward 1"){
                selectLine = 1
                positionPicker.reloadAllComponents()
               
            }else if(pickerData[row] == "Forward 2"){
                selectLine = 2
                positionPicker.reloadAllComponents()
            }else if(pickerData[row] == "Forward 3"){
                selectLine = 3
                 positionPicker.reloadAllComponents()
            }else if(pickerData[row] == "Defense 1"){
                selectLine = 4
                 positionPicker.reloadAllComponents()
            }else if(pickerData[row] == "Defense 2"){
                selectLine = 5
                 positionPicker.reloadAllComponents()
            }else if(pickerData[row] == "Defense 3"){
                selectLine = 6
                 positionPicker.reloadAllComponents()
            }else{
                selectLine = 0
                 positionPicker.reloadAllComponents()
            }
        }else if(pickerView == positionPicker){
            switch selectLine{
            case  1,2,3:
                selectPosition = positionCodeData[row]
            case 4,5,6:
                selectPosition = positionCodeData[row + 3]
            default :
                selectPosition = positionCodeData[positionCodeData.count - 1]
            }
        }else{
            selectedMainPlayer = mainPlayerPickerData[row]
            selectedMainPlayerID = mainPlayerPickerDataID[row]
            activePlayerBoolFunc(index: row)
        
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
    
    func activeTeamBoolFunc(){
        if(activeTeamBool[selectedTeamID] == "true"){
            activeStateTeamSwitch.isOn = true
            activeStateTeamLabel.text = "Enable \(selectTeam)"
            activeTeamBool = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "activeState == true OR activeState == false")).value(forKeyPath: "activeState") as! [Bool]).compactMap({String($0)})
        }else{
            activeStateTeamSwitch.isOn = false
            activeStateTeamLabel.text = "Disable \(selectTeam)"
            activeTeamBool = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "activeState == true OR activeState == false")).value(forKeyPath: "activeState") as! [Bool]).compactMap({String($0)})
        }
        activeStateTeamSwitch.reloadInputViews()
        activeStateTeamLabel.reloadInputViews()
        print("we good")
        
    }
    
    func activePlayerBoolFunc(index: Int){
        if(((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == true OR activeState == false", String(selectedTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})).count != 0){
             playersPicker.isUserInteractionEnabled = true
            if(activePlayerBool[index] == "true"){
                activeStatePlayerSwitch.isOn = true
                activeStatePLayerLabel.text = "Enable \(selectedMainPlayer)"
                activePlayerBool = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == true OR activeState == false", String(selectedTeamID))).value(forKeyPath: "activeState") as! [Bool]).compactMap({String($0)})
            }else{
                activeStatePlayerSwitch.isOn = false
                activeStatePLayerLabel.text = "Disable \(selectedMainPlayer)"
                activePlayerBool = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == true OR activeState == false", String(selectedTeamID))).value(forKeyPath: "activeState") as! [Bool]).compactMap({String($0)})
            }
            activeStatePlayerSwitch.reloadInputViews()
            activeStatePLayerLabel.reloadInputViews()
            
        }else{
            print("this team seems to be missing players")

        }
        
    }
    
    @IBAction func newTeamName(_ sender: UIButton) {
        let newName = newTeamName.text!
        let newTeam = self.realm.object(ofType: teamInfoTable.self, forPrimaryKey: selectedTeamID!);
        
        if (newName != "" && activeStateTeamSwitch.isOn == true){
            
            try! realm.write{
                newTeam!.activeState = true
                newTeam!.nameOfTeam = newName
                succesfulTeamAdd(teamName: newName)
                self.teamPickerData = realm.objects(teamInfoTable.self)
                self.teamPickerSelect = Array(self.teamPickerData)
                teamPicker.reloadAllComponents()
                selectTeam = teamPickerSelect[selectedTeamID].nameOfTeam
                activeTeamBoolFunc()
                
            }
        }else if (newName == "" && activeStateTeamSwitch.isOn != true){
            if (selectedTeamID == (UserDefaults.standard.object(forKey: "defaultHomeTeamID") as? Int)){
                UserDefaults.standard.set(nil, forKey: "defaultHomeTeamID")
                print("Default Team Reset")
            }else{
                print("Default Team \(String(describing: newTeam?.nameOfTeam)) remains the same")
            }
            try! realm.write{
                newTeam!.activeState = false
                succesfulTeamAdd(teamName: selectTeam)
            }
            
                
        }else if (newName != "" && activeStateTeamSwitch.isOn != true){
            if (selectedTeamID == (UserDefaults.standard.object(forKey: "defaultHomeTeamID") as? Int)){
                UserDefaults.standard.set(nil, forKey: "defaultHomeTeamID")
                print("Default Team Reset")
            }else{
                print("Default Team \(String(describing: newTeam?.nameOfTeam)) remains the same")
            }
                try! realm.write{
                    newTeam!.activeState = false
                    newTeam!.nameOfTeam = newName
                    succesfulTeamAdd(teamName: newName)
                    self.teamPickerData = realm.objects(teamInfoTable.self)
                    self.teamPickerSelect = Array(self.teamPickerData)
                    activeTeamBoolFunc()
                    selectTeam = teamPickerSelect[selectedTeamID].nameOfTeam
                    teamPicker.reloadAllComponents()
                    
                }
        }else if (newName == "" && activeStateTeamSwitch.isOn == true){
            
            try! realm.write{
                newTeam!.activeState = true
                succesfulTeamAdd(teamName: selectTeam)
                
            }
        
        }else{
            missingFieldAlert()
            }
    }
    
    func mainPlayerReterival(){
        if(((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == true OR activeState == false", String(selectedTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})).count != 0){
             playersPicker.isUserInteractionEnabled = true
            editPlayerButton.alpha = 1.0
            editPlayerButton.isUserInteractionEnabled = false
            // Get main Home players on view controller load
            mainPlayerPickerData = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@", String(selectedTeamID))).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)})
            activePlayerBool = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == true OR activeState == false", String(selectedTeamID))).value(forKeyPath: "activeState") as! [Bool]).compactMap({String($0)})
            mainPlayerPickerDataID = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@", String(selectedTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        }else{
            
            let missingPlayers = UIAlertController(title: "Team \(selectTeam) has no players, please add some.", message: "", preferredStyle: UIAlertController.Style.alert)
            missingPlayers.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(missingPlayers, animated: true, completion: nil)
             playersPicker.isUserInteractionEnabled = false
            editPlayerButton.alpha = 0.5
            editPlayerButton.isUserInteractionEnabled = false
            mainPlayerPickerData = ["Default Player"]
           
        }
        
    }
    
    @IBAction func saveEditedPlayer(_ sender: UIButton) {
        let playerLine = selectLine
        let playerPosition = selectPosition
        let playerName = newPlayerName.text!
        let playerNumber = Int(newPlayerNumber.text!)
        let editedPlayer = self.realm.object(ofType: playerInfoTable.self, forPrimaryKey: selectedMainPlayerID);
      
        // check to see if fields are filled out properly
        if(playerName != "" && newPlayerNumber.text! != ""){
            
            try! realm.write {
                editedPlayer!.jerseyNum = playerNumber!
                editedPlayer!.playerName = playerName
                editedPlayer!.lineNum = playerLine
                editedPlayer!.positionType = playerPosition
                editedPlayer!.activeState = activeStatePlayerSwitch.isOn
                succesfulPlayerAdd(playerName: playerName)
                mainPlayerReterival()
                playersPicker.reloadAllComponents()
                selectedMainPlayer = mainPlayerPickerData[selectedMainPlayerID]
                activePlayerBoolFunc(index: (mainPlayerPickerData.firstIndex(of: selectedMainPlayer)!))
            }
        }else if(playerName != "" && newPlayerNumber.text! == ""){
            
            try! realm.write {
                editedPlayer!.playerName = playerName
                editedPlayer!.lineNum = playerLine
                editedPlayer!.positionType = playerPosition
                editedPlayer!.activeState = activeStatePlayerSwitch.isOn
                succesfulPlayerAdd(playerName: playerName)
                mainPlayerReterival()
                playersPicker.reloadAllComponents()
                selectedMainPlayer = mainPlayerPickerData[selectedMainPlayerID]
                activePlayerBoolFunc(index: (mainPlayerPickerData.firstIndex(of: selectedMainPlayer)!))
            }
        }else if(playerName == "" && newPlayerNumber.text! != ""){
            
            try! realm.write {
                editedPlayer!.jerseyNum = playerNumber!
                editedPlayer!.lineNum = playerLine
                editedPlayer!.positionType = playerPosition
                editedPlayer!.activeState = activeStatePlayerSwitch.isOn
                succesfulPlayerAdd(playerName: selectedMainPlayer)
                selectedMainPlayer = mainPlayerPickerData[selectedMainPlayerID]
                activePlayerBoolFunc(index: (mainPlayerPickerData.firstIndex(of: selectedMainPlayer)!))
            }
        }else{
            print("player postion",playerPosition)
            try! realm.write {
                editedPlayer!.lineNum = playerLine
                editedPlayer!.positionType = playerPosition
                editedPlayer!.activeState = activeStatePlayerSwitch.isOn
                succesfulPlayerAdd(playerName: selectedMainPlayer)
                selectedMainPlayer = mainPlayerPickerData[selectedMainPlayerID]
                activePlayerBoolFunc(index: (mainPlayerPickerData.firstIndex(of: selectedMainPlayer)!))
            }
        }
    }
   
    func succesfulTeamAdd(teamName: String){
        
        let successfulQuery = UIAlertController(title: "Team \(teamName) has been updated.", message: "", preferredStyle: UIAlertController.Style.alert)
        successfulQuery.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        self.present(successfulQuery, animated: true, completion: nil)
    }
    
    func succesfulPlayerAdd(playerName: String){
        
        let successfulQuery = UIAlertController(title: "Player \(playerName) has been updated.", message: "", preferredStyle: UIAlertController.Style.alert)
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
