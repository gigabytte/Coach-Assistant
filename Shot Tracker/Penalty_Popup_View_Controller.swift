//
//  Penalty_Popup_View_Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-27.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class Penalty_Popup_View_Controller: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    let realm = try! Realm()
    
    let leftArrowImage = UIImage(named: "left_scroll_arrow")
    let rightArrowImage = UIImage(named: "right_scroll_arrow")
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var leftScrollImageView: UIImageView!
    @IBOutlet weak var rightScrollImageView: UIImageView!
    @IBOutlet weak var popupPenaltyView: UIView!
    @IBOutlet weak var penaltyTypePicker: UIPickerView!
    @IBOutlet weak var penaltyTimePicker: UIPickerView!
    @IBOutlet weak var playerNamePicker: UIPickerView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addPenaltyButton: UIButton!
    
    var timePickerValues: [[String]] = [[String]]()
    var penaltyType: [String] = [String]()
    var playerNameArray: [String] = [String]()
    var playerIdArray: [Int] = [Int]()
    var selectedPenaltyType: String!
    var selectedFirstMinuteValue: String!
    var selectedSecMinuteValue: String!
    var selectedFirstSecondsValue: String!
    var selectedPlayerID: Int!
    var homeTeamID: Int = UserDefaults.standard.integer(forKey: "homeTeam")
    var awayTeamID: Int = UserDefaults.standard.integer(forKey: "awayTeam")
    var teamNameArray: [String] = [String]()
    var teamIdArray: [Int] = [Int]()
    var currentArrayIndex: Int = 0
    var selectedTeamID: Int!
    var primaryID:Int!
    var gluedTime: String = ""
    var tempXCords: Int!
    var tempYCords: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add blur effect to view along with popUpView
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.addSubview(popupPenaltyView)
        
        // round conrers of view an items in view
        popupPenaltyView.layer.cornerRadius = 10
        bottomRoundedCorners(buttonName: cancelButton)
        bottomRoundedCorners(buttonName: addPenaltyButton)
        let path = UIBezierPath(roundedRect:topLabel.bounds, byRoundingCorners:[.topRight, .topLeft], cornerRadii: CGSize(width: 10, height: 10))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        topLabel.layer.mask = maskLayer
        
        // Data Connections for picker views:
        self.penaltyTypePicker.delegate = self
        self.penaltyTypePicker.dataSource = self
        
        // Data Connections for picker views:
        self.playerNamePicker.delegate = self
        self.playerNamePicker.dataSource = self
        
        // Data Connections for picker views:
        self.penaltyTimePicker.delegate = self
        self.penaltyTimePicker.dataSource = self

        // values are broken down into a 2D matrix with corresponding values ranging from minutes to seconds
        timePickerValues = [/*FIrst Row Minute values*/["0", "1", "2", "3", "4", "5", "6", "7", "8"], /*Sec Row Minute values*/["0", "1", "2", "3", "4", "5", "6", "7", "8"], /*Sec values*/["0", "1", "2", "3", "4", "5", "6", "7", "8"]]
        penaltyType = ["Minor", "Major"]
        // set default player names for home team to be used in picker
        playerNameArray = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "activeState == %@ AND TeamID == %@", NSNumber(value: true), String(homeTeamID))).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)}))
        // set default player Id for home team to ve used in picker
        playerIdArray = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "activeState == %@ AND TeamID == %@", NSNumber(value: true), String(homeTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)}))
        
        // run func to start gesture reconition on popview
        swipeGestureInitializer()
        // defaults set if user does not chnage values whie using View
        gluedTime = "00:00:00"
        selectedPlayerID = playerIdArray.first
        selectedTeamID = teamIdArray.first
        selectedPenaltyType = penaltyType.first
        selectedFirstMinuteValue = timePickerValues[0].first
        selectedSecMinuteValue = timePickerValues[1].first
        selectedFirstSecondsValue = timePickerValues[2].first
    }
    
    func swipeGestureInitializer() {
        
        // get names of teams from current game
        teamNameArray.append(((realm.objects(teamInfoTable.self).filter(NSPredicate(format: "activeState == %@ AND teamID == %i", NSNumber(value: true), homeTeamID)).value(forKeyPath: "nameOfTeam") as! [String]).compactMap({String($0)})).first!)
        teamNameArray.append(((realm.objects(teamInfoTable.self).filter(NSPredicate(format: "activeState == %@ AND teamID == %i", NSNumber(value: true), awayTeamID)).value(forKeyPath: "nameOfTeam") as! [String]).compactMap({String($0)})).first!)
        
        teamIdArray.append(homeTeamID)
        teamIdArray.append(awayTeamID)
        
        selectedTeamID = teamIdArray.first!
        teamNameLabel.text = "Select Team: \(teamNameArray.first!)"
        self.leftScrollImageView.image = leftArrowImage
        self.leftScrollImageView.alpha = 0.5
        self.leftScrollImageView.setNeedsDisplay()
        
        popupPenaltyView.isUserInteractionEnabled = true
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        popupPenaltyView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        popupPenaltyView.addGestureRecognizer(swipeLeft)
    }
    
    func bottomRoundedCorners(buttonName: UIButton){
        if(buttonName == cancelButton){
            // round bottom corners of button
            let path = UIBezierPath(roundedRect:buttonName.bounds, byRoundingCorners:[.bottomLeft], cornerRadii: CGSize(width: 10, height: 10))
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            buttonName.layer.mask = maskLayer
        }else{
            let path = UIBezierPath(roundedRect:buttonName.bounds, byRoundingCorners:[.bottomRight], cornerRadii: CGSize(width: 10, height: 10))
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            buttonName.layer.mask = maskLayer
            
        }
    }
    
    func scrollArrowProccessing(){
        if (self.teamNameArray[self.currentArrayIndex] == self.teamNameArray.last){
            self.teamNameLabel.text = self.teamNameArray[self.currentArrayIndex]
            self.rightScrollImageView.image = rightArrowImage
            self.rightScrollImageView.alpha = 0.5
            self.leftScrollImageView.image = leftArrowImage
            self.leftScrollImageView.alpha = 1
            self.leftScrollImageView.setNeedsDisplay()
            self.rightScrollImageView.setNeedsDisplay()
            // set player name array for picker view based on user swipe selection
            // and refresh player name picker view
            playerNameArray = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "activeState == %@ AND TeamID == %@", NSNumber(value: true), String(awayTeamID))).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)}))
            playerIdArray = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "activeState == %@ AND TeamID == %@", NSNumber(value: true), String(awayTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)}))
            self.playerNamePicker.reloadAllComponents()
            
        }else if (self.teamNameArray[self.currentArrayIndex] == self.teamNameArray.first){
            self.teamNameLabel.text = self.teamNameArray[self.currentArrayIndex]
            self.rightScrollImageView.image = rightArrowImage
            self.rightScrollImageView.alpha = 1
            self.leftScrollImageView.image = leftArrowImage
            self.leftScrollImageView.alpha = 0.5
            self.leftScrollImageView.setNeedsDisplay()
            self.rightScrollImageView.setNeedsDisplay()
            // set player name array for picker view based on user swipe selection
             // and refresh player name picker view
            playerNameArray = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "activeState == %@ AND TeamID == %@", NSNumber(value: true), String(homeTeamID))).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)}))
            playerIdArray = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "activeState == %@ AND TeamID == %@", NSNumber(value: true), String(homeTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)}))
            self.playerNamePicker.reloadAllComponents()
        }
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.left:
                print("Left Swipe Detected")
                if teamNameArray[currentArrayIndex] == teamNameArray.first{
                    currentArrayIndex += 1
                    
                }else if teamNameArray[currentArrayIndex] == teamNameArray.last{
                    currentArrayIndex = teamNameArray.count - 1
                    
                }else{
                    currentArrayIndex += 1
                }
                DispatchQueue.main.async {
                    self.scrollArrowProccessing()
                }
                selectedTeamID = teamIdArray[currentArrayIndex]
                teamNameLabel.text = teamNameArray[currentArrayIndex]
                print("Current Array Index: ",  currentArrayIndex)
                
            case UISwipeGestureRecognizer.Direction.right:
                print("Right Swipe Detected")
                if teamNameArray[currentArrayIndex] == teamNameArray.last{
                    currentArrayIndex -= 1
                    
                }else if teamNameArray[currentArrayIndex] == teamNameArray.first{
                    currentArrayIndex = 0
                    
                }else{
                    currentArrayIndex -= 1
                }
                DispatchQueue.main.async {
                    self.scrollArrowProccessing()
                }
                selectedTeamID = teamIdArray[currentArrayIndex]
                teamNameLabel.text = teamNameArray[currentArrayIndex]
                print("Current Array Index: ",  currentArrayIndex)
            default:
                break
            }
            
        }
    }
    @IBAction func cancelButton(_ sender: UIButton) {
         performSegue(withIdentifier: "backToIcePenalty", sender: nil)
    }
    
    @IBAction func addPenaltyButton(_ sender: UIButton) {
        
            try! realm.write{
                if (realm.objects(penaltyTable.self).max(ofProperty: "penaltyID") as Int? != nil){
                    primaryID = (realm.objects(penaltyTable.self).max(ofProperty: "penaltyID") as Int? ?? 0) + 1;
                }else{
                    primaryID = (realm.objects(penaltyTable.self).max(ofProperty: "penaltyID") as Int? ?? 0);
                }
                let currentGameID = realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?
                
                realm.create(penaltyTable.self, value: ["penaltyID": primaryID!, "gameID": currentGameID!]);
                let penaltyTableID = realm.object(ofType: penaltyTable.self, forPrimaryKey: primaryID!);
                
                // write vars to realm on save button click
                penaltyTableID?.playerID = selectedPlayerID
                penaltyTableID?.gameID = currentGameID!
                penaltyTableID?.teamID = selectedTeamID
                penaltyTableID?.penaltyType = selectedPenaltyType
                penaltyTableID?.timeOfOffense = stringToDate.stringToDateFormatter(unformattedString: gluedTime)
                penaltyTableID?.xCord = tempXCords
                penaltyTableID?.yCord = tempYCords
                penaltyTableID?.activeState = true
                
            }
        let dictionary = ["key":"value"]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "shotLocationRefresh"), object: nil, userInfo: dictionary)
        performSegue(withIdentifier: "backToIcePenalty", sender: nil)
        
    }
    //----------------------------------------------------------------------------------------------------------
    // Picker View Functions for Main Player and Assitant Picking
    // Number of columns of data
    func numberOfComponents(in numberOfComponents: UIPickerView) -> Int  {
        
        if (numberOfComponents == penaltyTimePicker){
            
            return 3;
        }else{
            
            return 1;
        }
        
    }
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == penaltyTypePicker){
            return penaltyType.count
            
        }else if (pickerView == playerNamePicker){
            return playerNameArray.count
        }else{
            return timePickerValues[0].count
        }
    }
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if (pickerView == penaltyTypePicker){
            
            return penaltyType[row];
        }else if (pickerView == playerNamePicker){
            return playerNameArray[row]
        }else{
            if(component == 0){
                return timePickerValues[0][row];
            }else if (component == 1){
                return timePickerValues[1][row];
            }else{
                return timePickerValues[2][row]
            }
            // return number of players associated with said team picked
        }
        
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        if (pickerView == penaltyTypePicker){
            selectedPenaltyType = penaltyType[row]
        }else if (pickerView == playerNamePicker){
            selectedPlayerID = playerIdArray[row]
        } else{
            if(component == 0){
                selectedFirstMinuteValue = timePickerValues[0][row]
            }else if (component == 1){
                selectedSecMinuteValue = timePickerValues[1][row]
            }else{
                selectedFirstSecondsValue = timePickerValues[2][row]
                
            }
            gluedTime = "00:\(selectedFirstMinuteValue!)\(selectedSecMinuteValue!):\(selectedFirstSecondsValue!)0"
            print("Glueed TIme", gluedTime)
        }
    }
   
        
      //______________________________________________________________________________________________________________

   
}
