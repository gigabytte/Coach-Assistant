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

class Team_Selection_View: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate {
    
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
    @IBOutlet weak var homeTeamPickerView: UIPickerView!
    @IBOutlet weak var awayTeamPickerView: UIPickerView!
    @IBOutlet weak var teamSelectionErrorText: UILabel!
    @IBOutlet weak var leftScrollArrowImage: UIImageView!
    @IBOutlet weak var rightScrollArrowImage: UIImageView!
    @IBOutlet weak var gameTypeLabel: UILabel!
    
    //let realm = try! Realm()
    // vars for home team data retrieval from Realm
    var homeTeamPickerData:Results<teamInfoTable>!
    var homeTeamValueSelected:[teamInfoTable] = []
    var selectedHomeTeam: String = ""
    
    // vars for away team data retrieval from Realm
    var awayTeamPickerData:Results<teamInfoTable>!
    var awayTeamValueSelected:[teamInfoTable] = []
    var selectedAwayTeam: String = ""
    
    //refrence to popup view
    @IBOutlet weak var teamSelectionPopUpView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // MUST SET ON EACH VIEW DEPENDENT ON ORIENTATION NEEDS
        // get rotation allowances of device
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // set auto rotation to false
        appDelegate.shouldRotate = true
 
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
        
        // Data Connections for picker views:
        self.homeTeamPickerView.delegate = self
        self.homeTeamPickerView.dataSource = self
        
        self.awayTeamPickerView.delegate = self
        self.awayTeamPickerView.dataSource = self
        
        // data translation from realm to local view controller array
        self.homeTeamPickerData =  realm.objects(teamInfoTable.self)
        self.homeTeamValueSelected = Array(self.homeTeamPickerData)
        
        self.awayTeamPickerData =  realm.objects(teamInfoTable.self)
        self.awayTeamValueSelected = Array(self.awayTeamPickerData)
        
        //round corners with a radius of 10 for popup view so my eyes dont bleed!
        teamSelectionPopUpView.layer.cornerRadius = 10
        
        // default home team and away team selection
        selectedHomeTeam = String(homeTeamValueSelected[0].nameOfTeam)
        selectedAwayTeam = String(awayTeamValueSelected[0].nameOfTeam)
        //hide team selectionn error by default
        teamSelectionErrorText.isHidden = true
        
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
    
    func doubleHomeTeamAlert(){
        //produce shake animation on error of double home team
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.06
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = CGPoint(x: teamSelectionPopUpView.center.x - 10, y: teamSelectionPopUpView.center.y)
        animation.toValue = CGPoint(x: teamSelectionPopUpView.center.x + 10, y: teamSelectionPopUpView.center.y)
        teamSelectionPopUpView.layer.add(animation, forKey: "position")
        // enable team election error text from hidden to appear
        teamSelectionErrorText.isHidden = false
    }
    
    @IBAction func continueTeamSelectionButton(_ sender: UIButton) {
        if (selectedHomeTeam != selectedAwayTeam){
            // if home team and away team are not the same proceed with regular segue to New Game Page
            animateOut()
            continueTeamSelection()
        }else{
            // if home team and away team are the same value run alert
            doubleHomeTeamAlert()
        }
    }
    
    @IBAction func cancelTeamSelectionButton(_ sender: UIButton) {
        animateOut()
        self.performSegue(withIdentifier: "cancelTeamSelectionSegue", sender: nil);
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
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //return homeTeamValueSelected.count;
        if (pickerView == homeTeamPickerView){
            return homeTeamValueSelected.count;
        }else{
            
           return awayTeamValueSelected.count;
        }
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        if (pickerView == homeTeamPickerView){
            return homeTeamValueSelected[row].nameOfTeam;
        }else{
            
            return awayTeamValueSelected[row].nameOfTeam;
        }
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        if (pickerView == homeTeamPickerView){
            teamSelectionErrorText.isHidden = true
            selectedHomeTeam = homeTeamValueSelected[row].nameOfTeam;
            selectedHomeTeamKey = homeTeamValueSelected[row].teamID;
            print("Home Team Selected" + selectedHomeTeam + " " + String(selectedHomeTeamKey));
        }else{
            teamSelectionErrorText.isHidden = true
            selectedAwayTeam = awayTeamValueSelected[row].nameOfTeam;
            selectedAwayTeamKey = awayTeamValueSelected[row].teamID;
            print("Away Team Selected" + selectedAwayTeam + " " + String(selectedAwayTeamKey));
            //awayTeamValueSelected= awayTeamPickerData[row];
        }
        
    }
    // func used to pass varables on segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check is appropriate segue is being used
        if (segue.identifier == "continueTeamSelectionSegue"){
            // set var vc as destination segue
            let vc = segue.destination as! New_Game_Page
            vc.newGameStarted = true
        }
    }
    
    func continueTeamSelection(){
        
        try! realm.write() {
            var primaryNewGameKey = realm.create(newGameTable.self, value: ["gameID": self.primaryNewGameKey, "dateGamePlayed": Date(), "opposingTeamID": self.selectedAwayTeamKey, "homeTeamID": self.selectedHomeTeamKey, "gameType": selectedGameType, "activeGameStatus": true, "activeState": true]);
        }
        self.performSegue(withIdentifier: "continueTeamSelectionSegue", sender: nil);
    }
}
