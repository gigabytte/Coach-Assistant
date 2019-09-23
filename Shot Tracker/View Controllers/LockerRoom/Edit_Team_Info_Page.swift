//
//  Edit_Team_Info_Page.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-01-29.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import RealmSwift

class Edit_Team_Info_Page: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIPopoverPresentationControllerDelegate {
    
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
    
    //variables for player data retrival from realm
    var mainPlayerPickerData: [String] = [String]()
    var mainPlayerPickerDataID: [Int] = [Int]()
    var HomeMainIDArray: [String] = [String]()
    var selectedMainPlayer: String = ""
    var selectedMainPlayerID: Int!
    
    var teamNameString: String!
    var selectPosition:String = ""
    var selectLine:Int = 0
    var selectedTeamID: Int!
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(myMethod(notification:)), name: NSNotification.Name(rawValue: "homePageRefresh"), object: nil)
        
        activeStateTeamSwitch.addTarget(self, action: #selector(self.switchValueDidChange), for: .valueChanged)
        activeStatePlayerSwitch.addTarget(self, action: #selector(self.switchValueDidChange), for: .valueChanged)
        
        self.playersPicker.delegate = self
        self.playersPicker.dataSource = self
        
        self.linePicker.delegate = self
        self.linePicker.dataSource = self
        
        self.positionPicker.delegate = self
        self.positionPicker.dataSource = self
        
       
        onLoad()
    
      
    }
    
    func onLoad(){
        
        selectedTeamID =  UserDefaults.standard.integer(forKey: "defaultHomeTeamID")
        
        let teamObjc = realm.object(ofType: teamInfoTable.self, forPrimaryKey: selectedTeamID)
        
        teamNameString = teamObjc?.nameOfTeam
        
        mainPlayerReterival()
        
        pickerData = ["Forward 1", "Forward 2","Forward 3","Defense 1","Defense 2","Defense 3","Goalie"]
        forwardPositionData = ["Left Wing", "Center", "Right Wing"]
        defensePositionData = ["Left Defence", "Right Defence"]
        goaliePositionData = ["Goalie"]
        positionCodeData = ["LW", "C", "RW", "LD", "RD", "G"]

        selectPosition = positionCodeData[0]
        selectedMainPlayer = mainPlayerPickerData[0]
        selectLine = 1
        selectedMainPlayerID = mainPlayerPickerDataID[0]
        
        activeTeamBool = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "activeState == true OR activeState == false")).value(forKeyPath: "activeState") as! [Bool]).compactMap({String($0)})
        
        activeStateTeamSwitch.isOn = Bool(activeTeamBool[0])!
        if (activeStateTeamSwitch.isOn == true) {activeStateTeamLabel.text =
            "Enable " + teamObjc!.nameOfTeam;}else{activeStateTeamLabel.text = "Disable " + teamObjc!.nameOfTeam;}
        activeStatePlayerSwitch.isOn = Bool(activePlayerBool[0])!
        if (activeStatePlayerSwitch.isOn == true) {activeStatePLayerLabel.text = "Enable \(mainPlayerPickerData[0])"}else{activeStatePLayerLabel.text = "Disable \(mainPlayerPickerData[0])"}
        
    }
    
    // We are willing to become first responder to get shake motion
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func myMethod(notification: NSNotification){
        print("reloading")
        onLoad()
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
        
        let actionSheet = UIAlertController(title: localizedString().localized(value:"Did you Know?"), message: localizedString().localized(value:"Tired of adding your players one by one? Coach Assistant allows you to add multiple users with our handy import / backup funciton. We have an easy to follow and quick tutorial online so you can get started!"), preferredStyle: .actionSheet)
        
        
        let openAction = UIAlertAction(title: "open", style: .default, handler: { (alert: UIAlertAction!) -> Void in
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
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: visitWebsiteButton.frame.origin.x, y: visitWebsiteButton.frame.origin.y, width: visitWebsiteButton.frame.width / 2, height: visitWebsiteButton.frame.height)
            
            
        }
        // Present the controller
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    
    
    @objc func switchValueDidChange(sender: UISwitch){
        
        if(activeStateTeamSwitch.isOn == true){
            activeStateTeamLabel.text = "Enable \(teamNameString!)"
        }else{
            activeStateTeamLabel.text = "Disable \(teamNameString!)"
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
        if(pickerView == positionPicker){
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
        if(pickerView == linePicker){
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
        print("Select Position \(selectPosition)")
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
            activeStateTeamLabel.text = "Enable \(teamNameString!)"
            activeTeamBool = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "activeState == true OR activeState == false")).value(forKeyPath: "activeState") as! [Bool]).compactMap({String($0)})
        }else{
            activeStateTeamSwitch.isOn = false
            activeStateTeamLabel.text = "Disable \(teamNameString!)"
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
        let newTeam = self.realm.object(ofType: teamInfoTable.self, forPrimaryKey: selectedTeamID);
        
        if (newName != "" && activeStateTeamSwitch.isOn == true){
            
            try! realm.write{
                newTeam!.activeState = true
                newTeam!.nameOfTeam = newName
                succesfulTeamAdd(teamName: newName)
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
                succesfulTeamAdd(teamName: teamNameString)
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
                    activeTeamBoolFunc()

                    
                }
            
        }else if (newName == "" && activeStateTeamSwitch.isOn == true){
            
            try! realm.write{
                newTeam!.activeState = true
                succesfulTeamAdd(teamName: teamNameString)
                
                
            }
        
        }else{
            missingFieldAlert()
            }
        newTeamName.text = ""
    }
    
    func mainPlayerReterival(){
        
        if(((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@", String(selectedTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})).count != 0){
             playersPicker.isUserInteractionEnabled = true
            editPlayerButton.alpha = 1.0
            playersPicker.alpha = 1.0
            editPlayerButton.isUserInteractionEnabled = true
            // Get main Home players on view controller load
            mainPlayerPickerData = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@", String(selectedTeamID))).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)})
            activePlayerBool = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == true OR activeState == false", String(selectedTeamID))).value(forKeyPath: "activeState") as! [Bool]).compactMap({String($0)})
            mainPlayerPickerDataID = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@", String(selectedTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
            activePlayerBool = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == true OR activeState == false", String(selectedTeamID))).value(forKeyPath: "activeState") as! [Bool]).compactMap({String($0)})
        }else{
            
            let missingPlayers = UIAlertController(title: "Team \(teamNameString!) has no players, please add some.", message: "", preferredStyle: UIAlertController.Style.alert)
            missingPlayers.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(missingPlayers, animated: true, completion: nil)
             playersPicker.isUserInteractionEnabled = false
            editPlayerButton.alpha = 0.5
            editPlayerButton.isUserInteractionEnabled = false
            playersPicker.alpha = 0.5
            mainPlayerPickerData = ["Default Player"]
           
        }
        DispatchQueue.main.async {
            self.playersPicker.reloadAllComponents()
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
            succesfulPlayerAdd(playerName: playerName)
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
            succesfulPlayerAdd(playerName: playerName)
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
            succesfulPlayerAdd(playerName: playerName)
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
            succesfulPlayerAdd(playerName: playerName)
        }
    }
   
    func succesfulTeamAdd(teamName: String){
        
        let successfulQuery = UIAlertController(title: String(format: localizedString().localized(value:"Team %@ has been updated."), teamName), message: "", preferredStyle: UIAlertController.Style.alert)
        successfulQuery.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            
            self.newTeamName.text = ""
            
            
        }))
        
        self.present(successfulQuery, animated: true, completion: nil)
    }
    
    func succesfulPlayerAdd(playerName: String){
        
        let successfulQuery = UIAlertController(title: String(format: localizedString().localized(value:"Player %@ has been updated."), playerName), message: "", preferredStyle: UIAlertController.Style.alert)
        successfulQuery.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            
            self.newPlayerName.text = ""
            self.newPlayerNumber.text = ""
            
            
        }))
        
        self.present(successfulQuery, animated: true, completion: nil)
    }
    
    func missingFieldAlert(){
        
        // create the alert
        let missingField = UIAlertController(title: localizedString().localized(value:"Missing Field Error"), message: localizedString().localized(value:"Please have 'Team Name' filled out before attempting to change the team name"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        missingField.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(missingField, animated: true, completion: nil)
    }
}
