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


class Current_Stats_Page: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var homeTeamNameTextField: UILabel!
    @IBOutlet weak var awayTeamNameTextField: UILabel!
    @IBOutlet weak var homeTeamScoreTextField: UILabel!
    @IBOutlet weak var awayTeamScoreTextField: UILabel!
    @IBOutlet weak var homeNumShotTextField: UILabel!
    @IBOutlet weak var awayNumShotTextField: UILabel!
    @IBOutlet weak var homePlayerStatsTable: UITableView!
    @IBOutlet weak var awayPlayerStatsTable: UITableView!

    
    var homeTeam: Int!
    var awayTeam: Int!
    var teamIDArray: [String] = [String]()
    var newGameStarted: Bool!
    var goalieSelectedID: Int!
    var periodNumSelected: Int!
    var homePlayerStatsArray: [String] = [String]()
    
    let textCellIdentifier = "cell"

    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homePlayerStatsTable.allowsSelection = false
        awayPlayerStatsTable.allowsSelection = false
        homePlayerStatsTable.dataSource = self
        homePlayerStatsTable.delegate = self
        awayPlayerStatsTable.dataSource = self
        awayPlayerStatsTable.delegate = self
        
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
        home_playerStatsProcessing()
        
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
    
    func home_playerStatsProcessing(){
        
        let newGameFilter = realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?);
            
        let homeScoringPlayerID = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "TeamID == %i AND gameID == %i AND activeState == true", newGameFilter!.homeTeamID, newGameFilter!.gameID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})
        let homeAssitPlayerID = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "TeamID == %i AND gameID == %i AND activeState == true", newGameFilter!.homeTeamID, newGameFilter!.gameID)).value(forKeyPath: "assitantPlayerID") as! [Int]).compactMap({Int($0)})
        let homeAssit2PlayerID = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "TeamID == %i AND gameID == %i AND activeState == true", newGameFilter!.homeTeamID, newGameFilter!.gameID)).value(forKeyPath: "sec_assitantPlayerID") as! [Int]).compactMap({Int($0)})
        
        let homePlayerName = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == true", String(newGameFilter!.homeTeamID))).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)})
       
        var numberOfGoalsEach: [Int: Int] = [:]
        var numberOfAssitsEach: [Int: Int] = [:]
        var numberOfSecAssitsEach: [Int: Int] = [:]
        // calc the number of occuring goals in query for each player
        homeScoringPlayerID.forEach { numberOfGoalsEach[$0, default: 0] += 1 }
        homeAssitPlayerID.forEach { numberOfAssitsEach[$0, default: 0] += 1 }
        print(numberOfAssitsEach)
        homeAssit2PlayerID.forEach { numberOfSecAssitsEach[$0, default: 0] += 1 }
        // get all player id's from home team to compare against
        let homePlayerID = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == true", String(newGameFilter!.homeTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        print(homePlayerID)
        // map values from dictionary sorting to array bpoth in terms of dictionary keys and names
        let tempGoalDicKeyArray = Array(numberOfGoalsEach.keys)
        let tempGoalDicValuesArray = Array(numberOfGoalsEach.values)
        let tempAssitDicKeyArray = Array(numberOfAssitsEach.keys)
        let tempAssitDicValuesArray = Array(numberOfAssitsEach.values)
        //let tempSecAssitDicValuesArray = Array(numberOfSecAssitsEach.values)
        
        let maxForLoopCount = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == true", String(newGameFilter!.homeTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({String($0)}).count
        for x in 0..<maxForLoopCount{
            
            if(tempGoalDicKeyArray.indices.contains(homePlayerID[x]) != false){
                
                homePlayerStatsArray.append("\(homePlayerName[x]) Stats\nGoals: \(tempGoalDicValuesArray[x])\n ")
            }else{
                homePlayerStatsArray.append("\(homePlayerName[x]) Stats\nGoals: 0\n")
                
            }
            print(tempAssitDicKeyArray)
            if(tempAssitDicKeyArray.indices.contains(homePlayerID[x]) != false){
                homePlayerStatsArray[x] = homePlayerStatsArray[x] + "Assits: \(tempAssitDicValuesArray[x])\n"
            }else{
                homePlayerStatsArray[x] = homePlayerStatsArray[x] + "Assits: 0\n"
            }
        }
    }
    
    // Returns count of items in tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let newGameFilter = realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?);
        if (tableView == homePlayerStatsTable){
            //print("table view count", (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == true", String(newGameFilter!.homeTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({String($0)}).count)
            return((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == true", String(newGameFilter!.homeTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({String($0)}).count)
        }else{
            return((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == true", String(newGameFilter!.opposingTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({String($0)}).count)
        }
    }
    //Assign values for tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newGameFilter = realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?);
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel!.numberOfLines = 0;
        //if (tableView == homePlayerStatsTable){
        cell.textLabel?.text = homePlayerStatsArray[indexPath.row]
        print(cell)
        return cell
               
        }
            
            
        //}
       
        /*else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            cell.textLabel?.text = homePlayerStatsArray[indexPath.row]
            print(cell)
            return cell
 
        }*/
   //}
    
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
