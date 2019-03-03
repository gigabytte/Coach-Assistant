
//
//  New_Game_Page.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-01-10.
//  Copyright © 2019 MAG Industries. All rights reserved.
//
import UIKit
import RealmSwift
import Realm

class New_Game_Page: UIViewController {
    
    let realm = try! Realm()
    //ice rink image connectionto UIIIMageView
    @IBOutlet weak var iceRinkImage: UIImageView!
    
    // declare image view vars
    let homeTeamGoalMakerImage = UIImage(named: "home_team_goal.png");
    let homeTeamShotMakerImage = UIImage(named: "home_team_shot.png");
    let awayTeamGoalMarkerImage = UIImage(named: "away_team_goal.png")
    let awayTeamShotMarkerImage = UIImage(named: "away_team_shot.png")
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var logoButton: UIButton!
    @IBOutlet weak var homeTeamNameLabel: UILabel!
    @IBOutlet weak var homeTeamNumGoals: UILabel!
    @IBOutlet weak var homeTeamNumShots: UILabel!
    @IBOutlet weak var awayTeamNumShots: UILabel!
    @IBOutlet weak var awayTeamNameLabel: UILabel!
    @IBOutlet weak var awayTeamNumGoals: UILabel!
    
    var yLocationCords: Int = 0
    var xLocationCords: Int = 0
    
    var shotMarkerimageView   : UIImageView!
    var goalMarkerimageView   : UIImageView!
    
    var markerType: Bool!
    var newGameStarted: Bool!
    var periodNumSelected: Int!
    var goalieSelectedID: Int!
    var selectedGameTypeString: String!
    
    var homeTeam: Int!
    var awayTeam: Int!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self.view)
        
        // link x and y cords data to vars for universal use
        yLocationCords = Int(location.y)
        xLocationCords = Int(location.x)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = try! Realm()
        newGameDetection()
        teamNameInitialize()
        teamIDProcessing()
        navBarProcessing()
        iceRinkImage.isUserInteractionEnabled = true
        
        // check Tap gestuires for a single tap
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapped));
        // number of taps require 1
        singleTap.numberOfTapsRequired = 1
        iceRinkImage.addGestureRecognizer(singleTap)
        
        // check Tap gestuires for a double tap
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(longTapped));
        //long tap must exceed 0.5 seconds
        longTap.minimumPressDuration = 0.5
        //longTap.delaysTouchesBegan = true
        iceRinkImage.addGestureRecognizer(longTap)
        
        // MUST SET ON EACH VIEW DEPENDENT ON ORIENTATION NEEDS
        // get rotation allowances of device
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // set auto rotation to false
        appDelegate.shouldRotate = false
    
        // run delay loop ever so after realm refreshes so you get the most current x and y cord placements
        delay(0.5){
            // call functions for stats page dynamic function
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
        // refrence to below functionns for loading first pv initial VC load
            self.teamIDProcessing()
            self.shot_markerProcessing()
            self.home_markerPlacement(markerType: self.homeTeamShotMakerImage!)
            self.home_markerPlacement(markerType: self.homeTeamGoalMakerImage!)
            self.goal_markerProcessing()
            self.away_markerPlacement(markerType: self.awayTeamShotMarkerImage!)
            self.away_markerPlacement(markerType: self.awayTeamGoalMarkerImage!)
        }
        
    }
    
    func navBarProcessing(){
        if (periodNumSelected != nil && homeTeam != nil && awayTeam != nil){
            let home_teamNameFilter = realm.object(ofType: teamInfoTable.self, forPrimaryKey: homeTeam)?.nameOfTeam
            let away_teamNameFilter = realm.object(ofType: teamInfoTable.self, forPrimaryKey: awayTeam)?.nameOfTeam
            navBar.topItem!.title = home_teamNameFilter! + " vs " + away_teamNameFilter! + " Period " + String(periodNumSelected)
        }else{
            print("Error Unable to Gather Period Number Selection!")
        }
    }
    
    func newGameDetection(){
        delay(0.3){
            if (self.newGameStarted != false){
                self.performSegue(withIdentifier: "logoButtonSegue", sender: nil);
            }
            
        }
    }
    
    func teamIDProcessing(){
        // get home team and away team id from the most recent new gamne entry
        let newGameFilter = realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?);
        homeTeam = newGameFilter?.homeTeamID
        awayTeam = newGameFilter?.opposingTeamID
    }
    // func used to process shot X and Y cord info from realm based on team selection on new game page load
    func shot_markerProcessing() -> (home_xCordsForPlacementShot: [String], home_yCordsForPlacementShot: [String], away_xCordsForPlacementShot: [String], away_yCordsForPlacementShot: [String]){
        
        let realm = try! Realm()
        
        let newGameFilter = realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.gameID;
    
        let home_xCordsArray = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", newGameFilter!, homeTeam!)).value(forKeyPath: "xCordShot") as! [Int]).compactMap({String($0)})
        let home_yCordsArray = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", newGameFilter!, homeTeam!)).value(forKeyPath: "yCordShot") as! [Int]).compactMap({String($0)})
        let away_xCordsArray = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", newGameFilter!, awayTeam!)).value(forKeyPath: "xCordShot") as! [Int]).compactMap({String($0)})
        let away_yCordsArray = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", newGameFilter!, awayTeam!)).value(forKeyPath: "yCordShot") as! [Int]).compactMap({String($0)})

        let home_xCordsForPlacementShot = home_xCordsArray
        let home_yCordsForPlacementShot = home_yCordsArray
        let away_xCordsForPlacementShot = away_xCordsArray
        let away_yCordsForPlacementShot = away_yCordsArray
        // return rresult of marker processing
        return(home_xCordsForPlacementShot, home_yCordsForPlacementShot, away_xCordsForPlacementShot, away_yCordsForPlacementShot)
    }
    
    // func used to process shot X and Y cord info from realm based on team selection on new game page load
    func goal_markerProcessing() -> (home_xCordsForPlacementGoal: [String], home_yCordsForPlacementGoal: [String], away_xCordsForPlacementGoal: [String], away_yCordsForPlacementGoal: [String]){
        let realm = try! Realm()
        
        let newGameFilter = realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.gameID;
        
        let home_xCordsArray = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", newGameFilter!, homeTeam!)).value(forKeyPath: "xCordGoal") as! [Int]).compactMap({String($0)})
        let home_yCordsArray = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", newGameFilter!, homeTeam!)).value(forKeyPath: "yCordGoal") as! [Int]).compactMap({String($0)})
        let away_xCordsArray = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", newGameFilter!, awayTeam!)).value(forKeyPath: "xCordGoal") as! [Int]).compactMap({String($0)})
        let away_yCordsArray = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", newGameFilter!, awayTeam!)).value(forKeyPath: "yCordGoal") as! [Int]).compactMap({String($0)})
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
    
    func home_markerPlacement(markerType: UIImage){
        if (shot_markerProcessing().home_xCordsForPlacementShot.isEmpty == false){
            // check markerType image value
            if(markerType == homeTeamShotMakerImage) {
                print("shot maker count", shot_markerProcessing().home_xCordsForPlacementShot.count)
                print(shot_markerProcessing().home_xCordsForPlacementShot)
                print(shot_markerProcessing().home_yCordsForPlacementShot)
                for i in 0..<shot_markerProcessing().home_xCordsForPlacementShot.count{
                    shotMarkerimageView = UIImageView(frame: CGRect(x: Int(shot_markerProcessing().home_xCordsForPlacementShot[i])! - 25, y: Int(shot_markerProcessing().home_yCordsForPlacementShot[i])! - 25, width: 50, height: 50));
                    shotMarkerimageView.contentMode = .scaleAspectFill;
                    shotMarkerimageView.image = markerType;
                    view.addSubview(shotMarkerimageView);
                }
            }
            if(markerType == homeTeamGoalMakerImage) {
                for i in 0..<goal_markerProcessing().home_xCordsForPlacementGoal.count{
                    goalMarkerimageView = UIImageView(frame: CGRect(x: Int(goal_markerProcessing().home_xCordsForPlacementGoal[i])! - 25, y: Int(goal_markerProcessing().home_yCordsForPlacementGoal[i])! - 25, width: 50, height: 50));
                    goalMarkerimageView.contentMode = .scaleAspectFill;
                    goalMarkerimageView.image = markerType;
                    view.addSubview(goalMarkerimageView);
                }
            }
        }else{
            // print error id not cord data present in arrays
            //should only error out if user hasnt submittte any marker data to realm
            print("No Home Marker Cords Found on Load")
        }
    }
    
    func away_markerPlacement(markerType: UIImage){
        
        if (shot_markerProcessing().away_xCordsForPlacementShot.isEmpty == false){
            // check markerType image value
            if(markerType == awayTeamShotMarkerImage) {
                for i in 0..<shot_markerProcessing().away_xCordsForPlacementShot.count{
                    shotMarkerimageView = UIImageView(frame: CGRect(x: Int(shot_markerProcessing().away_xCordsForPlacementShot[i])! - 25, y: Int(shot_markerProcessing().away_yCordsForPlacementShot[i])! - 25, width: 50, height: 50));
                    shotMarkerimageView.contentMode = .scaleAspectFill;
                    shotMarkerimageView.image = markerType;
                    view.addSubview(shotMarkerimageView);
                }
            }
            if(markerType == awayTeamGoalMarkerImage) {
                for i in 0..<goal_markerProcessing().away_xCordsForPlacementGoal.count{
                    goalMarkerimageView = UIImageView(frame: CGRect(x: Int(goal_markerProcessing().away_xCordsForPlacementGoal[i])! - 25, y: Int(goal_markerProcessing().away_yCordsForPlacementGoal[i])! - 25, width: 50, height: 50));
                    goalMarkerimageView.contentMode = .scaleAspectFill;
                    goalMarkerimageView.image = markerType;
                    view.addSubview(goalMarkerimageView);
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
        let newHomeGameFilter = realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.homeTeamID;
        let newAwayGameFilter = realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.opposingTeamID;
        let homeTeamNameString = realm.object(ofType: teamInfoTable.self, forPrimaryKey: newHomeGameFilter);
        let awayTeamNameString = realm.object(ofType: teamInfoTable.self, forPrimaryKey: newAwayGameFilter);
        // align text in text field as well assign text value to text field to team name
        homeTeamNameLabel.text = homeTeamNameString?.nameOfTeam
        homeTeamNameLabel.textAlignment = .center
        awayTeamNameLabel.text = awayTeamNameString?.nameOfTeam
        awayTeamNameLabel.textAlignment = .center
    }
    
    func scoreInitialize(){
        
        // query realm for goal count based on newest gam
        let gameID = realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)
        let homeScoreFilter = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", (gameID?.gameID)!, homeTeam!)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        
        let awayScoreFilter = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", (gameID?.gameID)!, awayTeam!)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        // align text to center and assigned text field the value of homeScoreFilter query
        homeTeamNumGoals.text = String(homeScoreFilter)
        homeTeamNumGoals.textAlignment = .center
        awayTeamNumGoals.text = String(awayScoreFilter)
        awayTeamNumGoals.textAlignment = .center
    }
    
    func numShotInitialize(){
        
        let newGameFilter = realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?);
        // get homeTeam and away team ID's fom said lastest new game entry
        homeTeam = newGameFilter?.homeTeamID
        awayTeam = newGameFilter?.opposingTeamID
        
        //get array of team ID's and concert to regular string array from optional
        let homeShotCounter = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", (newGameFilter?.gameID)!, homeTeam!)).value(forKeyPath: "TeamID") as! [Int]).compactMap({String($0)}).count
        
        let awayShotCounter = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", (newGameFilter?.gameID)!, awayTeam!)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        // align text to center and assigned text field the value of homeScoreFilter query
        homeTeamNumShots.text = String(homeShotCounter)
        homeTeamNumShots.textAlignment = .center
        awayTeamNumShots.text = String(awayShotCounter)
        awayTeamNumShots.textAlignment = .center        
    }
    
    // single tap function applies black x to ice surface when gesture returns correct
    @objc func singleTapped() {
        print("Single Tap Detected")
        markerType = true;
        // display custom view controller alert alert
        // segue to maker info page goes here
        popUpSegue()
        
    }
    // long tap function applies red x to ice surface when gesture returns correct
    @objc func longTapped() {
        print("Long Tap Detected")
        markerType = false;
        // display custom view controller alert alert
        popUpSegue()
    }
    
    func popUpSegue(){
        
        self.performSegue(withIdentifier: "popUpSegueView", sender: nil);
        
    }
    // action when clicking done button
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        // Create you actionsheet - preferredStyle: .actionSheet
        let actionSheet = UIAlertController(title: "New Game Save State", message: "Please Select a State New Game Should be Saved to.", preferredStyle: .actionSheet)
        
        // Create your actions - take a look at different style attributes
        //saveButtonAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        let keepActiveAction = UIAlertAction(title: "Keep Active", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            // observe it in the buttons block, what button has been pressed
            print("didPress Keep Active")
            self.performSegue(withIdentifier: "newGameSegue", sender: nil)
            try! self.realm.write{
                self.realm.object(ofType: newGameTable.self, forPrimaryKey: self.realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.activeGameStatus = true
            }
        })
        
        let saveAction = UIAlertAction(title: "Save", style: .destructive, handler: { (alert: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "newGameSegue", sender: nil)
            print("didPress Save")
            try! self.realm.write{
                self.realm.object(ofType: newGameTable.self, forPrimaryKey: self.realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.activeGameStatus = false
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in
            print("didPress Cancel")
        })
        // Add the actions to your actionSheet
        actionSheet.addAction(keepActiveAction)
        actionSheet.addAction(saveAction)
        actionSheet.addAction(cancelAction)
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        
        // Present the controller
        self.present(actionSheet, animated: true, completion: nil)
    
    }
    


    // func used to pass varables on segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check is appropriate segue is being used
        if (segue.identifier == "popUpSegueView"){
            // set var vc as destination segue
            let vc = segue.destination as! Shot_Location_View
            vc.tempXCords = xLocationCords
            vc.tempYCords = yLocationCords
            vc.tempMarkerType = markerType
            vc.homeTeamID = homeTeam
            vc.awayTeamID = awayTeam
            vc.tempGoalieSelectedID = goalieSelectedID
            vc.periodNumSelected = periodNumSelected
        }
        // check is appropriate segue is being used
        else if (segue.identifier == "logoButtonSegue"){
            // set var vc as destination segue
            let vc = segue.destination as! New_Game_Basic_Info_Page
            vc.homeTeamID = homeTeam
            vc.awayTeamID = awayTeam
            vc.tempPeriodNumSelected = periodNumSelected
            vc.newGameStarted = newGameStarted
        }
            // check is appropriate segue is being used
        else if (segue.identifier == "gameStatsSegue"){
            // set var vc as destination segue
            let vc = segue.destination as! Current_Stats_Page
            vc.homeTeam = homeTeam
            vc.awayTeam = awayTeam
            vc.newGameStarted = newGameStarted
            vc.goalieSelectedID = goalieSelectedID
            vc.periodNumSelected = periodNumSelected
        }
    }
    // delay loop
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
}
