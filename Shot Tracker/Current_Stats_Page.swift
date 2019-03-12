//
//  Current_Stats_Page.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-02-05.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import Charts

class Current_Stats_Page: UIViewController {
    
    @IBOutlet weak var homeTeamNameTextField: UILabel!
    @IBOutlet weak var awayTeamNameTextField: UILabel!
    @IBOutlet weak var homeTeamScoreTextField: UILabel!
    @IBOutlet weak var awayTeamScoreTextField: UILabel!
    @IBOutlet weak var homeNumShotTextField: UILabel!
    @IBOutlet weak var awayNumShotTextField: UILabel!
    
    var homeTeam: Int!
    var awayTeam: Int!
    var teamIDArray: [String] = [String]()
    var newGameStarted: Bool!
    var goalieSelectedID: Int!
    var periodNumSelected: Int!
    
    var homeTeamShotsPie = PieChartDataEntry(value: 0)
    var homeTeamGoalsPie = PieChartDataEntry(value: 0)
    var awayTeamShotsPie = PieChartDataEntry(value: 0)
    var awayTeamGoalsPie = PieChartDataEntry(value: 0)
    
    var tlShotValue = PieChartDataEntry(value: 0)
    var trShotValue = PieChartDataEntry(value: 0)
    var blShotValue = PieChartDataEntry(value: 0)
    var brShotValue = PieChartDataEntry(value: 0)
    var cShotValue = PieChartDataEntry(value: 0)
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Away team ID", awayTeam)
        teamNameInitialize()
        
        // call functions for stats page dynamic function
        if (realm.objects(newGameTable.self).filter("gameID >= 0").last != nil && realm.objects(goalMarkersTable.self).filter("cordSetID >= 0").last != nil){
            scoreInitialize()
            print("Succesfully Rendered Current Goal Stats")
        }else{
            // align text in text field as well assign text value to text field to team name
            homeTeamScoreTextField.text = String(0)
            homeTeamScoreTextField.textAlignment = .center
            awayTeamScoreTextField.text = String(0)
            awayTeamScoreTextField.textAlignment = .center
            print("Current Goal Stats Defaulted to 0")
        }
        if(realm.objects(newGameTable.self).filter("gameID >= 0").last != nil && realm.objects(shotMarkerTable.self).filter("cordSetID >= 0").last != nil){
            numShotInitialize()
            
            print("Succesfully Rendered Current Shot Stats")
        }else{
            // align text to center and assigned text field the value of homeScoreFilter query
            homeNumShotTextField.text = "Number of Shots: " + String(0)
            homeNumShotTextField.textAlignment = .center
            awayNumShotTextField.text = "Number of Shots: " + String(0)
            awayNumShotTextField.textAlignment = .center
            print("Current Shot Stats Defaulted to 0")
            
        }
        
    }
    
    func teamNameInitialize(){
        
        // query realm for team naames based on newest game
        let homeTeamNameString = realm.object(ofType: teamInfoTable.self, forPrimaryKey: realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.homeTeamID)!
        let awayTeamNameString = realm.object(ofType: teamInfoTable.self, forPrimaryKey: realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.opposingTeamID)!
        // align text in text field as well assign text value to text field to team name
        homeTeamNameTextField.text = homeTeamNameString.nameOfTeam
        homeTeamNameTextField.textAlignment = .center
        awayTeamNameTextField.text = awayTeamNameString.nameOfTeam
        awayTeamNameTextField.textAlignment = .center
    }
    
    func scoreInitialize() -> (Double, Double){
        
        // query realm for goal count based on newest gam
        let gameID = realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)
        let homeScoreFilter = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND activeState == true", (gameID?.gameID)!, homeTeam!)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        
        let awayScoreFilter = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND activeState == true", (gameID?.gameID)!, awayTeam!)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        
        // align text to center and assigned text field the value of homeScoreFilter query
        homeTeamScoreTextField.text = String(homeScoreFilter)
        homeTeamScoreTextField.textAlignment = .center
        awayTeamScoreTextField.text = String(awayScoreFilter)
        awayTeamScoreTextField.textAlignment = .center
        
        return(Double(homeScoreFilter), Double(awayScoreFilter))
    }
    
    func numShotInitialize() -> (Double, Double){
        
        let newGameFilter = realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?);
        // get homeTeam and away team ID's fom said lastest new game entry
        homeTeam = newGameFilter?.homeTeamID
        awayTeam = newGameFilter?.opposingTeamID
        //get array of team ID's and concert to regular string array from optional
        let homeShotCounter = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND activeState == true", (newGameFilter?.gameID)!, homeTeam!)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        
        let awayShotCounter = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND activeState == true", (newGameFilter?.gameID)!, awayTeam!)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        
        // align text to center and assigned text field the value of homeScoreFilter query
        homeNumShotTextField.text = "Number of Shots: " + String(homeShotCounter)
        homeNumShotTextField.textAlignment = .center
        awayNumShotTextField.text = "Number of Shots: " + String(awayShotCounter)
        awayNumShotTextField.textAlignment = .center
        
        return(Double(homeShotCounter), Double(awayShotCounter))
        
    }
    // func used to pass varables on segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check is appropriate segue is being used
        if (segue.identifier == "backFromCurrentGameStatsSegue"){
            // set var vc as destination segue
            let currentStats = segue.destination as! New_Game_Page
            currentStats.newGameStarted = false
            currentStats.homeTeam = homeTeam
            currentStats.awayTeam = awayTeam
            currentStats.goalieSelectedID = goalieSelectedID
            currentStats.periodNumSelected = periodNumSelected
        }
        if (segue.identifier == "analyticalSegue"){
            // set var vc as destination segue
            let currentStats = segue.destination as! Current_Stats_Ananlytical_View
            currentStats.newGameStarted = false
            currentStats.homeTeam = homeTeam
            currentStats.awayTeam = awayTeam
            currentStats.goalieSelectedID = goalieSelectedID
            currentStats.periodNumSelected = periodNumSelected
        }
        
    }
    
}
