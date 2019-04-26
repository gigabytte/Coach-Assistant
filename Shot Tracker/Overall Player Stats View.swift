//
//  Overall Player Stats View.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-03-15.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class Overall_Player_Stats_View: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    let realm = try! Realm()
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
    @IBOutlet weak var playerSatsTable: UITableView!
    @IBOutlet weak var goalieStatsTable: UITableView!
    @IBOutlet weak var teamRecordLabel: UILabel!
    
    var homePlayerStatsArray: [String] = [String]()
    var homePlayerNames: [String] = [String]()
    var homeGoalieNames: [String] = [String]()
    var goalieStatsArray:  [String] = [String]()
    var lineStatsArray:  [String] = [String]()
    var homePlayerIDs: [Int] = [Int]()
    var goalieIDArray: [Int] = [Int]()
    var lineIDArray: [Int] = [Int]()
    var homeTeamID :Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.playerSatsTable.estimatedRowHeight = 75.0
        self.playerSatsTable.rowHeight = UITableView.automaticDimension
        
        homePlayerIDs = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == true", String(homeTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        goalieIDArray = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType == %@ AND activeState == true", String(homeTeamID), "G")).value(forKeyPath: "playerID")
            as! [Int]).compactMap({Int($0)})
        
        playerNameFetch()
        goalieNameFetch()
        recordLabelProcessing()
        playerStatsProcessing()
        goalieStatsProcessing()
        
        playerSatsTable.layer.cornerRadius = 10
        goalieStatsTable.layer.cornerRadius = 10
       
        playerSatsTable.dataSource = self
        playerSatsTable.delegate = self
        goalieStatsTable.dataSource = self
        goalieStatsTable.delegate = self
        
    }
    
    
    func playerNameFetch(){
        if (homePlayerIDs.isEmpty != true){
            for x in 0..<homePlayerIDs.count{
                
                let queryPlayerName = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", homePlayerIDs[x])).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)})).first
                let queryPlayerNumber = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", homePlayerIDs[x])).value(forKeyPath: "jerseyNum") as! [Int]).compactMap({Int($0)})).first
                
                let playerFormatter = "\(queryPlayerName!) #\(queryPlayerNumber!)"
                homePlayerNames.append(playerFormatter)
            }
        }else{
         homePlayerNames[0] = "No Players Found"
            
        }
    }
    
    func goalieNameFetch(){
        if (goalieIDArray.isEmpty != true){
            for x in 0..<goalieIDArray.count{
                
                let queryGoalieName = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND positionType == %@ AND activeState == true", goalieIDArray[x], "G")).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)})).first
                let queryGoalieNumber = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND positionType == %@ AND activeState == true", goalieIDArray[x], "G")).value(forKeyPath: "jerseyNum") as! [Int]).compactMap({Int($0)})).first
                print("\(queryGoalieNumber) \(queryGoalieName)")
                let goalieFormatter = "\(queryGoalieName!) #\(queryGoalieNumber!)"
                homeGoalieNames.append(goalieFormatter)
            }
        }else{
            homeGoalieNames[0] = "No Goalies Found"
        }
    }
    
    func recordLabelProcessing(){
        
        let teamName = ((realm.objects(teamInfoTable.self).filter(NSPredicate(format: "teamID == %i AND activeState == true", homeTeamID)).value(forKeyPath: "nameOfTeam") as! [String]).compactMap({String($0)}))[0]
        let homeTeamWinCount = (realm.objects(newGameTable.self).filter(NSPredicate(format: "tieGameBool == false AND winingTeamID == %i AND activeState == true", homeTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)}).count
        let homeTeamTieCount =  (realm.objects(newGameTable.self).filter(NSPredicate(format: "tieGameBool == true AND homeTeamID == %i AND activeState == true", homeTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)}).count
        let homeTeamLooseCount =  (realm.objects(newGameTable.self).filter(NSPredicate(format: "tieGameBool == false AND losingTeamID == %i AND activeState == true", homeTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)}).count
        
        teamRecordLabel.text = "\(teamName)'s Record W:\(String(homeTeamWinCount))-L:\(String(homeTeamLooseCount))-T:\(String(homeTeamTieCount))"
    }
    
    func playerStatsProcessing(){
        
        for x in 0..<homePlayerIDs.count{
            // ------------------ player position -----------------------
            let playerPosition = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", homePlayerIDs[x])).value(forKeyPath: "positionType") as! [String]).compactMap({String($0)})
            homePlayerStatsArray.append("Position: \(playerPosition[0])\n")
            // ------------------ player line -----------------------
            let playerLineNum = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", homePlayerIDs[x])).value(forKeyPath: "lineNum") as! [Int]).compactMap({Int($0)})
            switch playerLineNum[0]{
            case 0:
                homePlayerStatsArray[x] = homePlayerStatsArray[x] + "Line Number: G\n"
            case 1:
                homePlayerStatsArray[x] = homePlayerStatsArray[x] + "Line Number: F1\n"
            case 2:
                homePlayerStatsArray[x] = homePlayerStatsArray[x] + "Line Number: F2\n"
            case 3:
                homePlayerStatsArray[x] = homePlayerStatsArray[x] + "Line Number: F3\n"
            case 4:
                homePlayerStatsArray[x] = homePlayerStatsArray[x] + "Line Number: D1\n"
            case 5:
                homePlayerStatsArray[x] = homePlayerStatsArray[x] + "Line Number: D2\n"
            case 6:
                homePlayerStatsArray[x] = homePlayerStatsArray[x] + "Line Number: D3\n"
            default:
                homePlayerStatsArray[x] = homePlayerStatsArray[x] + "Line Number: N/A\n"
            }
            
            //-------------------- goal count -----------------------
            // get number fos goals from player based oin looping player id
            let nextPlayerCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "goalPlayerID == %i AND gameID == %i AND activeState == true", homePlayerIDs[x], homeTeamID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})).count
            // if number of goals is not 0 aka the player scorerd atleast once
            // ass goals to player stats if not set as zero
            homePlayerStatsArray[x] = homePlayerStatsArray[x] + "Goals: \(nextPlayerCount)\n"
            // ------------------ assits count -----------------------------
            // get number of assist from player based on looping player id
            let nextPlayerAssitCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "assitantPlayerID == %i AND gameID == %i AND activeState == true", homePlayerIDs[x], homeTeamID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})).count
            let sec_nextPlayerAssitCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "assitantPlayerID == %i AND gameID == %i AND activeState == true", homePlayerIDs[x], homeTeamID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})).count
            // if number of assits is not 0 aka the player did not get assist atleast once
            //  set assist num to 0
            if (nextPlayerAssitCount != 0 || sec_nextPlayerAssitCount != 0){
                homePlayerStatsArray[x] = homePlayerStatsArray[x] + "Assits: \(String(nextPlayerAssitCount + sec_nextPlayerAssitCount)) \n"
            }else{
                homePlayerStatsArray[x] = homePlayerStatsArray[x] + "Assits: 0 \n"
            }
            // ------------------ plus minus count -----------------------------
            // get current looping player's plus minus
            let nextPlayerPlusMinus = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID = %i AND activeState == true", homePlayerIDs[x])).value(forKeyPath: "plusMinus") as! [Int]).compactMap({Int($0)})
            homePlayerStatsArray[x] = homePlayerStatsArray[x] + "Overall Plus/Minus: \(String(nextPlayerPlusMinus[0])) \n"
            // ------------------ player's line minus count -----------------------------
            // add all plus/minus from all member of the current player ids line for the overall line plus minus
            let nextPlayerLineNum = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID = %i AND activeState == true", homePlayerIDs[x])).value(forKeyPath: "lineNum") as! [Int]).compactMap({Int($0)})
            let allPlayersOnLine = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "lineNum = %i AND TeamID == %@ AND activeState == true", nextPlayerLineNum[0], String(homeTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
            var totalPlusMinus: Int = 0
            for i in 0..<allPlayersOnLine.count{
                
                totalPlusMinus = totalPlusMinus + ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID = %i AND activeState == true", allPlayersOnLine[i])).value(forKeyPath: "plusMinus") as! [Int]).compactMap({Int($0)}))[0]
                
            }
            homePlayerStatsArray[x] = homePlayerStatsArray[x] + "Overall Line Plus/Minus: \(String(totalPlusMinus))"
            
        }
    }
    
    func goalieStatsProcessing(){
        
        for x in 0..<goalieIDArray.count{
            print("Goalie ID", goalieIDArray[x])
            //----------- goals against avg -------------------------
             let numberOfHomeGames = ((realm.objects(newGameTable.self).filter(NSPredicate(format: "homeTeamID == %i AND activeState == true", homeTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)})).count
             let numberOfAwayGames = ((realm.objects(newGameTable.self).filter(NSPredicate(format: "opposingTeamID == %i AND activeState == true", homeTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)})).count
             let numberOfGoalsAgainst = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "goalieID == %i AND activeState == true", goalieIDArray[x], homeTeamID)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)})).count
            
            let GAA:Double = Double(numberOfGoalsAgainst) / Double(numberOfHomeGames + numberOfAwayGames)
            goalieStatsArray.append("Goals Against Average: \(String(format: "%.2f", GAA))\n")
            
            //-------------- save % overall ------------------
            let homeGoalieShots = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "goalieID == %i AND activeState == true", goalieIDArray[x])).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count
            let homeGoalieGoals = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "goalieID == %i AND activeState == true", goalieIDArray[x])).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count
            print(homeGoalieShots, homeGoalieGoals)
            if (homeGoalieShots != 0 && homeGoalieGoals != 0){
                let homeGoalieTotal:Double = (Double(homeGoalieShots) / Double(homeGoalieGoals + homeGoalieShots))
                goalieStatsArray[x] = goalieStatsArray[x] + "Overall Save %: \(String(format: "%.2f", homeGoalieTotal))\n"
            }else{
                goalieStatsArray[x] = goalieStatsArray[x] + "Overall Save %: N/A\n"
            }
         // ----------- save % by shot location --------------------
            let topLeft = Double((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "goalieID == %i AND shotLocation == %i AND activeState == true", goalieIDArray[x], 1)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
            let topRight = Double((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "goalieID == %i AND shotLocation == %i AND activeState == true", goalieIDArray[x], 2)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
            let bottomLeft = Double((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "goalieID == %i AND shotLocation == %i AND activeState == true", goalieIDArray[x], 3)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
            let bottomRight = Double((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "goalieID == %i AND shotLocation == %i AND activeState == true", goalieIDArray[x], 4)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
            let center = Double((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "goalieID == %i AND shotLocation == %i AND activeState == true", goalieIDArray[x], 5)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
            
            let totalShot:Double = topLeft + topRight + bottomLeft + bottomRight + center
            
            if (totalShot != 0.0){
            goalieStatsArray[x] = goalieStatsArray[x] + "Top Left Save %: \(String(format: "%.2f",(topLeft/totalShot)))\nTop Right Save %: \(String(format: "%.2f",(topRight/totalShot)))\nBottom Left Save %: \(String(format: "%.2f", (bottomLeft/totalShot)))\nBottom Right Save %: \(String(format: "%.2f",(bottomRight/totalShot)))\nFive Hole Save %: \(String(format: "%.2f",(center/totalShot)))"
            }else{
                 goalieStatsArray[x] = goalieStatsArray[x] + "Top Left Save %: N/A\nTop Right Save %: N/A\nBottom Left Save %: N/A\nBottom Right Save %: N/A\nFive Hole Save %: N/A"
            }
        }
        
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if (tableView == playerSatsTable){
            
            return("Overall Player Stats")
        }else{
            
            return("Overall Goalie Stats")
        }
    }
    // Returns count of items in tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableView == playerSatsTable){
            return((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == true", String(homeTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({String($0)}).count)
        }else {
            return((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType == %@ AND activeState == true", String(homeTeamID), "G")).value(forKeyPath: "playerID") as! [Int]).compactMap({String($0)}).count)
        }
    }
    //Assign values for tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (tableView == playerSatsTable){
            let cell:customOverallStatsCell = self.playerSatsTable.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! customOverallStatsCell
            cell.playerNameLabel!.text = homePlayerNames[indexPath.row]
            cell.playerStatsLabel?.text = self.homePlayerStatsArray[indexPath.row]
            
            return cell
        }else {
           
            let cell:customOverallStatsCell = self.goalieStatsTable.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! customOverallStatsCell
            cell.goalieNameLabel!.text = homeGoalieNames[indexPath.row]
            cell.goalieStatsLabel?.text = self.goalieStatsArray[indexPath.row]
            
            return cell
            
        }
    }

}
