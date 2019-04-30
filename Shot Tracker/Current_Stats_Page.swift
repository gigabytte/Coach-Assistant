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
    @IBOutlet weak var gameLocationLabel: UILabel!
    
    // vars used on segue passing
    var homeTeam: Int = UserDefaults.standard.integer(forKey: "homeTeam")
    var awayTeam: Int = UserDefaults.standard.integer(forKey: "awayTeam")
    var teamIDArray: [String] = [String]()
    var homePlayerStatsArray: [String] = [String]()
    var awayPlayerStatsArray: [String] = [String]()
    var homePlayerIDs: [Int] = [Int]()
    var awayPlayerIDs: [Int] = [Int]()

    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         let gameLocation = realm.object(ofType: newGameTable.self, forPrimaryKey: realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.gameID)!.gameLocation
        gameLocationLabel.text = "Game Location:\n\(gameLocation)"
        gameLocationLabel.textAlignment = .center
        
        // round corner of table views
        homePlayerStatsTable.layer.cornerRadius = 10
        awayPlayerStatsTable.layer.cornerRadius = 10
        home_playerStatsProcessing()
        away_playerStatsProcessing()
        
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
        let homeScoreFilter = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND activeState == true", (gameID?.gameID)!, homeTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        
        let awayScoreFilter = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND activeState == true", (gameID?.gameID)!, awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        
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
        homeTeam = (newGameFilter?.homeTeamID)!
        awayTeam = (newGameFilter?.opposingTeamID)!
        //get array of team ID's and concert to regular string array from optional
        let homeShotCounter = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND activeState == true", (newGameFilter?.gameID)!, homeTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        
        let awayShotCounter = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND activeState == true", (newGameFilter?.gameID)!, awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        
        // align text to center and assigned text field the value of homeScoreFilter query
        homeNumShotTextField.text = "Number of Shots: " + String(homeShotCounter)
        homeNumShotTextField.textAlignment = .center
        awayNumShotTextField.text = "Number of Shots: " + String(awayShotCounter)
        awayNumShotTextField.textAlignment = .center
        
        return(Double(homeShotCounter), Double(awayShotCounter))
        
    }
    
    func home_playerStatsProcessing(){
        
        let newGameFilter = realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?);
        
       homePlayerIDs = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == true", String(newGameFilter!.homeTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        
        for x in 0..<homePlayerIDs.count{
            //-------------------- goal count -----------------------
            // get number fos goals from player based oin looping player id
            let nextPlayerCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "goalPlayerID == %i AND gameID == %i AND activeState == true", homePlayerIDs[x], newGameFilter!.gameID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})).count
            // if number of goals is not 0 aka the player scorerd atleast once
            // ass goals to player stats if not set as zero

            let homePlayerName = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", homePlayerIDs[x])).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)})
             let homePlayerNum = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", homePlayerIDs[x])).value(forKeyPath: "jerseyNum") as! [Int]).compactMap({String($0)})
            homePlayerStatsArray.append("\(homePlayerName[0])'s #\(homePlayerNum[0]) Current Stats\nGoals: \(nextPlayerCount)\n")
           // ------------------ assits count -----------------------------
            // get number of assist from player based on looping player id
            let nextPlayerAssitCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "assitantPlayerID == %i AND gameID == %i AND activeState == true", homePlayerIDs[x], newGameFilter!.gameID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})).count
            let sec_nextPlayerAssitCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "assitantPlayerID == %i AND gameID == %i AND activeState == true", homePlayerIDs[x], newGameFilter!.gameID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})).count
            // if number of assits is not 0 aka the player did not get assist atleast once
            //  set assist num to 0
            if (nextPlayerAssitCount != 0 || sec_nextPlayerAssitCount != 0){
                homePlayerStatsArray[x] = homePlayerStatsArray[x] + "Assits: \(String(nextPlayerAssitCount + sec_nextPlayerAssitCount)) \n"
            }else{
                homePlayerStatsArray[x] = homePlayerStatsArray[x] + "Assits: 0 \n"
            }
            // ------------------ plus minus count -----------------------------
            // get current looping player's plus minus
            let goalCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "TeamID == %i AND assitantPlayerID == %i AND gameID == %i AND activeState == true", homeTeam, homePlayerIDs[x], newGameFilter!.gameID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})).count
            let assitsCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "TeamID == %i AND assitantPlayerID == %i AND gameID == %i AND activeState == true",homeTeam, homePlayerIDs[x], newGameFilter!.gameID)).value(forKeyPath: "assitantPlayerID") as! [Int]).compactMap({Int($0)})).count
            let sec_assitsCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "TeamID == %i AND assitantPlayerID == %i AND gameID == %i AND activeState == true",homeTeam, homePlayerIDs[x], newGameFilter!.gameID)).value(forKeyPath: "sec_assitantPlayerID") as! [Int]).compactMap({Int($0)})).count
            let plusTotal = goalCount + assitsCount + sec_assitsCount
            let playerLine = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", homePlayerIDs[x])).value(forKeyPath: "lineNum") as! [Int]).compactMap({Int($0)}))[0]
            var plusMinusTotal:Int = 0
            if (playerLine <= 3){
                let againstGoalCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "TeamID == %i AND againstFLine == %i AND gameID == %i AND activeState == true", awayTeam, playerLine, newGameFilter!.gameID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})).count
                plusMinusTotal = plusTotal - againstGoalCount
            }else{
                let againstGoalCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "TeamID == %i AND againstDLine == %i AND gameID == %i AND activeState == true", awayTeam, playerLine, newGameFilter!.gameID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})).count
                plusMinusTotal = plusTotal - againstGoalCount
                
            }
            
            homePlayerStatsArray[x] = homePlayerStatsArray[x] + "In Game Plus/Minus: \(String(plusMinusTotal))"
            
        }
    }
        
        func away_playerStatsProcessing(){
            
            let newGameFilter = realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?);
            
            awayPlayerIDs = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == true", String(newGameFilter!.opposingTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
            
            for x in 0..<awayPlayerIDs.count{
                //-------------------- goal count -----------------------
                // get number fos goals from player based oin looping player id
                let nextPlayerCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "goalPlayerID == %i AND gameID == %i AND activeState == true", awayPlayerIDs[x], newGameFilter!.gameID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})).count
                // if number of goals is not 0 aka the player scorerd atleast once
                // ass goals to player stats if not set as zero
                
                let homePlayerName = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", awayPlayerIDs[x])).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)})
                let homePlayerNum = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", awayPlayerIDs[x])).value(forKeyPath: "jerseyNum") as! [Int]).compactMap({String($0)})
                awayPlayerStatsArray.append("\(homePlayerName[0])'s #\(homePlayerNum[0]) Current Stats\nGoals: \(nextPlayerCount)\n")
                // ------------------ assits count -----------------------------
                // get number of assist from player based on looping player id
                let nextPlayerAssitCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "assitantPlayerID == %i AND gameID == %i AND activeState == true", awayPlayerIDs[x], newGameFilter!.gameID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})).count
                let sec_nextPlayerAssitCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "assitantPlayerID == %i AND gameID == %i AND activeState == true", awayPlayerIDs[x], newGameFilter!.gameID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})).count
                // if number of assits is not 0 aka the player did not get assist atleast once
                //  set assist num to 0
                if (nextPlayerAssitCount != 0 || sec_nextPlayerAssitCount != 0){
                    awayPlayerStatsArray[x] = awayPlayerStatsArray[x] + "Assits: \(String(nextPlayerAssitCount + sec_nextPlayerAssitCount)) \n"
                }else{
                    awayPlayerStatsArray[x] = awayPlayerStatsArray[x] + "Assits: 0 \n"
                }
                // ------------------ plus minus count -----------------------------
                // get current looping player's plus minus
                let goalCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "TeamID == %i AND assitantPlayerID == %i AND gameID == %i AND activeState == true", awayTeam, awayPlayerIDs[x], newGameFilter!.gameID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})).count
                let assitsCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "TeamID == %i AND assitantPlayerID == %i AND gameID == %i AND activeState == true",awayTeam, awayPlayerIDs[x], newGameFilter!.gameID)).value(forKeyPath: "assitantPlayerID") as! [Int]).compactMap({Int($0)})).count
                let sec_assitsCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "TeamID == %i AND assitantPlayerID == %i AND gameID == %i AND activeState == true",awayTeam, awayPlayerIDs[x], newGameFilter!.gameID)).value(forKeyPath: "sec_assitantPlayerID") as! [Int]).compactMap({Int($0)})).count
                let plusTotal = goalCount + assitsCount + sec_assitsCount
                let playerLine = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", awayPlayerIDs[x])).value(forKeyPath: "lineNum") as! [Int]).compactMap({Int($0)}))[0]
                var plusMinusTotal:Int = 0
                if (playerLine <= 3){
                    let againstGoalCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "TeamID == %i AND againstFLine == %i AND gameID == %i AND activeState == true", homeTeam, playerLine, newGameFilter!.gameID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})).count
                    plusMinusTotal = plusTotal - againstGoalCount
                }else{
                    let againstGoalCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "TeamID == %i AND againstDLine == %i AND gameID == %i AND activeState == true", homeTeam, playerLine, newGameFilter!.gameID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})).count
                    plusMinusTotal = plusTotal - againstGoalCount
                    
                }
                
                awayPlayerStatsArray[x] = awayPlayerStatsArray[x] + "In Game Plus/Minus: \(String(plusMinusTotal))"
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
       
            if (tableView == homePlayerStatsTable){
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                cell.textLabel!.numberOfLines = 0;
                cell.textLabel?.text = homePlayerStatsArray[indexPath.row]
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                cell.textLabel!.numberOfLines = 0;
                //if (tableView == homePlayerStatsTable){
                cell.textLabel?.text = awayPlayerStatsArray[indexPath.row]
                return cell
                
            }
        }
    
    
    
}
