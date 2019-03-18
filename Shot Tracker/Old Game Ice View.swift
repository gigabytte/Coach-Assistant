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

class Old_Game_Ice_View: UIViewController {

    let realm = try! Realm()
    
    let homeTeamGoalMakerImage = UIImage(named: "home_team_goal.png");
    let homeTeamShotMakerImage = UIImage(named: "home_team_shot.png");
    let awayTeamGoalMarkerImage = UIImage(named: "away_team_goal.png")
    let awayTeamShotMarkerImage = UIImage(named: "away_team_shot.png")
    
    @IBOutlet weak var homeTeamNameLabel: UILabel!
    @IBOutlet weak var homeTeamNumGoals: UILabel!
    @IBOutlet weak var homeTeamNumShots: UILabel!
    @IBOutlet weak var awayTeamNumShots: UILabel!
    @IBOutlet weak var awayTeamNameLabel: UILabel!
    @IBOutlet weak var awayTeamNumGoals: UILabel!
    @IBOutlet weak var navBar: UINavigationBar!
    
    var shotMarkerimageView: UIImageView!
    var goalMarkerimageView: UIImageView!
    
    var SeletedGame: Int!
    var homeTeam: Int!
    var awayTeam: Int!
    var tagCounter: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Game ID", SeletedGame)
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
        // refrence to below functionns for loading first pv initial VC load
        self.teamIDProcessing()
        self.shot_markerProcessing()
        self.home_markerPlacement(markerType: self.homeTeamShotMakerImage!)
        self.home_markerPlacement(markerType: self.homeTeamGoalMakerImage!)
        self.goal_markerProcessing()
        self.away_markerPlacement(markerType: self.awayTeamShotMarkerImage!)
        self.away_markerPlacement(markerType: self.awayTeamGoalMarkerImage!)
        
    }
    @objc func singleShotMarkerTapped(sender: UITapGestureRecognizer?) {
        print("Shot Marker Tapped")
        let newView = sender?.view
        print(newView)
        tappedMarker(markerType: true, markerTag: newView!.tag)
       
    }
    
    @objc func singleGoalMarkerTapped(sender: UITapGestureRecognizer?) {
        print("Goal Marker Tapped")
        let newView = sender?.view
       tappedMarker(markerType: false, markerTag: newView!.tag)
    }
    
    func teamIDProcessing(){
        // get home team and away team id from the most recent new gamne entry
        let newGameFilter = self.realm.object(ofType: newGameTable.self, forPrimaryKey: SeletedGame);
        homeTeam = newGameFilter?.homeTeamID
        awayTeam = newGameFilter?.opposingTeamID
    }

    func scoreInitialize(){
    
    // query realm for goal count based on newest gam
    let homeScoreFilter = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", SeletedGame!, homeTeam!)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
    
    let awayScoreFilter = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", SeletedGame!, awayTeam!)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
    // align text to center and assigned text field the value of homeScoreFilter query
    homeTeamNumGoals.text = String(homeScoreFilter)
    homeTeamNumGoals.textAlignment = .center
    awayTeamNumGoals.text = String(awayScoreFilter)
    awayTeamNumGoals.textAlignment = .center
    }
    
    func navBarProcessing() {
        if (homeTeam != nil && awayTeam != nil){
            let home_teamNameFilter = realm.object(ofType: teamInfoTable.self, forPrimaryKey: homeTeam)?.nameOfTeam
            let away_teamNameFilter = realm.object(ofType: teamInfoTable.self, forPrimaryKey: awayTeam)?.nameOfTeam
            
            navBar.topItem!.title = "Ice Surafce View of \(home_teamNameFilter!) vs \(away_teamNameFilter!)"
        }else{
            print("Error Unable to Gather Team Name, Nav Bar Has Defaulted")
            
        }
    }

    func shot_markerProcessing() -> (home_xCordsForPlacementShot: [String], home_yCordsForPlacementShot: [String], away_xCordsForPlacementShot: [String], away_yCordsForPlacementShot: [String]){
        
        let newGameFilter = (self.realm.object(ofType: newGameTable.self, forPrimaryKey: SeletedGame)?.gameID)
        
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
        
        let newGameFilter = (self.realm.object(ofType: newGameTable.self, forPrimaryKey: SeletedGame)?.gameID)
        
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
    
    func tappedMarker(markerType: Bool, markerTag: Int){
        if(markerType == true){
            let selectedShotMarker = view.viewWithTag(markerTag)
            let markerCords: CGPoint = selectedShotMarker!.frame.origin
            let xMarkerCord: Int = Int(markerCords.x + 25)
            let yMarkerCord: Int = Int(markerCords.y + 25)
            print("Cords for shot image are: \(xMarkerCord) and \(yMarkerCord)")
            
            let shotLocation = (self.realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "xCordShot == %i AND yCordShot == %i AND gameID == %i AND activeState == true", xMarkerCord, yMarkerCord, SeletedGame!)).value(forKeyPath: "shotLocation") as! [Int]).compactMap({Int($0)})
            let goalieID = (self.realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "xCordShot == %i AND yCordShot == %i AND gameID == %i AND activeState == true", xMarkerCord, yMarkerCord, SeletedGame!)).value(forKeyPath: "goalieID") as! [Int]).compactMap({Int($0)})
            let goalieName = self.realm.object(ofType: playerInfoTable.self, forPrimaryKey: goalieID[0])?.playerName;
            let teamID = (self.realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "xCordShot == %i AND yCordShot == %i AND gameID == %i AND activeState == true", xMarkerCord, yMarkerCord, SeletedGame!)).value(forKeyPath: "TeamID") as! [Int]).compactMap({Int($0)})
            let teamName = self.realm.object(ofType: teamInfoTable.self, forPrimaryKey: teamID[0])?.nameOfTeam;
            
            let actionSheet = UIAlertController(title: "Shot Marker Details", message: "Shot Location: \(shotLocationConversion(shotLocationInt: shotLocation[0])) \n Goalie Shot on: \(goalieName!) \n Shot by team: \(teamName!)", preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (alert: UIAlertAction!) -> Void in
                // observe it in the buttons block, what button has been pressed
                print("didPress Ok")
            })
            actionSheet.addAction(okAction)
            if let popoverController = actionSheet.popoverPresentationController {
                popoverController.sourceView = selectedShotMarker!
            }
            // Present the controller
            self.present(actionSheet, animated: true, completion: nil)
        }else{
             let selectedGoalMarker = view.viewWithTag(markerTag)
            let markerCords: CGPoint = selectedGoalMarker!.frame.origin
            let xMarkerCord = Int(markerCords.x + 25)
            let yMarkerCord = Int(markerCords.y + 25)
            print("Cords for goal image are: \(xMarkerCord) and \(yMarkerCord)")
            let shotLocation = (self.realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "xCordGoal == %i AND yCordGoal == %i AND gameID == %i AND activeState == true", xMarkerCord, yMarkerCord, self.SeletedGame!)).value(forKeyPath: "shotLocation") as! [Int]).compactMap({Int($0)})
            let goalieID = (self.realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "xCordGoal == %i AND yCordGoal == %i AND gameID == %i AND activeState == true", xMarkerCord, yMarkerCord, SeletedGame!)).value(forKeyPath: "goalieID") as! [Int]).compactMap({Int($0)})
            let goalieName = self.realm.object(ofType: playerInfoTable.self, forPrimaryKey: goalieID[0])?.playerName;
            let teamID = (self.realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "xCordGoal == %i AND yCordGoal == %i AND gameID == %i AND activeState == true", xMarkerCord, yMarkerCord, SeletedGame!)).value(forKeyPath: "TeamID") as! [Int]).compactMap({Int($0)})
            let teamName = self.realm.object(ofType: teamInfoTable.self, forPrimaryKey: teamID[0])?.nameOfTeam;
            let scoringPlayerID = (self.realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "xCordGoal == %i AND yCordGoal == %i AND gameID == %i AND activeState == true", xMarkerCord, yMarkerCord, SeletedGame!)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})
            let scoringPlayerName = self.realm.object(ofType: playerInfoTable.self, forPrimaryKey: scoringPlayerID[0])?.playerName;
            
            let actionSheet = UIAlertController(title: "Goal Marker Details", message: "Goal Location: \(shotLocationConversion(shotLocationInt: shotLocation[0])) \n Goalie Shot on: \(goalieName!) \n Scored by team: \(teamName!) \n Player Scored: \(scoringPlayerName!)", preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (alert: UIAlertAction!) -> Void in
                // observe it in the buttons block, what button has been pressed
                print("didPress Ok")
            })
            actionSheet.addAction(okAction)
            if let popoverController = actionSheet.popoverPresentationController {
                popoverController.sourceView = selectedGoalMarker
            }
            // Present the controller
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    func home_markerPlacement(markerType: UIImage){
        if (shot_markerProcessing().home_xCordsForPlacementShot.isEmpty == false || goal_markerProcessing().away_xCordsForPlacementGoal.isEmpty == false){
            // check markerType image value
            if(markerType == homeTeamShotMakerImage) {
                for i in 0..<shot_markerProcessing().home_xCordsForPlacementShot.count{
                    let imageView = UIImageView(frame: CGRect(x: Int(shot_markerProcessing().home_xCordsForPlacementShot[i])! - 25, y: Int(shot_markerProcessing().home_yCordsForPlacementShot[i])! - 25, width: 50, height: 50));
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
            if(markerType == homeTeamGoalMakerImage) {
                for i in 0..<goal_markerProcessing().home_xCordsForPlacementGoal.count{
                    let imageView = UIImageView(frame: CGRect(x: Int(goal_markerProcessing().home_xCordsForPlacementGoal[i])! - 25, y: Int(goal_markerProcessing().home_yCordsForPlacementGoal[i])! - 25, width: 50, height: 50));
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
        }else{
            // print error id not cord data present in arrays
            //should only error out if user hasnt submittte any marker data to realm
            print("No Home Marker Cords Found on Load")
        }
    }
    func away_markerPlacement(markerType: UIImage){
        if (shot_markerProcessing().away_xCordsForPlacementShot.isEmpty == false || goal_markerProcessing().away_xCordsForPlacementGoal.isEmpty == false){
            // check markerType image value
            if(markerType == awayTeamShotMarkerImage) {
                for i in 0..<shot_markerProcessing().away_xCordsForPlacementShot.count{
                    let imageView = UIImageView(frame: CGRect(x: Int(shot_markerProcessing().away_xCordsForPlacementShot[i])! - 25, y: Int(shot_markerProcessing().away_yCordsForPlacementShot[i])! - 25, width: 50, height: 50));
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
                    let imageView = UIImageView(frame: CGRect(x: Int(goal_markerProcessing().away_xCordsForPlacementGoal[i])! - 25, y: Int(goal_markerProcessing().away_yCordsForPlacementGoal[i])! - 25, width: 50, height: 50));
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
        }else{
            // print error id not cord data present in arrays
            //should only error out if user hasnt submittte any marker data to realm
            print("No Away Marker Cords Found on Load")
        }
    }
    
    func teamNameInitialize(){
        
        // query realm for team naames based on newest game
        let newHomeGameFilter = (self.realm.object(ofType: newGameTable.self, forPrimaryKey: SeletedGame)?.homeTeamID)
        let newAwayGameFilter = (self.realm.object(ofType: newGameTable.self, forPrimaryKey: SeletedGame)?.opposingTeamID)
        let homeTeamNameString = realm.object(ofType: teamInfoTable.self, forPrimaryKey: newHomeGameFilter);
        let awayTeamNameString = realm.object(ofType: teamInfoTable.self, forPrimaryKey: newAwayGameFilter);
        // align text in text field as well assign text value to text field to team name
        homeTeamNameLabel.text = homeTeamNameString?.nameOfTeam
        homeTeamNameLabel.textAlignment = .center
        awayTeamNameLabel.text = awayTeamNameString?.nameOfTeam
        awayTeamNameLabel.textAlignment = .center
    }
    
    func numShotInitialize(){
        
        let newGameFilter = (self.realm.object(ofType: newGameTable.self, forPrimaryKey: SeletedGame))
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check is appropriate segue is being used
        if (segue.identifier == "statsSegue"){
            // set var vc as destination segue
            let vc = segue.destination as! Old_Stats_Game_Details_Page
            vc.SeletedGame = SeletedGame
        }
        if (segue.identifier == "oldStatsAnalyticsPopUp"){
            // set var vc as destination segue
            let vc = segue.destination as! Current_Stats_Ananlytical_View
            vc.SeletedGame = SeletedGame
            vc.oldStatsPopUpBool = true
        }
    }

}
