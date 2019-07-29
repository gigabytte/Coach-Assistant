//
//  Team_Selection_View.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-01-29.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class Team_Selection_View: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, UIPopoverPresentationControllerDelegate {
    
    let realm = try! Realm()
    
    // decalre vars for primary key handling in terms of realm
    var primaryNewGameKey: Int = 0;
    var primaryGoalMarkerKey: Int = 0;
    var primaryShotMarkerKey:Int = 0;
    var selectedHomeTeamKey:Int = 0;
    var selectedAwayTeamKey:Int = 0;
    var currentArrayIndex: Int = 0
    var selectedGameType: String!
    var gameTypeStringArray: [String] = [String]()
    
    let leftArrowImage = UIImage(named: "left_scroll_arrow")
    let rightArrowImage = UIImage(named: "right_scroll_arrow")
    
    // refrence to home and away pickerviews
    @IBOutlet weak var defaultHomeTeamLabel: UILabel!
    @IBOutlet weak var awayTeamPickerView: UIPickerView!
    @IBOutlet weak var teamSelectionErrorText: UILabel!
    @IBOutlet weak var leftScrollArrowImage: UIImageView!
    @IBOutlet weak var rightScrollArrowImage: UIImageView!
    @IBOutlet weak var gameTypeLabel: UILabel!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var gameLocationTextField: UITextField!
    
    // vars for away team data retrieval from Realm
    var awayTeamPickerData: [String] = [String]()
    var awayTeamPickerDataID: [Int] = [Int]()
    var selectedAwayTeam: String = ""
    
    //refrence to popup view
    @IBOutlet weak var teamSelectionPopUpView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        selectedHomeTeamKey = (UserDefaults.standard.object(forKey: "defaultHomeTeamID") as! Int)
        
        bottomRoundedCorners(buttonName: cancelButton)
        bottomRoundedCorners(buttonName: continueButton)
        // add blur effect to view along with popUpView
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.addSubview(popUpView)       
 
        gameTypeGesture()
        
        // increment primary ID of each type based on new game initialization
        if (realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int? != nil){
            primaryNewGameKey = (realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int? ?? 0) + 1;
            primaryGoalMarkerKey = (realm.objects(goalMarkersTable.self).max(ofProperty: "cordSetID") as Int? ?? 0) + 1;
            primaryShotMarkerKey = (realm.objects(shotMarkerTable.self).max(ofProperty: "cordSetID") as Int? ?? 0) + 1
        }else{
            primaryNewGameKey = (realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int? ?? 0);
            primaryGoalMarkerKey = (realm.objects(goalMarkersTable.self).max(ofProperty: "cordSetID") as Int? ?? 0);
            primaryShotMarkerKey = (realm.objects(shotMarkerTable.self).max(ofProperty: "cordSetID") as Int? ?? 0);
        }
        
        self.awayTeamPickerView.delegate = self
        self.awayTeamPickerView.dataSource = self
        
        awayTeamPickerData = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "activeState == %@", NSNumber(value: true))).value(forKeyPath: "nameOfTeam") as! [String]).compactMap({String($0)})
        awayTeamPickerDataID = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "activeState == %@", NSNumber(value: true))).value(forKeyPath: "teamID") as! [Int]).compactMap({Int($0)})
        
        //round corners with a radius of 10 for popup view so my eyes dont bleed!
        teamSelectionPopUpView.layer.cornerRadius = 10
        
        // default home team and away team selection
        let homeTeamName = ((realm.objects(teamInfoTable.self).filter(NSPredicate(format: "teamID == %i AND activeState == %@", selectedHomeTeamKey, NSNumber(value: true))).value(forKeyPath: "nameOfTeam") as! [String]).compactMap({String($0)})).first
        defaultHomeTeamLabel.text = "\(homeTeamName!) Vs"
        selectedAwayTeam = awayTeamPickerData[0]
        selectedAwayTeamKey = awayTeamPickerDataID[0]
        //hide team selectionn error by default
        teamSelectionErrorText.isHidden = true
        
    }
    
    // if keyboard is out push whole view up half the height of the keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height / 4)
                //self.popUpView.frame.origin.y -= (keyboardSize.height / 4)
            }
        }
    }
    // when keybaord down return view back to y orgin of 0
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
           // self.popUpView.frame.origin.y = 0
        }
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
    
    func gameTypeProcessing(){
        if (self.gameTypeStringArray[self.currentArrayIndex] == self.gameTypeStringArray.last){
            self.gameTypeLabel.text = self.gameTypeStringArray[self.currentArrayIndex]
            self.rightScrollArrowImage.image = rightArrowImage
            self.rightScrollArrowImage.alpha = 0.5
            self.leftScrollArrowImage.image = leftArrowImage
            self.leftScrollArrowImage.alpha = 1
            self.leftScrollArrowImage.setNeedsDisplay()
            self.rightScrollArrowImage.setNeedsDisplay()
        }else if (self.gameTypeStringArray[self.currentArrayIndex] == self.gameTypeStringArray.first){
            self.gameTypeLabel.text = self.gameTypeStringArray[self.currentArrayIndex]
            self.rightScrollArrowImage.image = rightArrowImage
            self.rightScrollArrowImage.alpha = 1
            self.leftScrollArrowImage.image = leftArrowImage
            self.leftScrollArrowImage.alpha = 0.5
            self.leftScrollArrowImage.setNeedsDisplay()
            self.rightScrollArrowImage.setNeedsDisplay()
        }
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.left:
                print("Left Swipe Detected")
                if gameTypeStringArray[currentArrayIndex] == gameTypeStringArray.first{
                    currentArrayIndex += 1
                    
                }else if gameTypeStringArray[currentArrayIndex] == gameTypeStringArray.last{
                    currentArrayIndex = gameTypeStringArray.count - 1
                    
                }else{
                    currentArrayIndex += 1
                }
                DispatchQueue.main.async {
                    self.gameTypeProcessing()
                }
                gameTypeLabel.text = gameTypeStringArray[currentArrayIndex]
                selectedGameType = gameTypeStringArray[currentArrayIndex]
                print("Current Array Index: ",  currentArrayIndex)
            
            case UISwipeGestureRecognizer.Direction.right:
                print("Right Swipe Detected")
                if gameTypeStringArray[currentArrayIndex] == gameTypeStringArray.last{
                    currentArrayIndex -= 1
                    
                }else if gameTypeStringArray[currentArrayIndex] == gameTypeStringArray.first{
                    currentArrayIndex = 0
                    
                }else{
                    currentArrayIndex -= 1
                }
                DispatchQueue.main.async {
                    self.gameTypeProcessing()
                }
                gameTypeLabel.text = gameTypeStringArray[currentArrayIndex]
                selectedGameType = gameTypeStringArray[currentArrayIndex]
                print("Current Array Index: ",  currentArrayIndex)
            default:
                break
            }
            
        }
    }
    func gameTypeGesture() {
        
        gameTypeStringArray = ["Regular Season", "Playoff", "Exhibition", "Tournament", "Practice"]
        selectedGameType = gameTypeStringArray[0]
        gameTypeLabel.text = "Game Type: " + gameTypeStringArray[0]
        self.leftScrollArrowImage.image = leftArrowImage
        self.leftScrollArrowImage.alpha = 0.5
        self.leftScrollArrowImage.setNeedsDisplay()
        
        teamSelectionPopUpView.isUserInteractionEnabled = true
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        teamSelectionPopUpView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        teamSelectionPopUpView.addGestureRecognizer(swipeLeft)
    }
    
    func doubleHomeTeamAlert(errorMessage: String){
        //produce shake animation on error of double home team
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.06
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = CGPoint(x: teamSelectionPopUpView.center.x - 10, y: teamSelectionPopUpView.center.y)
        animation.toValue = CGPoint(x: teamSelectionPopUpView.center.x + 10, y: teamSelectionPopUpView.center.y)
        teamSelectionPopUpView.layer.add(animation, forKey: "position")
        teamSelectionErrorText.textColor = UIColor.red
        teamSelectionErrorText.text = errorMessage
    }
    
    @IBAction func continueTeamSelectionButton(_ sender: UIButton) {
        if (teamPlayerGoalieChecker(homeKey: selectedHomeTeamKey, awayKey: selectedAwayTeamKey) != false && (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == %@",String(selectedAwayTeamKey), NSNumber(value: true))).value(forKeyPath: "playerID") as! [Int]).compactMap({String($0)}).count != 0 && (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == %@",String(selectedHomeTeamKey), NSNumber(value: true))).value(forKeyPath: "playerID") as! [Int]).compactMap({String($0)}).count != 0){
            
            if (selectedHomeTeamKey != selectedAwayTeamKey){
               
                if(gameLocationTextField.text != ""){
                     // if home team and away team are not the same proceed with regular segue to New Game Page
                    // and game location is not left blank procceed
                    newGameUserDefaultGen().userDefaults()
                    UserDefaults.standard.set(true, forKey: "newGameStarted")
    
                    animateOut()
                    continueTeamSelection()
                }else{
                    // enable team election error text from hidden to appear
                    teamSelectionErrorText.isHidden = false
                    doubleHomeTeamAlert(errorMessage: "Whoops! Please Add a Location to Your Game")
                }
            }else{
                // enable team election error text from hidden to appear
                teamSelectionErrorText.isHidden = false
                // if home team and away team are the same value run alert
                doubleHomeTeamAlert(errorMessage: "Please select two DIFFERENT teams")
                
            }
        }else{
            doubleHomeTeamAlert(errorMessage: "Please make sure both teams have a player and goalie minimum")
            self.teamSelectionErrorText.isHidden = false
            self.teamSelectionErrorText.textAlignment = .center
            self.teamSelectionErrorText.textColor = UIColor.red
        }
    }
    
    @IBAction func cancelTeamSelectionButton(_ sender: UIButton) {
        animateOut()
        self.performSegue(withIdentifier: "Go_Back_Home_Segue", sender: nil);
    }
    
    // on animateIn display popUpview over top of New Game View
    func animateIn(){
        
        print("popUpView has been animated in")
        self.view.addSubview(teamSelectionPopUpView)
        teamSelectionPopUpView.center = self.view.center
        
        
        teamSelectionPopUpView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        teamSelectionPopUpView.alpha = 0
        
        // set animation results
        UIView.animate(withDuration: 0.4){
            
            self.teamSelectionPopUpView.alpha = 1
            self.teamSelectionPopUpView.transform = CGAffineTransform.identity
        }
        
    }
    // on animateOut tear down popUpview over top of New Game View
    func animateOut(){
        
        UIView.animate(withDuration: 0.3, animations: {
            self.teamSelectionPopUpView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            self.teamSelectionPopUpView.alpha = 0
            // omn sucess of popup tear down remove popUpView from super view
        })  { (success: Bool) in
            
            self.teamSelectionPopUpView.removeFromSuperview()
            
        }
        
        print("popUpView has been Teared Down")
    }
    
    //-------------------------------------------------------------------------------
    // Picker View Functions for Home and Away Team Picking
    // Number of columns of data
    func numberOfComponents(in homeTeamPickerView: UIPickerView) -> Int  {
        return 1;
    }
    // height of picker views defined here
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30.0
    }
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return awayTeamPickerData.count;
     
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        return awayTeamPickerData[row];
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        teamSelectionErrorText.isHidden = true
        selectedAwayTeam = awayTeamPickerData[row]
        selectedAwayTeamKey = awayTeamPickerDataID[row]
        print("Away Team Selected" + selectedAwayTeam + " " + String(selectedAwayTeamKey))
      
        
    }
    
    func teamPlayerGoalieChecker(homeKey: Int, awayKey: Int) -> Bool{
        let playerOne = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType != %@ AND activeState == %@", String(homeKey), "G" , NSNumber(value: true))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
       let goalieOne = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType == %@ AND activeState == %@", String(awayKey), "G" , NSNumber(value: true))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        if (playerOne.first != nil && goalieOne.first != nil && playerOne.first != goalieOne.last){
            
            return true
        }else{
            return false
        }
    }
    
    
    
    func continueTeamSelection(){
        
        try! realm.write() {
            realm.create(newGameTable.self, value: ["gameID": self.primaryNewGameKey, "dateGamePlayed": Date(), "opposingTeamID": self.selectedAwayTeamKey, "homeTeamID": self.selectedHomeTeamKey, "gameType": selectedGameType, "gameLocation": gameLocationTextField.text!, "activeGameStatus": true, "activeState": true]);
            
            let primaryHomePlayerID = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ && activeState == %@", String(selectedHomeTeamKey),NSNumber(value: true))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
            let primaryAwayPlayerID = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ && activeState == %@", String(selectedAwayTeamKey),NSNumber(value: true))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
            
            for i in 0..<primaryHomePlayerID.count {
                var primaryID: Int!
                if (self.realm.objects(overallStatsTable.self).max(ofProperty: "overallStatsID") as Int? != nil){
                    primaryID = (self.realm.objects(overallStatsTable.self).max(ofProperty: "overallStatsID") as Int? ?? 0) + 1;
                }else{
                    primaryID = (self.realm.objects(overallStatsTable.self).max(ofProperty: "overallStatsID") as Int? ?? 0);
                }
                self.realm.create(overallStatsTable.self, value: ["overallStatsID": primaryID])
                let primaryCurrentStatID = self.realm.object(ofType: overallStatsTable.self, forPrimaryKey: primaryID)
                
                primaryCurrentStatID?.playerID = primaryHomePlayerID[i];
                primaryCurrentStatID?.gameID = primaryNewGameKey;
                primaryCurrentStatID?.lineNum = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i && activeState == %@", primaryHomePlayerID[i],NSNumber(value: true))).value(forKeyPath: "lineNum") as! [Int]).compactMap({Int($0)}).first!
                primaryCurrentStatID?.activeState = true
                
            }
            for i in 0..<primaryAwayPlayerID.count {
                var primaryID: Int!
                primaryID = (self.realm.objects(overallStatsTable.self).max(ofProperty: "overallStatsID") as Int? ?? 0) + 1;
                
                self.realm.create(overallStatsTable.self, value: ["overallStatsID": primaryID])
                let primaryCurrentStatID = self.realm.object(ofType: overallStatsTable.self, forPrimaryKey: primaryID)
                
                primaryCurrentStatID?.playerID = primaryAwayPlayerID[i];
                primaryCurrentStatID?.gameID = primaryNewGameKey;
                primaryCurrentStatID?.lineNum = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i && activeState == %@", primaryAwayPlayerID[i],NSNumber(value: true))).value(forKeyPath: "lineNum") as! [Int]).compactMap({Int($0)}).first!
                primaryCurrentStatID?.activeState = true
                
            }
            
        }
        let tempHomeTeamID = (self.realm.object(ofType: newGameTable.self, forPrimaryKey: primaryNewGameKey)?.homeTeamID)!
        let tempAwayTeamID = (self.realm.object(ofType: newGameTable.self, forPrimaryKey: primaryNewGameKey)?.opposingTeamID)!
        UserDefaults.standard.set(tempHomeTeamID, forKey: "homeTeam")
        UserDefaults.standard.set(tempAwayTeamID, forKey: "awayTeam")
        UserDefaults.standard.set(primaryNewGameKey, forKey: "gameID")
       
        self.performSegue(withIdentifier: "continueTeamSelectionSegue", sender: nil);
    }
    
}
