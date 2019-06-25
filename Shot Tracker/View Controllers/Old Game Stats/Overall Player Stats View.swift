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
    
    var homePlayerStatsArray: [[String]] = [[String]]()
    var homePlayerNames: [String] = [String]()
    var homeGoalieNames: [String] = [String]()
    var goalieStatsArray:  [[String]] = [[String]]()
    var lineStatsArray:  [String] = [String]()
    var homePlayerIDs: [Int] = [Int]()
    var goalieIDArray: [Int] = [Int]()
    var lineIDArray: [Int] = [Int]()
    var homeTeamID :Int = UserDefaults.standard.integer(forKey: "overallStatsTeamID")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Team Selected is \(homeTeamID)")
        
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
    
  
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        UserDefaults.standard.removeObject(forKey: "overallStatsTeamID")
        // remove all hireachy VC back to main page
       // presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "Back_To_Home_Overalll", sender: self)
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
        let homeTeamWinCount = (realm.objects(newGameTable.self).filter(NSPredicate(format: "tieGameBool == false AND winingTeamID == %i AND activeState == true AND activeGameStatus == false", homeTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)}).count
        let homeTeamTieCount =  (realm.objects(newGameTable.self).filter(NSPredicate(format: "tieGameBool == true AND homeTeamID == %i AND activeState == true AND activeGameStatus == false", homeTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)}).count
        let homeTeamLooseCount =  (realm.objects(newGameTable.self).filter(NSPredicate(format: "tieGameBool == false AND losingTeamID == %i AND activeState == true AND activeGameStatus == false", homeTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)}).count
        
        teamRecordLabel.text = "\(teamName)'s Record W:\(String(homeTeamWinCount))-L:\(String(homeTeamLooseCount))-T:\(String(homeTeamTieCount))"
    }
    
    func playerStatsProcessing(){
        
        for x in 0..<homePlayerIDs.count{
            // ------------------ player position -----------------------
            let playerPosition = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", homePlayerIDs[x])).value(forKeyPath: "positionType") as! [String]).compactMap({String($0)})
            homePlayerStatsArray.append(["Position: \(playerPosition.first!)"])
            // ------------------ player line -----------------------
            let playerLineNum = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", homePlayerIDs[x])).value(forKeyPath: "lineNum") as! [Int]).compactMap({Int($0)})
            switch playerLineNum[0]{
            case 0:
                homePlayerStatsArray[x].append("Line Number: G")
            case 1:
                homePlayerStatsArray[x].append("Line Number: F1")
            case 2:
                homePlayerStatsArray[x].append("Line Number: F2")
            case 3:
                homePlayerStatsArray[x].append("Line Number: F3")
            case 4:
                homePlayerStatsArray[x].append("Line Number: D1")
            case 5:
                homePlayerStatsArray[x].append("Line Number: D2")
            case 6:
                homePlayerStatsArray[x].append("Line Number: D3")
            default:
                homePlayerStatsArray[x].append("Line Number: N/A")
            }
            
            //-------------------- goal count -----------------------
            // get number fos goals from player based oin looping player id
            let nextPlayerCount = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", homePlayerIDs[x])).value(forKeyPath: "goalCount") as! [Int]).compactMap({Int($0)})).first
            // if number of goals is not 0 aka the player scorerd atleast once
            // ass goals to player stats if not set as zero
            homePlayerStatsArray[x].append("Goals: \(nextPlayerCount!)")
            // ------------------ assits count -----------------------------
            // get number of assist from player based on looping player id
            let nextPlayerAssitCount = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", homePlayerIDs[x])).value(forKeyPath: "assitsCount") as! [Int]).compactMap({Int($0)})).first
            // if number of assits is not 0 aka the player did not get assist atleast once
            //  set assist num to 0
            if (nextPlayerAssitCount != 0){
                homePlayerStatsArray[x].append("Assits: \(String(nextPlayerAssitCount!))")
            }else{
                homePlayerStatsArray[x].append("Assits: 0")
            }
            // ------------------ plus minus count -----------------------------
            // get current looping player's plus minus
            let nextPlayerPlusMinus = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID = %i AND activeState == true", homePlayerIDs[x])).value(forKeyPath: "plusMinus") as! [Int]).compactMap({Int($0)}).first
            print(nextPlayerPlusMinus)
            homePlayerStatsArray[x].append("Overall Plus/Minus: \(String(nextPlayerPlusMinus!))")
            // ------------------ player's line minus count -----------------------------
            // add all plus/minus from all member of the current player ids line for the overall line plus minus
            let nextPlayerLineNum = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID = %i AND activeState == true", homePlayerIDs[x])).value(forKeyPath: "lineNum") as! [Int]).compactMap({Int($0)}).first
            
            let allPlayersOnLine = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "lineNum = %i AND TeamID == %@ AND activeState == true", nextPlayerLineNum!, String(homeTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
            var totalPlusMinus: Int = 0
            for i in 0..<allPlayersOnLine.count{
                
                totalPlusMinus = totalPlusMinus + ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID = %i AND activeState == true", allPlayersOnLine[i])).value(forKeyPath: "plusMinus") as! [Int]).compactMap({Int($0)})).first!
                
            }
            homePlayerStatsArray[x].append("Overall Line Plus/Minus: \(String(totalPlusMinus))")
            
            // -------------------- PIM (Penalty in minutes for season against player -----------------------------
            let penaltyMinutesAgainstMinor = ((realm.objects(penaltyTable.self).filter(NSPredicate(format: "playerID == %i AND penaltyType == %@ AND activeState == true", homePlayerIDs[x], "Minor")).value(forKeyPath: "penaltyID") as! [Int]).compactMap({Int($0)})).count
            let penaltyMinutesAgainstMajor = ((realm.objects(penaltyTable.self).filter(NSPredicate(format: "playerID == %i AND penaltyType == %@ AND activeState == true", homePlayerIDs[x], "Major")).value(forKeyPath: "penaltyID") as! [Int]).compactMap({Int($0)})).count
            
           let totalMinutes = (penaltyMinutesAgainstMinor * UserDefaults.standard.integer(forKey: "minorPenaltyLength")) + (penaltyMinutesAgainstMajor * UserDefaults.standard.integer(forKey: "majorPenaltyLength"))
            homePlayerStatsArray[x].append("PIM: \(String(totalMinutes))")
            
            /* -------------------------- GMG Game Wining Goals for the Season ----------------
            let countOfGames = ((realm.objects(newGameTable.self).filter(NSPredicate(format: "homeTeamID == %i OR opposingTeamID == %i AND activeState == true", homeTeamID, homeTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)})).count
           for y in 0..<countOfGames{
            
             let penaltyMinutesAgainstMinor = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "playerID == %i AND gameID == %i AND activeState == true", homePlayerIDs[x], )).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)})).count
            }
            */
        }
    }
    
    func goalieStatsProcessing(){
        
        for x in 0..<goalieIDArray.count{
            
            //----------- goals against avg -------------------------
             let numberOfHomeGames = ((realm.objects(newGameTable.self).filter(NSPredicate(format: "homeTeamID == %i AND activeState == true", homeTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)})).count
             let numberOfAwayGames = ((realm.objects(newGameTable.self).filter(NSPredicate(format: "opposingTeamID == %i AND activeState == true", homeTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)})).count
             let numberOfGoalsAgainst = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "goalieID == %i AND activeState == true", goalieIDArray[x], homeTeamID)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)})).count
            
            let GAA:Double = Double(numberOfGoalsAgainst) / Double(numberOfHomeGames + numberOfAwayGames)
            goalieStatsArray.append(["Goals Against Average: \(String(format: "%.2f", GAA))"])
            
            //-------------- save % overall ------------------
            let homeGoalieShots = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "goalieID == %i AND activeState == true", goalieIDArray[x])).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count
            let homeGoalieGoals = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "goalieID == %i AND activeState == true", goalieIDArray[x])).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count
            print(homeGoalieShots, homeGoalieGoals)
            if (homeGoalieShots != 0 && homeGoalieGoals != 0){
                let homeGoalieTotal:Double = (Double(homeGoalieShots) / Double(homeGoalieGoals + homeGoalieShots))
                goalieStatsArray[x].append("Overall Save %: \(String(format: "%.2f", homeGoalieTotal))")
            }else{
                goalieStatsArray[x].append("Overall Save %: N/A")
            }
         // ----------- save % by shot location --------------------
            let topLeft = Double((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "goalieID == %i AND shotLocation == %i AND activeState == true", goalieIDArray[x], 1)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
            let topRight = Double((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "goalieID == %i AND shotLocation == %i AND activeState == true", goalieIDArray[x], 2)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
            let bottomLeft = Double((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "goalieID == %i AND shotLocation == %i AND activeState == true", goalieIDArray[x], 3)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
            let bottomRight = Double((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "goalieID == %i AND shotLocation == %i AND activeState == true", goalieIDArray[x], 4)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
            let center = Double((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "goalieID == %i AND shotLocation == %i AND activeState == true", goalieIDArray[x], 5)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
            
            let totalShot:Double = topLeft + topRight + bottomLeft + bottomRight + center
            
            if (totalShot != 0.0){
                goalieStatsArray[x].append("Top Left Save %: \(String(format: "%.2f",(topLeft/totalShot)))")
                goalieStatsArray[x].append("Top Right Save %: \(String(format: "%.2f",(topRight/totalShot)))")
                goalieStatsArray[x].append("Bottom Left Save %: \(String(format: "%.2f", (bottomLeft/totalShot)))")
                goalieStatsArray[x].append("Bottom Right Save %: \(String(format: "%.2f",(bottomRight/totalShot)))")
                goalieStatsArray[x].append("Five Hole Save %: \(String(format: "%.2f",(center/totalShot)))")
            }else{
                goalieStatsArray[x].append("Top Left Save %: N/A")
                goalieStatsArray[x].append("Top Right Save %: N/A")
                goalieStatsArray[x].append("Bottom Left Save %: N/A")
                goalieStatsArray[x].append("Bottom Right Save %: N/A")
                goalieStatsArray[x].append("Five Hole Save %: N/A")
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
        
        var count: Int = 0
        
        if (tableView == playerSatsTable){
            
            let cell:customOverallStatsCell = self.playerSatsTable.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! customOverallStatsCell
            cell.playerNameLabel!.text = homePlayerNames[indexPath.row]
            cell.playerPositionLabel?.text = self.homePlayerStatsArray[indexPath.row][count]; count = count  + 1
            cell.playerLineNumberLabel?.text = self.homePlayerStatsArray[indexPath.row][count]; count = count  + 1
            cell.playerGoalCountLabel?.text = self.homePlayerStatsArray[indexPath.row][count]; count = count  + 1
            cell.playerAssistCountLabel?.text = self.homePlayerStatsArray[indexPath.row][count]; count = count  + 1
            cell.playerPlusMinusLabel?.text = self.homePlayerStatsArray[indexPath.row][count]; count = count  + 1
            if (UserDefaults.standard.bool(forKey: "userPurchaseConf") == true){
            cell.playerLinePlusMinusLabel?.text = self.homePlayerStatsArray[indexPath.row][count]; count = count  + 1
                cell.playerLinePlusMinusImageView.isHidden = true
            }else{
                count = count  + 1
                cell.playerLinePlusMinusImageView.isHidden = false
            }
            if (UserDefaults.standard.bool(forKey: "userPurchaseConf") == true){
            cell.playerPIMLabel?.text = self.homePlayerStatsArray[indexPath.row][count]; //count = count  + 1
            cell.playerPIMIMageView.isHidden = true
            }else{
                cell.playerPIMIMageView.isHidden = false
            }
            return cell
            
        }else {
           
            let cell:customOverallStatsCell = self.goalieStatsTable.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! customOverallStatsCell
            cell.goalieNameLabel!.text = homeGoalieNames[indexPath.row]
            cell.goalieGoalsAGAVGLabel?.text = self.goalieStatsArray[indexPath.row][count]; count = count  + 1
            cell.goalieSavePerLabel?.text = self.goalieStatsArray[indexPath.row][count]; count = count  + 1
            if (UserDefaults.standard.bool(forKey: "userPurchaseConf") == true){
                cell.goalieSavePerTopLeftLabel?.text = self.goalieStatsArray[indexPath.row][count]; count = count  + 1
                cell.goalieSavePerTopRightLabel?.text = self.goalieStatsArray[indexPath.row][count]; count = count  + 1
                cell.goalieSavePerBottomLeftLabel?.text = self.goalieStatsArray[indexPath.row][count]; count = count  + 1
                cell.goalieSavePerBottomRightLabel?.text = self.goalieStatsArray[indexPath.row][count]; count = count  + 1
                cell.goalieSavePerCenterLabel?.text = self.goalieStatsArray[indexPath.row][count]; //count = count  + 1
                cell.goalieLocationSavePerImageView.isHidden = true
            }
            return cell
            
        }
    }
    
    

}
