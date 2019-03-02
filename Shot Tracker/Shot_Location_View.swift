//
//  Shot_Location_View.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-01-24.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class Shot_Location_View: UIViewController {
    
    
    // pop view controler assigned to popupview var along with blur visual effect
    @IBOutlet var popUpView: UIView!
    @IBOutlet weak var shotLocationPopUp: UIView!
    @IBOutlet weak var goalieNumberLabel: UILabel!
    @IBOutlet weak var hockeyNetImageView: UIImageView!
    @IBOutlet weak var tapLocationSelectionErrorLabel: UILabel!
    @IBOutlet weak var leftScrollArrowImage: UIImageView!
    @IBOutlet weak var rightScrollArrowImage: UIImageView!
    
    let hockeyNetBasic = UIImage(named: "hockey_net_basic_shot.PNG")
    let hockeyNetTopLeft = UIImage(named: "hockey_net_top_left.PNG")
    let hockeyNetTopRight = UIImage(named: "hockey_net_top_right.PNG")
    let hockeyNetBottomLeft = UIImage(named: "hockey_net_bottom_left.PNG")
    let hockeyNetBottomRight = UIImage(named: "hockey_net_bottom_right.PNG")
    let hockeyNetCenter = UIImage(named: "hockey_net_center.PNG")
    let hockeyNetAwayTeam = UIImage(named: "hockey_net_away_goalie.PNG")
    var leftArrowImage = UIImage(named: "left_scroll_arrow")
    var rightArrowImage = UIImage(named: "right_scroll_arrow")
    
    var shotLocationValueSelected: Int!;
    var goalieNumberArray: [String] = [String]()
    
    var tempXCords: Int = 0
    var tempYCords: Int = 0
    var homeTeamID: Int!
    var awayTeamID: Int!
    var tempGoalieSelectedID: Int!
    var goalieSelectedID: Int!
    var selectedGoalieIDArray: [Int] = [Int]()
    var universalGoalieIDArray: [Int] = [Int]()
    var realmSelectTeamID: Int!
    var periodNumSelected: Int!
    var currentArrayIndex: Int = 0
    var homeTeamGoalieIndex: Int = 0
    
    var tempMarkerType: Bool!
    
    var topLeft: CGRect?
    var topRight: CGRect?
    var bottomLeft: CGRect?
    var bottomRight: CGRect?
    var middleCenter: CGRect?
    
    var shot_primaryID: Int!
    
    var realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goalieSelectedID = tempGoalieSelectedID
        if (tempMarkerType != true){
            print("You are placing a goal, passed bool is: ", tempMarkerType)
        }else{
            print("You are placing a shot, passed bool is: ", tempMarkerType)
        }
        shotLocationPopUp.layer.cornerRadius = 10
        tapLocationSelectionErrorLabel.isHidden = true
        // Do any additional setup after loading the view.
        
        // MUST SET ON EACH VIEW DEPENDENT ON ORIENTATION NEEDS
        // get rotation allowances of device
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // set auto rotation to false
        appDelegate.shouldRotate = false
        print("goalie id: ", goalieSelectedID)
        // if true its a shot
        if(tempMarkerType != false){
            netImageViewBoundaries()
            goalieSelectionGesture()
            let selectedGoalieJerseyNum = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i", goalieSelectedID)).value(forKeyPath: "jerseyNum") as! [Int]).compactMap({Int($0)})
            print(selectedGoalieJerseyNum)
            self.goalieNumberLabel.text = String(selectedGoalieJerseyNum[0])
            realmSelectTeamID = awayTeamID
        }else{
            netImageViewBoundaries()
            goalieSelectionGesture()
        }
    }
    
    func missingSelectionError(){
        //produce shake animation on error of double home team
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.06
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = CGPoint(x: popUpView.center.x - 10, y: popUpView.center.y)
        animation.toValue = CGPoint(x: popUpView.center.x + 10, y: popUpView.center.y)
        popUpView.layer.add(animation, forKey: "position")
        // enable team election error text from hidden to appear
        tapLocationSelectionErrorLabel.isHidden = false
    }
    
    func netImageViewBoundaries(){
        
        hockeyNetImageView.isUserInteractionEnabled = true
        
        let screenWidth = hockeyNetImageView.frame.width
        print(screenWidth)
        let screenHeight = hockeyNetImageView.frame.height
        print(screenHeight)
        
        topLeft = CGRect(x: screenWidth / 8, y: screenHeight / 8,  width: 80,  height: 80)
        topRight = CGRect(x: (screenWidth / 8) * 5.5, y: screenHeight / 8,  width:80,  height: 80)
        bottomLeft = CGRect(x: screenWidth / 8, y: (screenHeight / 8) * 6,  width: 80,  height:80)
        bottomRight = CGRect(x: ((screenWidth / 8) * 6) - 10, y:  (screenHeight / 8) * 6,  width:80,  height:80)
        middleCenter = CGRect(x: 200, y: 200,  width:80,  height:80)
        // check Tap gestuires for a single tap
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(netLocationSelectionTap));
        // number of taps require 1
        singleTap.numberOfTapsRequired = 1
        hockeyNetImageView.addGestureRecognizer(singleTap)
        
    }
    
    //Function for determining when tap gesture is in/outside of touchable area
    @objc func netLocationSelectionTap(sender: UITapGestureRecognizer){
        let tapPosition = sender.location(in: self.hockeyNetImageView)
        print(tapPosition)
        
        if topLeft!.contains(tapPosition) {
            DispatchQueue.main.async {
                self.hockeyNetImageView.image = self.hockeyNetTopLeft
                self.hockeyNetImageView.setNeedsDisplay()
                self.tapLocationSelectionErrorLabel.isHidden = true
                self.shotLocationValueSelected = 1
            }
            print("Top Left Tap")
        }
        else if(topRight!.contains(tapPosition)) {
            DispatchQueue.main.async {
                self.hockeyNetImageView.image = self.hockeyNetTopRight
                self.hockeyNetImageView.setNeedsDisplay()
                self.shotLocationValueSelected = 2
                self.tapLocationSelectionErrorLabel.isHidden = true
            }
            print("Top Right Tap")
            
        }else if(bottomLeft!.contains(tapPosition)){
            DispatchQueue.main.async {
                self.hockeyNetImageView.image = self.hockeyNetBottomLeft
                self.hockeyNetImageView.setNeedsDisplay()
                self.shotLocationValueSelected = 3
                self.tapLocationSelectionErrorLabel.isHidden = true
            }
            print("Bottom Left Tap")
            
        }else if(bottomRight!.contains(tapPosition)){
            DispatchQueue.main.async {
                self.hockeyNetImageView.image = self.hockeyNetBottomRight
                self.hockeyNetImageView.setNeedsDisplay()
                self.shotLocationValueSelected = 4
                self.tapLocationSelectionErrorLabel.isHidden = true
            }
            print("Bottom Right Tap")
            
        }else if(middleCenter!.contains(tapPosition)){
            DispatchQueue.main.async {
                self.hockeyNetImageView.image = self.hockeyNetCenter
                self.hockeyNetImageView.setNeedsDisplay()
                self.shotLocationValueSelected = 5
                self.tapLocationSelectionErrorLabel.isHidden = true
            }
            print("Middle Tap ")
            
        }else{
            DispatchQueue.main.async {
                self.hockeyNetImageView.image = self.hockeyNetBasic
                self.hockeyNetImageView.setNeedsDisplay()
                self.shotLocationValueSelected = nil
            }
            print("Error! No Tape Detected")
            
        }
    }
    func goalieSelectionGesture() {
        
        let realm = try! Realm()
        // get array of Goalie Jersey Nunbers of Page Load
        if (tempMarkerType != true){
            // if goal marker is placed run code below
            goalieNumberArray = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType == %@", String(homeTeamID!), "G")).value(forKeyPath: "jerseyNum") as! [Int]).compactMap({String($0)})
            let awayTeamGoalieNumberArray = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType == %@", String(awayTeamID!), "G")).value(forKeyPath: "jerseyNum") as! [Int]).compactMap({String($0)})
            goalieNumberArray.append(awayTeamGoalieNumberArray[0])
            print("Goalie Number Array for Goal: ", goalieNumberArray)
        }else{
            goalieNumberArray = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i", goalieSelectedID)).value(forKeyPath: "jerseyNum") as! [Int]).compactMap({String($0)})
            let awayTeamGoalieNumberArray = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType == %@", String(awayTeamID!), "G")).value(forKeyPath: "jerseyNum") as! [Int]).compactMap({String($0)})
            goalieNumberArray.append(awayTeamGoalieNumberArray[0])
            print("Goalie Number Array for Shot: ", goalieNumberArray)
        }
        self.leftScrollArrowImage.image = leftArrowImage
        self.leftScrollArrowImage.alpha = 0.5
        self.leftScrollArrowImage.setNeedsDisplay()
        // set deafult jersey number
        goalieNumberLabel.text = goalieNumberArray[0]
        selectedGoalieIDArray = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "jerseyNum == %i", Int(goalieNumberArray[0])!)).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        goalieSelectedID = selectedGoalieIDArray[0]
        
        hockeyNetImageView.isUserInteractionEnabled = true
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        hockeyNetImageView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        hockeyNetImageView.addGestureRecognizer(swipeLeft)
    }
    

    func goalieTypeProcessing(){

        if (self.goalieNumberArray[self.currentArrayIndex] != self.goalieNumberArray.last){
            self.goalieNumberLabel.text = self.goalieNumberArray[self.currentArrayIndex]
            self.hockeyNetImageView.image = self.hockeyNetBasic
            self.goalieNumberLabel.setNeedsDisplay()
            self.hockeyNetImageView.setNeedsDisplay()
        }else if(self.goalieNumberArray[self.currentArrayIndex] == self.goalieNumberArray.last){
            self.hockeyNetImageView.image = self.hockeyNetAwayTeam
            self.goalieNumberLabel.text = "Away"
            self.goalieNumberLabel.setNeedsDisplay()
            self.hockeyNetImageView.setNeedsDisplay()
            // reset shot location
            shotLocationValueSelected = nil

        }
        if (self.goalieNumberArray[self.currentArrayIndex] == self.goalieNumberArray.last){
            self.rightScrollArrowImage.image = rightArrowImage
            self.rightScrollArrowImage.alpha = 0.5
            self.leftScrollArrowImage.image = leftArrowImage
            self.leftScrollArrowImage.alpha = 1
            self.leftScrollArrowImage.setNeedsDisplay()
            self.rightScrollArrowImage.setNeedsDisplay()
        }else if (self.goalieNumberArray[self.currentArrayIndex] == self.goalieNumberArray.first){
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
            print("Number of goalie jersey numbers: ", goalieNumberArray.count - 1)
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.left:
                print("Left Swipe Detected")
                if goalieNumberArray[currentArrayIndex] == goalieNumberArray.first{
                    currentArrayIndex += 1
                    
                }else if goalieNumberArray[currentArrayIndex] == goalieNumberArray.last{
                    currentArrayIndex = goalieNumberArray.count - 1
                    
                }else{
                    currentArrayIndex += 1
                }
                DispatchQueue.main.async {

                    self.goalieTypeProcessing()
                    print("Current Array Index: ",  self.currentArrayIndex)

                }
                
            case UISwipeGestureRecognizer.Direction.right:
                print("Right Swipe Detected")
                if goalieNumberArray[currentArrayIndex] == goalieNumberArray.last{
                    currentArrayIndex -= 1
                    
                }else if goalieNumberArray[currentArrayIndex] == goalieNumberArray.first{
                    currentArrayIndex = 0
                    
                }else{
                    currentArrayIndex -= 1
                }
                DispatchQueue.main.async {

                    self.goalieTypeProcessing()
                    print("Current Array Index: ",  self.currentArrayIndex)

                }
            default:
                break
            }
        }
    }
    func realmStatsAddShot(){
         try! realm.write{
            if (realm.objects(shotMarkerTable.self).max(ofProperty: "cordSetID") as Int? != nil){
                shot_primaryID = (realm.objects(shotMarkerTable.self).max(ofProperty: "cordSetID") as Int? ?? 0) + 1;
            }else{
                shot_primaryID = (realm.objects(shotMarkerTable.self).max(ofProperty: "cordSetID") as Int? ?? 0);
            }
            let currentGameID = realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?

            realm.create(shotMarkerTable.self, value: ["cordSetID": shot_primaryID!, "gameID": currentGameID!]);
            let shotMarkerTableID = realm.object(ofType: shotMarkerTable.self, forPrimaryKey: shot_primaryID!);
            // opposing team id
            let teamIDProcessed = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i", tempGoalieSelectedID!)).value(forKeyPath: "TeamID") as! [String]).compactMap({Int($0)})
            // shooting team id processing
            if (teamIDProcessed[0] == homeTeamID){
                let scoringTeamID = (realm.objects(newGameTable.self).filter(NSPredicate(format: "homeTeamID == %i AND gameID == %i", teamIDProcessed[0], currentGameID!)).value(forKeyPath: "opposingTeamID") as! [Int]).compactMap({Int($0)})
                shotMarkerTableID?.TeamID = Int(scoringTeamID[0])
            }else{
                 let scoringTeamID = (realm.objects(newGameTable.self).filter(NSPredicate(format: "opposingTeamID == %i AND gameID == %i", teamIDProcessed[0], currentGameID!)).value(forKeyPath: "homeTeamID") as! [Int]).compactMap({Int($0)})
                shotMarkerTableID?.TeamID = Int(scoringTeamID[0])
            }
            shotMarkerTableID?.goalieID = goalieSelectedID

            shotMarkerTableID?.xCordShot = tempXCords
            shotMarkerTableID?.yCordShot = tempYCords
            shotMarkerTableID?.periodNumSet = periodNumSelected!
            shotMarkerTableID?.shotLocation = shotLocationValueSelected
            shotMarkerTableID?.activeState = true

        }
    }
    
    @IBAction func cancelShotLocationButtton(_ sender: UIButton) {
        currentArrayIndex = 0
        animateOut()
        self.performSegue(withIdentifier: "cancelShotLocationSegue", sender: nil);
    }
    
    
    @IBAction func continueShotLocationButton(_ sender: UIButton) {
        if(tempMarkerType != true){
            // if goal run below code
            if(shotLocationValueSelected != nil && hockeyNetImageView.image != hockeyNetAwayTeam){
                 let goalieIDFIlter = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "jerseyNum == %i AND activeState == true", Int(goalieNumberArray[currentArrayIndex])!)).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
                tempGoalieSelectedID = goalieIDFIlter[0]
                animateOut()
                currentArrayIndex = 0
                self.performSegue(withIdentifier: "markerInfoSegue", sender: nil);
            }else if(shotLocationValueSelected == nil && hockeyNetImageView.image == hockeyNetAwayTeam){
                    let goalieIDFIlter = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "jerseyNum == %i AND activeState == true", Int(goalieNumberArray[currentArrayIndex])!)).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
                tempGoalieSelectedID = goalieIDFIlter[0]
                    shotLocationValueSelected = 0
                    animateOut()
                    currentArrayIndex = 0
                    self.performSegue(withIdentifier: "markerInfoSegue", sender: nil);
            }else{
                missingSelectionError()
            }
        }
        if(tempMarkerType != false){
            // if shot run below code
            print("Current Goalie Num", goalieNumberArray)
            print("Selected Goalie Num", goalieNumberArray[currentArrayIndex])
            if(shotLocationValueSelected != nil && hockeyNetImageView.image != hockeyNetAwayTeam){

                let goalieIDFIlter = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "jerseyNum == %i AND activeState == true", Int(goalieNumberArray[currentArrayIndex])!)).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
                tempGoalieSelectedID = goalieIDFIlter[0]

                realmStatsAddShot()
                animateOut()
                self.performSegue(withIdentifier: "cancelShotLocationSegue", sender: nil);
            }else if(shotLocationValueSelected == nil && hockeyNetImageView.image == hockeyNetAwayTeam){

                let goalieIDFIlter = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "jerseyNum == %i AND activeState == true", Int(goalieNumberArray[currentArrayIndex])!)).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
                tempGoalieSelectedID = goalieIDFIlter[0]

                shotLocationValueSelected = 0
                realmStatsAddShot()
                animateOut()
                self.performSegue(withIdentifier: "cancelShotLocationSegue", sender: nil);
            }else{
                print("Missing Feild Entry Error")
                missingSelectionError()
            }
        }
    }
    
    // on animateIn display popUpview over top of New Game View
    func animateIn(){
        
        print("popUpView has been animated in")
        self.view.addSubview(popUpView)
        popUpView.center = self.view.center
        
        popUpView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        popUpView.alpha = 0
        
        // set animation results
        UIView.animate(withDuration: 0.4){
            
            self.popUpView.alpha = 1
            self.popUpView.transform = CGAffineTransform.identity
        }
        
    }
    // on animateOut tear down popUpview over top of New Game View
    func animateOut(){
        
        UIView.animate(withDuration: 0.3, animations: {
            self.popUpView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            self.popUpView.alpha = 0
            // omn sucess of popup tear down remove popUpView from super view
        })  { (success: Bool) in
            
            self.popUpView.removeFromSuperview()
        }
        
        print("popUpView has been Teared Down")
    }
    
    // func used to pass varables on segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check is appropriate segue is being used
        if (segue.identifier == "markerInfoSegue"){
            // set var vc as destination segue
            let shotLocationVC = segue.destination as! Marker_Info_Page
            //let new_vc = segue.destination as! New_Game_Page
            shotLocationVC.shotLocationValue = String(shotLocationValueSelected)
            shotLocationVC.xCords = tempXCords
            shotLocationVC.yCords = tempYCords
            shotLocationVC.markerType = tempMarkerType

            shotLocationVC.goalieSelectedID = tempGoalieSelectedID
            shotLocationVC.homeTeam = homeTeamID
            shotLocationVC.awayTeam = awayTeamID
            shotLocationVC.periodNumSelected = periodNumSelected
            print("Passed Goalie ID", tempGoalieSelectedID)
            
        }
        if (segue.identifier == "cancelShotLocationSegue"){
            // set var vc as destination segue
            let shotLocationVC = segue.destination as! New_Game_Page
            //let new_vc = segue.destination as! New_Game_Page
            shotLocationVC.newGameStarted = false
            shotLocationVC.goalieSelectedID = goalieSelectedID
            shotLocationVC.periodNumSelected = periodNumSelected
        }
    }
}

