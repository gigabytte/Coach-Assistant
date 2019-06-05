//
//  Old Game Ice View.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-03-08.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import GoogleMobileAds

class Old_Game_Ice_View: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBAction func unwindToOldStatsIce(segue: UIStoryboardSegue) {}
    
    let realm = try! Realm()
    
    let homeTeamGoalMakerImage = UIImage(named: "home_team_goal.png");
    let homeTeamShotMakerImage = UIImage(named: "home_team_shot.png");
    let awayTeamGoalMarkerImage = UIImage(named: "away_team_goal.png")
    let awayTeamShotMarkerImage = UIImage(named: "away_team_shot.png")
    let awayTeamPenaltyMarkerImage = UIImage(named: "away_penalty.png")
    let homeTeamPenaltyMarkerImage = UIImage(named: "home_penalty.png")
    
    @IBOutlet weak var adView: GADBannerView!
    @IBOutlet weak var homeTeamNameLabel: UILabel!
    @IBOutlet weak var homeTeamNumGoals: UILabel!
    @IBOutlet weak var homeTeamNumShots: UILabel!
    @IBOutlet weak var awayTeamNumShots: UILabel!
    @IBOutlet weak var awayTeamNameLabel: UILabel!
    @IBOutlet weak var awayTeamNumGoals: UILabel!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var coachAssitantLogoBtn: UIButton!
    
    var shotMarkerimageView: UIImageView!
    var goalMarkerimageView: UIImageView!
    var penaltyMarkerimageView: UIImageView!
    
    var SeletedGame: Int = UserDefaults.standard.integer(forKey: "gameID")
    var homeTeam: Int = UserDefaults.standard.integer(forKey: "homeTeam")
    var awayTeam: Int = UserDefaults.standard.integer(forKey: "awayTeam")
    var goalieID:Int!
    var tagCounter: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder() // To get shake gesture
        // set listener for notification after goalie is selected
        NotificationCenter.default.addObserver(self, selector: #selector(myMethod(notification:)), name: NSNotification.Name(rawValue: "passDataInView"), object: nil)
        
        let singleLogoGesture = UITapGestureRecognizer(target: self, action: #selector(normalTapLogo(_:)))
        singleLogoGesture.numberOfTapsRequired = 1
        coachAssitantLogoBtn?.addGestureRecognizer(singleLogoGesture)
        
        let longLogoGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTapLogo(_:)))
        coachAssitantLogoBtn?.addGestureRecognizer(longLogoGesture)
        
        bannerViewInitialize()
        
        teamNameInitialize()
        teamIDProcessing()
        navBarProcessing()
        
        if (realm.objects(newGameTable.self).filter("gameID >= 0").last != nil) {
            
            if (realm.objects(goalMarkersTable.self).filter("cordSetID >= 0").last == nil){
                // align text in text field as well assign text value to text field to team name
                self.homeTeamNumGoals.text = String(0)
                self.homeTeamNumGoals.textAlignment = .center
                self.awayTeamNumGoals.text = String(0)
                self.awayTeamNumGoals.textAlignment = .center
                print("Goal Count Defaulted to 0")
            }else{
                self.scoreInitialize()
                print("Goal Count Sucessfully Ran")
            }
            if (realm.objects(shotMarkerTable.self).filter("cordSetID >= 0").last == nil){
                // align text to center and assigned text field the value of homeScoreFilter query
                self.homeTeamNumShots.text = String(0)
                self.homeTeamNumShots.textAlignment = .center
                self.awayTeamNumShots.text = String(0)
                self.awayTeamNumShots.textAlignment = .center
                print("Shot Count Defaulted to 0")
            }else{
                self.numShotInitialize()
                print("Shot Count Sucessfully Ran")
            }
        }else{
            print("Score and Shot Count Ran Failed at newGameTable gameID")
        }
        
        self.teamIDProcessing()
        
        
        if (isKeyPresentInUserDefaults(key: "selectedGoalieID") != true){
            delay(0.5){
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let popupVC = storyboard.instantiateViewController(withIdentifier: "Old_Stats_Goalie_Selection_View") as! Old_Stats_Goalie_Selection_View
                popupVC.modalPresentationStyle = .overCurrentContext
                popupVC.modalTransitionStyle = .crossDissolve
                let pVC = popupVC.popoverPresentationController
                pVC?.permittedArrowDirections = .any
                pVC?.delegate = self
                
                self.present(popupVC, animated: true, completion: nil)
                print("Old_Stats_Goalie_Selection_View Presented!")
            }
        }else{
        
            onLoad()
        }
        // load data needed to display ice results on load
        //onLoad()
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
    
    @objc func myMethod(notification: NSNotification){
        onLoad()
    }
    
    func onLoad(){
        goalieID = UserDefaults.standard.integer(forKey: "selectedGoalieID")
        
        self.home_markerPlacement(markerType: self.homeTeamShotMakerImage!)
        self.home_markerPlacement(markerType: self.homeTeamGoalMakerImage!)
        self.home_markerPlacement(markerType: self.homeTeamPenaltyMarkerImage!)
        
        self.away_markerPlacement(markerType: self.awayTeamShotMarkerImage!)
        self.away_markerPlacement(markerType: self.awayTeamGoalMarkerImage!)
        self.away_markerPlacement(markerType: self.awayTeamPenaltyMarkerImage!)
        
    }
    
    func bannerViewInitialize(){
    
        if (UserDefaults.standard.bool(forKey: "userPurchaseConf") == true){
            adView?.heightAnchor.constraint(equalToConstant: 0.0).isActive = true
        }else{
            adView?.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
            adView?.adUnitID = universalValue().newGameAdUnitID
            adView?.rootViewController = self
            adView?.load(GADRequest())
            adView?.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
            adView?.backgroundColor = UIColor.lightGray
        }
    }
    
    @IBAction func statsViewButton(_ sender: Any) {
        self.performSegue(withIdentifier: "Old_Stats_Main_Stats", sender: nil);
        
    }
    @IBAction func backbutton(_ sender: UIBarButtonItem) {
        // delete user defaults then exit old game stats view
        deleteNewGameUserDefaults.deleteUserDefaults()
        NotificationCenter.default.removeObserver(self)
        self.performSegue(withIdentifier: "Back_To_Old_Stats_Ice", sender: nil);
    }
    
    @objc func normalTapLogo(_ sender: UIGestureRecognizer){
        // segue to golaie picker poage from new game on single press
       self.performSegue(withIdentifier: "goalieSelectionPopUp", sender: nil);
    }
    
    @objc func longTapLogo(_ sender: UIGestureRecognizer){
        // segue to ananlytics page on long press
        if sender.state == .began {
            //self.performSegue(withIdentifier: "oldStatsAnalyticsPopUp", sender: nil);
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let popupVC = storyboard.instantiateViewController(withIdentifier: "Analytical_View_Controller") as! Current_Stats_Ananlytical_View
            popupVC.modalPresentationStyle = .overCurrentContext
            popupVC.modalTransitionStyle = .crossDissolve
            let pVC = popupVC.popoverPresentationController
            pVC?.permittedArrowDirections = .any
            pVC?.delegate = self
            
            present(popupVC, animated: true, completion: nil)
            print("Analytical_View_Controller Presented!")
            
        }
    }
    
    @objc func singleShotMarkerTapped(sender: UITapGestureRecognizer?) {
        print("Shot Marker Tapped")
        let newView = sender?.view
        tappedMarker(markerType: 0, markerTag: newView!.tag)
       
    }
    
    @objc func singleGoalMarkerTapped(sender: UITapGestureRecognizer?) {
        print("Goal Marker Tapped")
        let newView = sender?.view
       tappedMarker(markerType: 1, markerTag: newView!.tag)
    }
    
    @objc func singlePenaltyMarkerTapped(sender: UITapGestureRecognizer?) {
        print("Penalty Marker Tapped")
        let newView = sender?.view
        tappedMarker(markerType: 2, markerTag: newView!.tag)
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func teamIDProcessing(){
        // get home team and away team id from the most recent new gamne entry
        let newGameFilter = self.realm.object(ofType: newGameTable.self, forPrimaryKey: SeletedGame);
        homeTeam = (newGameFilter?.homeTeamID)!
        awayTeam = (newGameFilter?.opposingTeamID)!
    }

    func scoreInitialize(){
    
    // query realm for goal count based on newest gam
    let homeScoreFilter = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", SeletedGame, homeTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
    
    let awayScoreFilter = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", SeletedGame, awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
    // align text to center and assigned text field the value of homeScoreFilter query
    homeTeamNumGoals?.text = String(homeScoreFilter)
    homeTeamNumGoals?.textAlignment = .center
    awayTeamNumGoals?.text = String(awayScoreFilter)
    awayTeamNumGoals?.textAlignment = .center
    }
    
    func navBarProcessing() {
        if (homeTeam != nil && awayTeam != nil){
            let home_teamNameFilter = realm.object(ofType: teamInfoTable.self, forPrimaryKey: homeTeam)?.nameOfTeam
            let away_teamNameFilter = realm.object(ofType: teamInfoTable.self, forPrimaryKey: awayTeam)?.nameOfTeam
            
            navBar?.topItem?.title = "Ice Surface View of \(home_teamNameFilter!) vs \(away_teamNameFilter!)"
        }else{
            print("Error Unable to Gather Team Name, Nav Bar Has Defaulted")
            
        }
    }

    func shot_markerProcessing() -> (home_xCordsForPlacementShot: [String], home_yCordsForPlacementShot: [String], away_xCordsForPlacementShot: [String], away_yCordsForPlacementShot: [String]){
        

        let home_xCordsArray = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", SeletedGame, homeTeam)).value(forKeyPath: "xCordShot") as! [Int]).compactMap({String($0)})
        let home_yCordsArray = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", SeletedGame, homeTeam)).value(forKeyPath: "yCordShot") as! [Int]).compactMap({String($0)})
        let away_xCordsArray = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND goalieID == %i AND TeamID == %i", SeletedGame, UserDefaults.standard.integer(forKey: "selectedGoalieID"), awayTeam)).value(forKeyPath: "xCordShot") as! [Int]).compactMap({String($0)})
        let away_yCordsArray = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND goalieID == %i AND TeamID == %i", SeletedGame, UserDefaults.standard.integer(forKey: "selectedGoalieID"), awayTeam)).value(forKeyPath: "yCordShot") as! [Int]).compactMap({String($0)})
        
        let home_xCordsForPlacementShot = home_xCordsArray
        let home_yCordsForPlacementShot = home_yCordsArray
        let away_xCordsForPlacementShot = away_xCordsArray
        let away_yCordsForPlacementShot = away_yCordsArray
        // return rresult of marker processing
        return(home_xCordsForPlacementShot, home_yCordsForPlacementShot, away_xCordsForPlacementShot, away_yCordsForPlacementShot)
    }
    
    // func used to process shot X and Y cord info from realm based on team selection on new game page load
    func goal_markerProcessing() -> (home_xCordsForPlacementGoal: [String], home_yCordsForPlacementGoal: [String], away_xCordsForPlacementGoal: [String], away_yCordsForPlacementGoal: [String]){
        
        let newGameFilter = (self.realm.object(ofType: newGameTable.self, forPrimaryKey: SeletedGame)?.gameID)
        
        let home_xCordsArray = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", newGameFilter!,homeTeam)).value(forKeyPath: "xCordGoal") as! [Int]).compactMap({String($0)})
        let home_yCordsArray = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", newGameFilter!,homeTeam)).value(forKeyPath: "yCordGoal") as! [Int]).compactMap({String($0)})
        let away_xCordsArray = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND goalieID == %i AND TeamID == %i", newGameFilter!,UserDefaults.standard.integer(forKey: "selectedGoalieID"),awayTeam)).value(forKeyPath: "xCordGoal") as! [Int]).compactMap({String($0)})
        let away_yCordsArray = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND goalieID == %i AND TeamID == %i", newGameFilter!,UserDefaults.standard.integer(forKey: "selectedGoalieID"),awayTeam)).value(forKeyPath: "yCordGoal") as! [Int]).compactMap({String($0)})
        // filter xCords and y cords by home  and away team realtive positions based on TeamID colum result
        let home_xCordsForPlacementGoal = home_xCordsArray
        let home_yCordsForPlacementGoal = home_yCordsArray
        let away_xCordsForPlacementGoal = away_xCordsArray
        let away_yCordsForPlacementGoal = away_yCordsArray
        // log data grabbed from realm
        print("Home team goal X cords to be used; ", home_xCordsForPlacementGoal)
        print("Home team goal Y cords to be used; ", home_yCordsForPlacementGoal)
        print("Away team goal X cords to be used; ", away_xCordsForPlacementGoal)
        print("Away team goal Y cords to be used; ", away_yCordsForPlacementGoal)
        // return rresult of marker processing
        return(home_xCordsForPlacementGoal, home_yCordsForPlacementGoal, away_xCordsForPlacementGoal, away_yCordsForPlacementGoal)
    }
    // func used to process shot X and Y cord info from realm based on team selection on new game page load
    func peanlty_markerProcessing() -> (home_xCordsForPlacementPenalty: [String], home_yCordsForPlacementPenalty: [String], away_xCordsForPlacementPenalty: [String], away_yCordsForPlacementPenalty: [String]){
        
        let newGameFilter = (self.realm.object(ofType: newGameTable.self, forPrimaryKey: SeletedGame)?.gameID)
        
        let home_xCordsArray = (realm.objects(penaltyTable.self).filter(NSPredicate(format: "gameID == %i AND teamID == %i", newGameFilter!, homeTeam)).value(forKeyPath: "xCord") as! [Int]).compactMap({String($0)})
        let home_yCordsArray = (realm.objects(penaltyTable.self).filter(NSPredicate(format: "gameID == %i AND teamID == %i", newGameFilter!, homeTeam)).value(forKeyPath: "yCord") as! [Int]).compactMap({String($0)})
        let away_xCordsArray = (realm.objects(penaltyTable.self).filter(NSPredicate(format: "gameID == %i AND teamID == %i", newGameFilter!, awayTeam)).value(forKeyPath: "xCord") as! [Int]).compactMap({String($0)})
        let away_yCordsArray = (realm.objects(penaltyTable.self).filter(NSPredicate(format: "gameID == %i AND teamID == %i", newGameFilter!, awayTeam)).value(forKeyPath: "yCord") as! [Int]).compactMap({String($0)})
        // filter xCords and y cords by home  and away team realtive positions based on TeamID colum result
        let home_xCordsForPlacementPenalty = home_xCordsArray
        let home_yCordsForPlacementPenalty = home_yCordsArray
        let away_xCordsForPlacementPenalty = away_xCordsArray
        let away_yCordsForPlacementPenalty = away_yCordsArray
        // log data grabbed from realm
        print("Home team penalty X cords to be used; ", home_xCordsForPlacementPenalty)
        print("Home team penalty Y cords to be used; ", home_yCordsForPlacementPenalty)
        print("Away team penalty X cords to be used; ", away_xCordsForPlacementPenalty)
        print("Away team penalty Y cords to be used; ", away_yCordsForPlacementPenalty)
        // return rresult of marker processing
        return(home_xCordsForPlacementPenalty, home_yCordsForPlacementPenalty, away_xCordsForPlacementPenalty, away_yCordsForPlacementPenalty)
    }
    
    func shotLocationConversion(shotLocationInt: Int) -> String{
        switch shotLocationInt {
        case 1  :
            return("Top Left")
        case 2  :
            return("Top Right")
        case 3  :
            return("Bottom Left")
        case 4  :
            return("Bottom Right")
        case 5  :
            return("Five Hole")
        default :
            return("Not Found")
        }
    }
    
    func tappedMarker(markerType: Int, markerTag: Int){
        if(markerType == 0){
            let selectedShotMarker = view.viewWithTag(markerTag)
            let markerCords: CGPoint = selectedShotMarker!.frame.origin
            let xMarkerCord = Int(markerCords.x + CGFloat(universalValue().markerCenterX))
            let yMarkerCord = Int(markerCords.y + CGFloat(universalValue().markerCenterY))
            print("Cords for shot image are: \(xMarkerCord) and \(yMarkerCord)")
            
            let shotLocation = (self.realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "xCordShot == %i AND yCordShot == %i AND gameID == %i AND activeState == true", xMarkerCord, yMarkerCord, SeletedGame)).value(forKeyPath: "shotLocation") as! [Int]).compactMap({Int($0)})
            let goalieID = (self.realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "xCordShot == %i AND yCordShot == %i AND gameID == %i AND activeState == true", xMarkerCord, yMarkerCord, SeletedGame)).value(forKeyPath: "goalieID") as! [Int]).compactMap({Int($0)})
            let goalieName = self.realm.object(ofType: playerInfoTable.self, forPrimaryKey: goalieID.first)?.playerName;
             print("Goalie ID \(goalieID.first) \(goalieName)")
            let teamID = (self.realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "xCordShot == %i AND yCordShot == %i AND gameID == %i AND activeState == true", xMarkerCord, yMarkerCord, SeletedGame)).value(forKeyPath: "TeamID") as! [Int]).compactMap({Int($0)})
            let teamName = self.realm.object(ofType: teamInfoTable.self, forPrimaryKey: teamID[0])?.nameOfTeam;
            
            let actionSheet = UIAlertController(title: "Shot Marker Details", message: "Shot Location: \(shotLocationConversion(shotLocationInt: shotLocation[0])) \n Goalie Shot on: \(goalieName!) \n Shot by team: \(teamName!)", preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert: UIAlertAction!) -> Void in
                // observe it in the buttons block, what button has been pressed
                print("didPress Ok - Goal")
            })
            actionSheet.addAction(okAction)
            if let popoverController = actionSheet.popoverPresentationController {
                popoverController.sourceView = selectedShotMarker!
            }
            // Present the controller
            self.present(actionSheet, animated: true, completion: nil)
        }else if(markerType == 1){
            let selectedGoalMarker = view.viewWithTag(markerTag)
            let markerCords: CGPoint = selectedGoalMarker!.frame.origin
            let xMarkerCord = Int(markerCords.x + CGFloat(universalValue().markerCenterX))
            let yMarkerCord = Int(markerCords.y + CGFloat(universalValue().markerCenterY))
            print("Cords for goal image are: \(xMarkerCord) and \(yMarkerCord)")
            
            let shotLocation = (self.realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "xCordGoal == %i AND yCordGoal == %i AND gameID == %i AND activeState == true", xMarkerCord, yMarkerCord, self.SeletedGame)).value(forKeyPath: "shotLocation") as! [Int]).compactMap({Int($0)})
            let goalieID = (self.realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "xCordGoal == %i AND yCordGoal == %i AND gameID == %i AND activeState == true", xMarkerCord, yMarkerCord, SeletedGame)).value(forKeyPath: "goalieID") as! [Int]).compactMap({Int($0)})
           
            let goalieName = self.realm.object(ofType: playerInfoTable.self, forPrimaryKey: goalieID.first)?.playerName;
            
            let teamID = (self.realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "xCordGoal == %i AND yCordGoal == %i AND gameID == %i AND activeState == true", xMarkerCord, yMarkerCord, SeletedGame)).value(forKeyPath: "TeamID") as! [Int]).compactMap({Int($0)})
            let teamName = self.realm.object(ofType: teamInfoTable.self, forPrimaryKey: teamID[0])?.nameOfTeam;
            let scoringPlayerID = (self.realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "xCordGoal == %i AND yCordGoal == %i AND gameID == %i AND activeState == true", xMarkerCord, yMarkerCord, SeletedGame)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})
            let scoringPlayerName = self.realm.object(ofType: playerInfoTable.self, forPrimaryKey: scoringPlayerID[0])?.playerName;
            
            let actionSheet = UIAlertController(title: "Goal Marker Details", message: "Goal Location: \(shotLocationConversion(shotLocationInt: shotLocation[0])) \n Goalie Shot on: \(goalieName!) \n Scored by team: \(teamName!) \n Player Scored: \(scoringPlayerName!)", preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert: UIAlertAction!) -> Void in
                // observe it in the buttons block, what button has been pressed
                print("didPress Ok - Penalty")
            })
            actionSheet.addAction(okAction)
            if let popoverController = actionSheet.popoverPresentationController {
                popoverController.sourceView = selectedGoalMarker
            }
            // Present the controller
            self.present(actionSheet, animated: true, completion: nil)
        }else{
            // placement of bto for peanlty marker
            let selectedPeanltyMarker = view.viewWithTag(markerTag)
            let markerCords: CGPoint = selectedPeanltyMarker!.frame.origin
            let xMarkerCord = Int(markerCords.x + CGFloat(universalValue().markerCenterX))
            let yMarkerCord = Int(markerCords.y  + CGFloat(universalValue().markerCenterY))
            print("Cords for Penalty image are: \(xMarkerCord) and \(yMarkerCord)")
            
            let playerID = (self.realm.objects(penaltyTable.self).filter(NSPredicate(format: "xCord == %i AND yCord == %i AND gameID == %i AND activeState == true", xMarkerCord, yMarkerCord, self.SeletedGame)).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)}).first
            let playerOffenderName = (self.realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", playerID!)).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)}).first
            let timeOfPenalty = (self.realm.objects(penaltyTable.self).filter(NSPredicate(format: "xCord == %i AND yCord == %i AND gameID == %i AND activeState == true", xMarkerCord,yMarkerCord ,self.SeletedGame)).value(forKeyPath: "timeOfOffense") as! [Date]).first
            let convertedTime = dateToString.dateToStringFormatter(unformattedDate: timeOfPenalty!)
            let typeOfOffense = (self.realm.objects(penaltyTable.self).filter(NSPredicate(format: "xCord == %i AND yCord == %i AND gameID == %i AND activeState == true", xMarkerCord,yMarkerCord ,self.SeletedGame)).value(forKeyPath: "penaltyType") as! [String]).compactMap({String($0)}).first
            
            let actionSheet = UIAlertController(title: "Penalty Details", message: "Offense Made By: \(playerOffenderName!)\n Time of Offense: \(convertedTime)\n Offense Type: \(typeOfOffense!)\n ", preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert: UIAlertAction!) -> Void in
                // observe it in the buttons block, what button has been pressed
                print("didPress Ok - Penalty")
            })
            actionSheet.addAction(okAction)
            if let popoverController = actionSheet.popoverPresentationController {
                popoverController.sourceView = selectedPeanltyMarker
            }
            // Present the controller
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    func home_markerPlacement(markerType: UIImage){
        if (shot_markerProcessing().home_xCordsForPlacementShot.isEmpty == false || goal_markerProcessing().away_xCordsForPlacementGoal.isEmpty == false || peanlty_markerProcessing().home_xCordsForPlacementPenalty.isEmpty == false){
            // check markerType image value
            if(markerType == homeTeamShotMakerImage) {
                for i in 0..<shot_markerProcessing().home_xCordsForPlacementShot.count{
                    let imageView = UIImageView(frame: CGRect(x: Int(shot_markerProcessing().home_xCordsForPlacementShot[i])! - universalValue().markerCenterX, y: Int(shot_markerProcessing().home_yCordsForPlacementShot[i])! - universalValue().markerCenterY, width: universalValue().markerWidth, height: universalValue().markerHeight));
                    imageView.contentMode = .scaleAspectFill;
                    imageView.image = markerType;
                    view.addSubview(imageView);
                    imageView.tag = tagCounter
                    imageView.viewWithTag(imageView.tag)!.isUserInteractionEnabled = true
                    // check Tap gestuires for a single tap
                    let singleShotTap = UITapGestureRecognizer(target: self, action: #selector(singleShotMarkerTapped(sender:)));
                    // number of taps require 1
                    singleShotTap.numberOfTapsRequired = 1
                    imageView.viewWithTag(imageView.tag)!.addGestureRecognizer(singleShotTap)
                    tagCounter += 1
                    print("home marker placved")
                }
            }
            if(markerType == homeTeamGoalMakerImage) {
                for i in 0..<goal_markerProcessing().home_xCordsForPlacementGoal.count{
                    let imageView = UIImageView(frame: CGRect(x: Int(goal_markerProcessing().home_xCordsForPlacementGoal[i])! - universalValue().markerCenterX, y: Int(goal_markerProcessing().home_yCordsForPlacementGoal[i])! - universalValue().markerCenterY, width:  universalValue().markerWidth, height: universalValue().markerHeight));
                    imageView.contentMode = .scaleAspectFill;
                    imageView.image = markerType;
                    view.addSubview(imageView);
                    imageView.tag = tagCounter
                    imageView.viewWithTag(imageView.tag)!.isUserInteractionEnabled = true
                    // check Tap gestuires for a single tap
                    let singleGoalTap = UITapGestureRecognizer(target: self, action: #selector(singleGoalMarkerTapped(sender:)));
                    // number of taps require 1
                    singleGoalTap.numberOfTapsRequired = 1
                    imageView.viewWithTag(imageView.tag)!.addGestureRecognizer(singleGoalTap)
                    tagCounter += 1
                }
            }
            // placement of home penalty marker
            if(markerType == homeTeamPenaltyMarkerImage) {
                for i in 0..<peanlty_markerProcessing().home_xCordsForPlacementPenalty.count{
                    let imageView = UIImageView(frame: CGRect(x: Int(peanlty_markerProcessing().home_xCordsForPlacementPenalty[i])! - universalValue().markerCenterX, y: Int(peanlty_markerProcessing().home_yCordsForPlacementPenalty[i])! - universalValue().markerCenterY, width:  universalValue().markerWidth, height: universalValue().markerHeight));
                    imageView.contentMode = .scaleAspectFill;
                    imageView.image = markerType;
                    view.addSubview(imageView);
                    imageView.tag = tagCounter
                    imageView.viewWithTag(imageView.tag)!.isUserInteractionEnabled = true
                    // check Tap gestuires for a single tap
                    let singlePeanltyTap = UITapGestureRecognizer(target: self, action: #selector(singlePenaltyMarkerTapped(sender:)));
                    // number of taps require 1
                    singlePeanltyTap.numberOfTapsRequired = 1
                    imageView.viewWithTag(imageView.tag)!.addGestureRecognizer(singlePeanltyTap)
                    tagCounter += 1
                }
            }
        }else{
            // print error id not cord data present in arrays
            //should only error out if user hasnt submittte any marker data to realm
            print("No Home Marker Cords Found on Load")
        }
    }
    func away_markerPlacement(markerType: UIImage){
        if (shot_markerProcessing().away_xCordsForPlacementShot.isEmpty == false || goal_markerProcessing().away_xCordsForPlacementGoal.isEmpty == false || peanlty_markerProcessing().away_xCordsForPlacementPenalty.isEmpty == false){
            // check markerType image value
            print("away shot")
            if(markerType == awayTeamShotMarkerImage) {
                
                for i in 0..<shot_markerProcessing().away_xCordsForPlacementShot.count{
                    let imageView = UIImageView(frame: CGRect(x: Int(shot_markerProcessing().away_xCordsForPlacementShot[i])! - universalValue().markerCenterX, y: Int(shot_markerProcessing().away_yCordsForPlacementShot[i])! - universalValue().markerCenterY, width:  universalValue().markerWidth, height: universalValue().markerHeight));
                    imageView.contentMode = .scaleAspectFill;
                    imageView.image = markerType;
                    view.addSubview(imageView);
                    imageView.tag = tagCounter
                    imageView.viewWithTag(imageView.tag)!.isUserInteractionEnabled = true
                    // check Tap gestuires for a single tap
                    let singleShotTap = UITapGestureRecognizer(target: self, action: #selector(singleShotMarkerTapped(sender:)));
                    // number of taps require 1
                    singleShotTap.numberOfTapsRequired = 1
                    imageView.viewWithTag(imageView.tag)!.addGestureRecognizer(singleShotTap)
                    tagCounter += 1
                }
            }
            if(markerType == awayTeamGoalMarkerImage) {
                for i in 0..<goal_markerProcessing().away_xCordsForPlacementGoal.count{
                    let imageView = UIImageView(frame: CGRect(x: Int(goal_markerProcessing().away_xCordsForPlacementGoal[i])! - universalValue().markerCenterX, y: Int(goal_markerProcessing().away_yCordsForPlacementGoal[i])! - universalValue().markerCenterY, width:  universalValue().markerWidth, height: universalValue().markerHeight));
                    imageView.contentMode = .scaleAspectFill;
                    imageView.image = markerType;
                    view.addSubview(imageView);
                    imageView.tag = tagCounter
                    imageView.viewWithTag(imageView.tag)!.isUserInteractionEnabled = true
                    // check Tap gestuires for a single tap
                    let singleGoalTap = UITapGestureRecognizer(target: self, action: #selector(singleGoalMarkerTapped(sender:)));
                    // number of taps require 1
                    singleGoalTap.numberOfTapsRequired = 1
                    imageView.viewWithTag(imageView.tag)!.addGestureRecognizer(singleGoalTap)
                    tagCounter += 1
                }
            }
            // placement of home penalty marker
            if(markerType == awayTeamPenaltyMarkerImage) {
                for i in 0..<peanlty_markerProcessing().away_xCordsForPlacementPenalty.count{
                    let imageView = UIImageView(frame: CGRect(x: Int(peanlty_markerProcessing().away_xCordsForPlacementPenalty[i])! - universalValue().markerCenterX, y: Int(peanlty_markerProcessing().away_yCordsForPlacementPenalty[i])! - universalValue().markerCenterY, width:  universalValue().markerWidth, height: universalValue().markerHeight));
                    imageView.contentMode = .scaleAspectFill;
                    imageView.image = markerType;
                    view.addSubview(imageView);
                    imageView.tag = tagCounter
                    imageView.viewWithTag(imageView.tag)!.isUserInteractionEnabled = true
                    // check Tap gestuires for a single tap
                    let singlePeanltyTap = UITapGestureRecognizer(target: self, action: #selector(singlePenaltyMarkerTapped(sender:)));
                    // number of taps require 1
                    singlePeanltyTap.numberOfTapsRequired = 1
                    imageView.viewWithTag(imageView.tag)!.addGestureRecognizer(singlePeanltyTap)
                    tagCounter += 1
                }
            }
            
        }else{
            // print error id not cord data present in arrays
            //should only error out if user hasnt submittte any marker data to realm
            print("No Away Marker Cords Found on Load")
        }
    }
    
    
    func teamNameInitialize(){
        
        // query realm for team naames based on newest game
        // align text in text field as well assign text value to text field to team name
        homeTeamNameLabel?.text = (realm.object(ofType: teamInfoTable.self, forPrimaryKey: homeTeam))?.nameOfTeam
        homeTeamNameLabel?.textAlignment = .center
        awayTeamNameLabel?.text = (realm.object(ofType: teamInfoTable.self, forPrimaryKey: awayTeam))?.nameOfTeam
        awayTeamNameLabel?.textAlignment = .center
    }
    
    func numShotInitialize(){
        
        let newGameFilter = (self.realm.object(ofType: newGameTable.self, forPrimaryKey: SeletedGame))
        // get homeTeam and away team ID's fom said lastest new game entry
        homeTeam = (newGameFilter?.homeTeamID)!
        awayTeam = (newGameFilter?.opposingTeamID)!
        
        //get array of team ID's and concert to regular string array from optional
        let homeShotCounter = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", (newGameFilter?.gameID)!, homeTeam)).value(forKeyPath: "TeamID") as! [Int]).compactMap({String($0)}).count
        
        let awayShotCounter = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", (newGameFilter?.gameID)!, awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        // align text to center and assigned text field the value of homeScoreFilter query
        homeTeamNumShots?.text = String(homeShotCounter)
        homeTeamNumShots?.textAlignment = .center
        awayTeamNumShots?.text = String(awayShotCounter)
        awayTeamNumShots?.textAlignment = .center
    }
    
    // delay loop
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }

}
