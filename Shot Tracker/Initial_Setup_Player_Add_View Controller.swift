//
//  Initial_Setup_Player_Add_View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-23.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class Initial_Setup_Player_Add_View_Controller: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    let realm = try! Realm()
    
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var proceedArrow: UIImageView!
    @IBOutlet weak var playerNameTextField: UITextField!
    @IBOutlet weak var playerNumberTextField: UITextField!
    @IBOutlet weak var playerPositionPicker: UIPickerView!
    @IBOutlet weak var playerLinePicker: UIPickerView!
    @IBOutlet weak var viewControllerTitle: UILabel!
    
    var pickerData:[String] = [String]()
    var forwardPositionData:[String] = [String]()
    var defensePositionData:[String] = [String]()
    var goaliePositionData:[String] = [String]()
    var positionCodeData:[String] = [String]()
    
    var queryTeamID: Int!
    var primaryPlayerID: Int!
    var selectPlayerLine: Int!
    var selectPosition: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.playerLinePicker.delegate = self
        self.playerLinePicker.dataSource = self
        
        self.playerPositionPicker.delegate = self
        self.playerPositionPicker.dataSource = self
        
        playerNumberTextField.delegate = self
        playerNameTextField.delegate = self
        
        // MARK intialize ui elements on load so user cannot leave blank
        // ie. user must complete elements in order to save player successfully
        let alphaStartValue = 0.25
        playerNumberTextField.isUserInteractionEnabled = false
        playerNumberTextField.alpha = CGFloat(alphaStartValue)
        playerPositionPicker.isUserInteractionEnabled = false
        playerPositionPicker.alpha = CGFloat(alphaStartValue)
        playerLinePicker.isUserInteractionEnabled = false
        playerLinePicker.alpha = CGFloat(alphaStartValue)
        
        // Do any additional setup after loading the view.
        pickerData = ["Forward 1", "Forward 2","Forward 3","Defense 1","Defense 2","Defense 3","Goalie"]
        forwardPositionData = ["Left Wing", "Center", "Right Wing"]
        defensePositionData = ["Left Defence", "Right Defence"]
        goaliePositionData = ["Goalie"]
        positionCodeData = ["LW", "C", "RW", "LD", "RD", "G"]
        
        proceedArrow.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (((realm.objects(teamInfoTable.self).filter(NSPredicate(format: "teamID >= %i AND activeState == %@", 0, NSNumber(value: true))).value(forKeyPath: "teamID") as! [Int]).compactMap({Int($0)})).last != nil){
            queryTeamID = ((realm.objects(teamInfoTable.self).filter(NSPredicate(format: "teamID >= %i AND activeState == %@", 0, NSNumber(value: true))).value(forKeyPath: "teamID") as! [Int]).compactMap({Int($0)})).last
            // set View COntroller title based on users previous team add
            let queryTeamName = realm.object(ofType: teamInfoTable.self, forPrimaryKey: queryTeamID)?.nameOfTeam
            viewControllerTitle.text = "Add Player to \(queryTeamName!)"
            //Sets selected team ID and position is set to position zero
            //of the arrays. Set selected line to 1(forward line 1)
            selectPosition = positionCodeData[0]
            selectPlayerLine = 1
            
            // hide warning label if user has added a team
            warningLabel.isHidden = true
        }else{
            // show warning label / proceed arrow and blur VC if user has added a team
            warningLabel.isHidden = false
            proceedArrow.isHidden = false
            // add blur effect to view along with popUpView
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(blurEffectView)
            view.addSubview(warningLabel)
            view.addSubview(proceedArrow)
            
            // animate arrow spining to the back position
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue = Double.pi
            rotationAnimation.duration = 1.0
            self.proceedArrow.layer.add(rotationAnimation, forKey: nil)
            // stick uiikmage in 108 position
            let angle = CGFloat(Double.pi)
            let tr = CGAffineTransform.identity.rotated(by: angle)
            proceedArrow.transform = tr
            //self.proceedArrow.layer.
        }
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case playerLinePicker:
            return pickerData.count
        case playerPositionPicker:
            switch selectPlayerLine{
            case  1,2,3:
                return forwardPositionData.count
            case 4,5,6:
                return defensePositionData.count
            default :
                return 1
            }
        default:
            return pickerData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView == playerPositionPicker){
            switch selectPlayerLine{
            case  1,2,3:
                return forwardPositionData[row]
            case 4,5,6:
                return defensePositionData[row]
            default :
                return goaliePositionData[row]
            }
        }else{
            return pickerData[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView == playerLinePicker){
            if(pickerData[row] == "Forward 1"){
                selectPlayerLine = 1
                playerPositionPicker.reloadAllComponents()
                playerPositionPicker.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    self.playerPositionPicker.alpha = 1.0
                }, completion: nil)
                
            }else if(pickerData[row] == "Forward 2"){
                selectPlayerLine = 2
                playerPositionPicker.reloadAllComponents()
                playerPositionPicker.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    self.playerPositionPicker.alpha = 1.0
                }, completion: nil)
            }else if(pickerData[row] == "Forward 3"){
                selectPlayerLine = 3
                playerPositionPicker.reloadAllComponents()
                playerPositionPicker.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    self.playerPositionPicker.alpha = 1.0
                }, completion: nil)
            }else if(pickerData[row] == "Defense 1"){
                selectPlayerLine = 4
                playerPositionPicker.reloadAllComponents()
                playerPositionPicker.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    self.playerPositionPicker.alpha = 1.0
                }, completion: nil)
            }else if(pickerData[row] == "Defense 2"){
                selectPlayerLine = 5
                playerPositionPicker.reloadAllComponents()
                playerPositionPicker.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    self.playerPositionPicker.alpha = 1.0
                }, completion: nil)
            }else if(pickerData[row] == "Defense 3"){
                selectPlayerLine = 6
                playerPositionPicker.reloadAllComponents()
                playerPositionPicker.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    self.playerPositionPicker.alpha = 1.0
                }, completion: nil)
            }else{
                selectPlayerLine = 0
                playerPositionPicker.reloadAllComponents()
                playerPositionPicker.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    self.playerPositionPicker.alpha = 1.0
                }, completion: nil)
            }
        }else{
            switch selectPlayerLine{
            case  1,2,3:
                selectPosition = positionCodeData[row]
                
            case 4,5,6:
                selectPosition = positionCodeData[row + 3]
                
            default :
                selectPosition = positionCodeData[positionCodeData.count - 1]
                
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == playerNumberTextField){
            guard NSCharacterSet(charactersIn: "0123456789").isSuperset(of: NSCharacterSet(charactersIn: string) as CharacterSet) else {
                return false
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    
        if (textField == playerNameTextField || playerNameTextField.text?.isEmpty != true){
            playerNumberTextField.isUserInteractionEnabled = true
            UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                self.playerNumberTextField.alpha = 1.0
            }, completion: nil)
        
            if (textField == playerNumberTextField || playerNumberTextField.text?.isEmpty != true){
                playerLinePicker.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    self.playerLinePicker.alpha = 1.0
                }, completion: nil)
                
            }
        }
    }
    
    // on add player button click
    @IBAction func savePlayer(_ sender: Any) {
        
        if (fieldErrorChecker() == true){
        
        if (realm.objects(playerInfoTable.self).max(ofProperty: "playerID") as Int? != nil){
            
            primaryPlayerID = (realm.objects(playerInfoTable.self).max(ofProperty: "playerID")as Int? ?? 0) + 1
        }else{
            primaryPlayerID = (realm.objects(playerInfoTable.self).max(ofProperty: "playerID")as Int? ?? 0)
            
        }
        let newPlayer = playerInfoTable()
    
        try! realm.write{
            newPlayer.playerID = primaryPlayerID
            newPlayer.TeamID = String(queryTeamID)
            newPlayer.playerName = playerNameTextField.text!
            newPlayer.jerseyNum = Int(playerNumberTextField.text!)!
            newPlayer.lineNum = selectPlayerLine
            newPlayer.positionType = selectPosition
            realm.add(newPlayer, update:true)
        }
        proceedArrow.isHidden = false
        // reset textfields
        playerNameTextField.text = ""
        playerNumberTextField.text = ""
        }else{
            print("User is missing a field, player canot be saved properly")
        }
     
    }
    
    func fieldErrorChecker() -> Bool{
        
        if (playerNameTextField.text?.isEmpty == true && playerNumberTextField.text?.isEmpty == true){
            
            missingFieldAlert(missingFieldType: "Player Name and Player Number")
            return false
        }else if (playerNameTextField.text?.isEmpty == true){
            
            missingFieldAlert(missingFieldType: "Player Name")
            return false
        }else if (playerNumberTextField.text?.isEmpty == true){
            missingFieldAlert(missingFieldType: "Player Number ")
            return false
        }else{
            return true
        }
    }
        
    // if player name or player number is missing create alert notifying user
    func missingFieldAlert(missingFieldType: String){
        
        // create the alert
        let missingField = UIAlertController(title: "Missing Field Error", message: "Please have the \(missingFieldType) field filled out first before saving a player.", preferredStyle: UIAlertController.Style.alert)
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
