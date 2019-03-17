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
    
    @IBOutlet weak var playerSatsTable: UITableView!
    @IBOutlet weak var goalieStatsTable: UITableView!
    //@IBOutlet weak var lineStatsTable: UITableView!
    
    var homePlayerStatsArray: [String] = [String]()
    var goalieStatsArray:  [String] = [String]()
    var lineStatsArray:  [String] = [String]()
    var homePlayerIDs: [Int] = [Int]()
    var goalieIDArray: [Int] = [Int]()
    var lineIDArray: [Int] = [Int]()
    var homeTeamID :Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Team ID is:", homeTeamID)
        homePlayerIDs = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == true", String(homeTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        goalieIDArray = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType == %@ AND activeState == true", String(homeTeamID), "G")).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        
        playerStatsProcessing()
        goalieStatsProcessing()
        
        playerSatsTable.layer.cornerRadius = 10
        goalieStatsTable.layer.cornerRadius = 10
       
        playerSatsTable.dataSource = self
        playerSatsTable.delegate = self
        goalieStatsTable.dataSource = self
        goalieStatsTable.delegate = self
        

        // Do any additional setup after loading the view.
    }
    func playerStatsProcessing(){
        
        for x in 0..<homePlayerIDs.count{
            //-------------------- goal count -----------------------
            // get number fos goals from player based oin looping player id
            let nextPlayerCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "goalPlayerID == %i AND gameID == %i AND activeState == true", homePlayerIDs[x], homeTeamID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})).count
            // if number of goals is not 0 aka the player scorerd atleast once
            // ass goals to player stats if not set as zero
            
            let homePlayerName = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", homePlayerIDs[x])).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)})
            let homePlayerNum = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", homePlayerIDs[x])).value(forKeyPath: "jerseyNum") as! [Int]).compactMap({String($0)})
            homePlayerStatsArray.append("\(homePlayerName[0])'s #\(homePlayerNum[0]) Stats\nGoals: \(nextPlayerCount)\n")
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
            // get plaayer name and number
            let homePlayerName = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", goalieIDArray[x])).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)})
            let homePlayerNum = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", goalieIDArray[x])).value(forKeyPath: "jerseyNum") as! [Int]).compactMap({String($0)})
            
            //----------- goals against avg -------------------------
             let numberOfHomeGames = ((realm.objects(newGameTable.self).filter(NSPredicate(format: "homeTeamID == %i AND activeState == true", homeTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)})).count
             let numberOfAwayGames = ((realm.objects(newGameTable.self).filter(NSPredicate(format: "opposingTeamID == %i AND activeState == true", homeTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)})).count
             let numberOfGoalsAgainst = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "goalieID == %i AND activeState == true", goalieIDArray[x], homeTeamID)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)})).count
            
            let GAA:Double = Double(numberOfGoalsAgainst) / Double(numberOfHomeGames + numberOfAwayGames)
            goalieStatsArray.append("\(homePlayerName[0])'s #\(homePlayerNum[0]) Stats\nGoals Against Average: \(String(format: "%.2f", GAA))\n")
            
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel!.numberOfLines = 0;
            cell.textLabel?.text = homePlayerStatsArray[indexPath.row]
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel!.numberOfLines = 0;
            //if (tableView == homePlayerStatsTable){
            cell.textLabel?.text = goalieStatsArray[indexPath.row]
            return cell
            
        }
    }

}
