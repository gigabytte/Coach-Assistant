//
//  Faceoff View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-06-19.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class Faceoff_View_Controller: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var rightScrollImageView: UIImageView!
    @IBOutlet weak var leftScrollImageView: UIImageView!
    @IBOutlet weak var playerNamePicker: UIPickerView!
    @IBOutlet weak var opposingPlayerNamePicker: UIPickerView!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var tempXCords: Int!
    var tempYCords: Int!
    
    var homeTeamID: Int = UserDefaults.standard.integer(forKey: "homeTeam")
    var awayTeamID: Int = UserDefaults.standard.integer(forKey: "awayTeam")
    var teamNameArray: [String] = [String]()
    var teamIdArray: [Int] = [Int]()
    var currentArrayIndex: Int = 0
    var selectedTeamID: Int!
    var opposite_selectedTeamID: Int!
    var primaryID:Int!
    var playerNameArray: [String] = [String]()
    var playerIdArray: [Int] = [Int]()
    var opposing_playerNameArray: [String] = [String]()
    var opposing_playerIdArray: [Int] = [Int]()
    var winner_selectedPlayerID: Int!
    var loser_selectedPlayerID: Int!
    var faceoffLocation: Int!
    var periodNum: Int = UserDefaults.standard.integer(forKey: "periodNumber")
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // add blur effect to view along with popUpView
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.addSubview(popUpView)
        
        
        popUpView.layer.cornerRadius = 10
        roundedCorners().buttonBottomLeft(bottonViewType: cancelButton)
        roundedCorners().buttonBottomRight(bottonViewType: saveButton)
        roundedCorners().labelViewTopLeftRight(labelViewType: titleLabel)
        
        swipeGestureInitializer()
        titleProcessing()
        
        selectedTeamID = teamIdArray.first
        
        // Data Connections for picker views:
        self.playerNamePicker.delegate = self
        self.playerNamePicker.dataSource = self
        
        self.opposingPlayerNamePicker.delegate = self
        self.opposingPlayerNamePicker.dataSource = self
       
        // set default player names for home team to be used in picker
        playerNameArray = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "activeState == %@ AND TeamID == %@", NSNumber(value: true), String(selectedTeamID))).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)}))
        // set default player Id for home team to ve used in picker
        playerIdArray = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "activeState == %@ AND TeamID == %@", NSNumber(value: true), String(selectedTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)}))
        
        // set default player names for home team to be used in picker
        opposing_playerNameArray = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "activeState == %@ AND TeamID == %@", NSNumber(value: true), String(teamIdArray[1]))).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)}))
        // set default player Id for home team to ve used in picker
        opposing_playerIdArray = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "activeState == %@ AND TeamID == %@", NSNumber(value: true), String(teamIdArray[1]))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)}))
        
        // var defaults
        winner_selectedPlayerID = playerIdArray.first
        loser_selectedPlayerID = opposing_playerIdArray.first
        
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        
        // segue back to ice surface
        performSegue(withIdentifier: "fromFaceoffSegue", sender: nil)
    }
    

    @IBAction func saveButton(_ sender: UIButton) {
        
        // add stat and segue back to ice surface
        try! realm.write{
            if (realm.objects(faceOffInfoTable.self).max(ofProperty: "faceoffID") as Int? != nil){
                primaryID = (realm.objects(faceOffInfoTable.self).max(ofProperty: "faceoffID") as Int? ?? 0) + 1;
            }else{
                primaryID = (realm.objects(faceOffInfoTable.self).max(ofProperty: "faceoffID") as Int? ?? 0);
            }
            let currentGameID = realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?
            
            realm.create(faceOffInfoTable.self, value: ["faceoffID": primaryID!, "gameID": currentGameID!]);
            let faceoffTableID = realm.object(ofType: faceOffInfoTable.self, forPrimaryKey: primaryID!);
            
            faceoffTableID?.gameID = currentGameID!
            faceoffTableID?.winingPlayerID = winner_selectedPlayerID
            faceoffTableID?.losingPlayerID = loser_selectedPlayerID
            faceoffTableID?.periodNum = periodNum
            faceoffTableID?.faceoffLocationCode = faceoffLocation
            faceoffTableID?.activeState = true
        }
        
        
        let dictionary = ["key":"value"]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "shotLocationRefresh"), object: nil, userInfo: dictionary)
        performSegue(withIdentifier: "fromFaceoffSegue", sender: nil)
        
    }
    
    
    func oppositeTeamID(mainTeamID: Int) -> Int{
        
        let location = teamIdArray.firstIndex(of: mainTeamID)
        
        if location == 0{
            return(teamIdArray[1])
        }else{
            return(teamIdArray[0])
        }
    
    }
    
    func titleProcessing(){
        
        switch faceoffLocation {
        case 1:
            titleLabel.text = "Top Left Circle Faceoff"
        case 2:
            titleLabel.text = "Top Right Circle Faceoff"
        case 3:
            titleLabel.text = "Center Ice Faceoff"
        case 4:
            titleLabel.text = "Bottom Left Circle Faceoff"
        case 5:
            titleLabel.text = "Bottom Right Circle Faceoff"
        default:
            titleLabel.text = "Generic Faceoff"
        }
    }
    
    func swipeGestureInitializer() {
        
        // get names of teams from current game
        teamNameArray.append(((realm.objects(teamInfoTable.self).filter(NSPredicate(format: "activeState == %@ AND teamID == %i", NSNumber(value: true), homeTeamID)).value(forKeyPath: "nameOfTeam") as! [String]).compactMap({String($0)})).first!)
        teamNameArray.append(((realm.objects(teamInfoTable.self).filter(NSPredicate(format: "activeState == %@ AND teamID == %i", NSNumber(value: true), awayTeamID)).value(forKeyPath: "nameOfTeam") as! [String]).compactMap({String($0)})).first!)
        
        teamIdArray.append(homeTeamID)
        teamIdArray.append(awayTeamID)
        
        selectedTeamID = teamIdArray.first!
        teamNameLabel.text = "Select Team: \(teamNameArray.first!)"
        self.leftScrollImageView.alpha = 0.5
        self.leftScrollImageView.setNeedsDisplay()
        
        popUpView.isUserInteractionEnabled = true
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        popUpView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        popUpView.addGestureRecognizer(swipeLeft)
    }
    
    func scrollArrowProccessing(){
        if (self.teamNameArray[self.currentArrayIndex] == self.teamNameArray.last){
            self.teamNameLabel.text = self.teamNameArray[self.currentArrayIndex]
            self.rightScrollImageView.alpha = 0.5
            self.leftScrollImageView.alpha = 1
            self.leftScrollImageView.setNeedsDisplay()
            self.rightScrollImageView.setNeedsDisplay()
            // set player name array for picker view based on user swipe selection
            // and refresh player name picker view
            playerNameArray = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "activeState == %@ AND TeamID == %@", NSNumber(value: true), String(awayTeamID))).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)}))
            playerIdArray = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "activeState == %@ AND TeamID == %@", NSNumber(value: true), String(awayTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)}))
            opposing_playerNameArray = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "activeState == %@ AND TeamID == %@", NSNumber(value: true), String(homeTeamID))).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)}))
            opposing_playerIdArray = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "activeState == %@ AND TeamID == %@", NSNumber(value: true), String(homeTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)}))
            self.playerNamePicker.reloadAllComponents()
            self.opposingPlayerNamePicker.reloadAllComponents()
            // var defaults
            winner_selectedPlayerID = playerIdArray.first
            loser_selectedPlayerID = opposing_playerIdArray.first
            
        }else if (self.teamNameArray[self.currentArrayIndex] == self.teamNameArray.first){
            self.teamNameLabel.text = self.teamNameArray[self.currentArrayIndex]
            self.rightScrollImageView.alpha = 1
            self.leftScrollImageView.alpha = 0.5
            self.leftScrollImageView.setNeedsDisplay()
            self.rightScrollImageView.setNeedsDisplay()
            // set player name array for picker view based on user swipe selection
            // and refresh player name picker view
            playerNameArray = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "activeState == %@ AND TeamID == %@", NSNumber(value: true), String(homeTeamID))).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)}))
            playerIdArray = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "activeState == %@ AND TeamID == %@", NSNumber(value: true), String(homeTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)}))
            opposing_playerNameArray = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "activeState == %@ AND TeamID == %@", NSNumber(value: true), String(awayTeamID))).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)}))
            opposing_playerIdArray = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "activeState == %@ AND TeamID == %@", NSNumber(value: true), String(awayTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)}))
            self.opposingPlayerNamePicker.reloadAllComponents()
            self.playerNamePicker.reloadAllComponents()
            // var defaults
            winner_selectedPlayerID = playerIdArray.first
            loser_selectedPlayerID = opposing_playerIdArray.first
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
                opposite_selectedTeamID = oppositeTeamID(mainTeamID: selectedTeamID)
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
                opposite_selectedTeamID = oppositeTeamID(mainTeamID: selectedTeamID)
                teamNameLabel.text = teamNameArray[currentArrayIndex]
                print("Current Array Index: ",  currentArrayIndex)
            default:
                break
            }
            
        }
    }
    
    func numberOfComponents(in numberOfComponents: UIPickerView) -> Int  {
        
        return 1;
  
    }
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == playerNamePicker{
            return playerNameArray.count
        }else{
            return opposing_playerNameArray.count
        }
        
       
    }
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if (pickerView == playerNamePicker){
            return playerNameArray[row]
        }else{
            return opposing_playerNameArray[row]
        }
        
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        if pickerView == playerNamePicker{
            winner_selectedPlayerID = playerIdArray[row]
        }else{
            loser_selectedPlayerID = opposing_playerIdArray[row]
        }
        
    }
    
    
    //______________________________________________________________________________________________________________
    
    
    
}
