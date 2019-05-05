//
//  Detailed_Current_Stats_View_Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-30.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class Detailed_Current_Stats_View_Controller: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var homePlayerStatsTableView: UITableView!
    @IBOutlet weak var awayPlayerStatsTableView: UITableView!
    @IBOutlet weak var goalieStatsTableView: UITableView!
    @IBOutlet weak var teamStatsTableView: UITableView!
    
    
    // vars used on segue passing
    var homeTeam: Int = UserDefaults.standard.integer(forKey: "homeTeam")
    var awayTeam: Int = UserDefaults.standard.integer(forKey: "awayTeam")
    
    var teamIDArray: [String] = [String]()
    var homePlayerStatsArray: [String] = [String]()
    var homePlayerNames: [String] = [String]()
    var homePlayerIDs: [Int] = [Int]()
    var awayPlayerStatsArray: [String] = [String]()
    var awayPlayerNames: [String] = [String]()
    var awayPlayerIDs: [Int] = [Int]()
    var goalieStatsArray: [String] = [String]()
    var homeGoalieNames: [String] = [String]()
    var goalieIDArray: [Int] = [Int]()
    var teamStatsType: [String] = [String]()
    var teamStatsVar: [String] = [String]()
    var gameID: Int = UserDefaults.standard.integer(forKey: "gameID")
    
    var homeTeamName: String!
    var awayTeamName: String!
    
    
    let realm = try! Realm()
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // rounding of corners for tableview
        goalieStatsTableView.layer.cornerRadius = 10
        goalieStatsTableView.layer.cornerRadius = 10
        
        teamStatsTableView.layer.cornerRadius = 10
        teamStatsTableView.layer.cornerRadius = 10
        
        customTableViewRoundedCorners(tableViewName: homePlayerStatsTableView)
        customTableViewRoundedCorners(tableViewName: awayPlayerStatsTableView)
        
        // disable section for tableview to used as a excel like table only
        homePlayerStatsTableView.allowsSelection = false
        awayPlayerStatsTableView.allowsSelection = false
        goalieStatsTableView.allowsSelection = false
        teamStatsTableView.allowsSelection = false
        
        // connect table to data source
        homePlayerStatsTableView.dataSource = self
        homePlayerStatsTableView.delegate = self
        
        awayPlayerStatsTableView.dataSource = self
        awayPlayerStatsTableView.delegate = self
        
        goalieStatsTableView.dataSource = self
        goalieStatsTableView.delegate = self
        
        teamStatsTableView.dataSource = self
        teamStatsTableView.delegate = self
        
        // data callection /processing for tableview
        teamStatsType = ["GF", "SF", "GA", "SA", "SOG", "PPG", "PIM"]
        home_playerStatsProcessing()
        away_playerStatsProcessing()
        goalieStatsProcessing()
        home_teamStatsProcessing()
        playerNameFetch()
        goalieNameFetch()
        
        // get name of teams currently playing
        homeTeamName = ((realm.objects(teamInfoTable.self).filter(NSPredicate(format: "teamID == %i AND activeState == true", homeTeam)).value(forKeyPath: "nameOfTeam") as! [String]).compactMap({String($0)})).first
        awayTeamName = ((realm.objects(teamInfoTable.self).filter(NSPredicate(format: "teamID == %i AND activeState == true", awayTeam)).value(forKeyPath: "nameOfTeam") as! [String]).compactMap({String($0)})).first
        // Do any additional setup after loading the view.
        
        // set table view cell to be dynamic in terms of height
        self.homePlayerStatsTableView.estimatedRowHeight = 75.0
        self.homePlayerStatsTableView.rowHeight = UITableView.automaticDimension
        
        self.awayPlayerStatsTableView.estimatedRowHeight = 75.0
        self.awayPlayerStatsTableView.rowHeight = UITableView.automaticDimension
        
        self.goalieStatsTableView.estimatedRowHeight = 75.0
        self.goalieStatsTableView.rowHeight = UITableView.automaticDimension
       
        self.teamStatsTableView.rowHeight = 50.0
    }
    
    func customTableViewRoundedCorners(tableViewName: UITableView){
        if(tableViewName == homePlayerStatsTableView){
            // round bottom corners of button
            let path = UIBezierPath(roundedRect:tableViewName.bounds, byRoundingCorners:[.topLeft], cornerRadii: CGSize(width: 10, height: 10))
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            tableViewName.layer.mask = maskLayer
        }else{
            let path = UIBezierPath(roundedRect:tableViewName.bounds, byRoundingCorners:[.topRight], cornerRadii: CGSize(width: 10, height: 10))
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            tableViewName.layer.mask = maskLayer
            
        }
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
            homePlayerNames.append("No Players Found")
            
        }
        
        if (awayPlayerIDs.isEmpty != true){
            for x in 0..<awayPlayerIDs.count{
                
                let queryPlayerName = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", awayPlayerIDs[x])).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)})).first
                let queryPlayerNumber = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", awayPlayerIDs[x])).value(forKeyPath: "jerseyNum") as! [Int]).compactMap({Int($0)})).first
                
                let playerFormatter = "\(queryPlayerName!) #\(queryPlayerNumber!)"
                awayPlayerNames.append(playerFormatter)
            }
        }else{
            awayPlayerNames.append("No Players Found")
            
        }
        print(awayPlayerNames)
    }
    
    func goalieNameFetch(){
        if (goalieIDArray.isEmpty != true){
            for x in 0..<goalieIDArray.count{
                
                let queryGoalieName = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND positionType == %@ AND activeState == true", goalieIDArray[x], "G")).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)})).first
                let queryGoalieNumber = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND positionType == %@ AND activeState == true", goalieIDArray[x], "G")).value(forKeyPath: "jerseyNum") as! [Int]).compactMap({Int($0)})).first
               
                let goalieFormatter = "\(queryGoalieName!) #\(queryGoalieNumber!)"
                homeGoalieNames.append(goalieFormatter)
                print(homeGoalieNames)
            }
        }else{
            homeGoalieNames.append("No Goalies Found")
        }
    }
    
    func home_playerStatsProcessing(){
        
        homePlayerIDs = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == true", String(homeTeam))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        
        for x in 0..<homePlayerIDs.count{
            //-------------------- goal count -----------------------
            // get number fos goals from player based oin looping player id
            let nextPlayerCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "goalPlayerID == %i AND gameID == %i AND activeState == true", homePlayerIDs[x], gameID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})).count
            // if number of goals is not 0 aka the player scorerd atleast once
            // ass goals to player stats if not set as zero
            homePlayerStatsArray.append("Goals: \(nextPlayerCount)\n")
            // ------------------ assits count -----------------------------
            // get number of assist from player based on looping player id
            let nextPlayerAssitCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "assitantPlayerID == %i AND gameID == %i AND activeState == true", homePlayerIDs[x], gameID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})).count
            let sec_nextPlayerAssitCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "assitantPlayerID == %i AND gameID == %i AND activeState == true", homePlayerIDs[x], gameID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})).count
            // if number of assits is not 0 aka the player did not get assist atleast once
            //  set assist num to 0
            if (nextPlayerAssitCount != 0 || sec_nextPlayerAssitCount != 0){
                homePlayerStatsArray[x] = homePlayerStatsArray[x] + "Assits: \(String(nextPlayerAssitCount + sec_nextPlayerAssitCount)) \n"
            }else{
                homePlayerStatsArray[x] = homePlayerStatsArray[x] + "Assits: 0 \n"
            }
            // ------------------ plus minus count -----------------------------
            // get current looping player's plus minus
            let goalCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "TeamID == %i AND assitantPlayerID == %i AND gameID == %i AND activeState == true", homeTeam, homePlayerIDs[x], gameID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})).count
            let assitsCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "TeamID == %i AND assitantPlayerID == %i AND gameID == %i AND activeState == true",homeTeam, homePlayerIDs[x], gameID)).value(forKeyPath: "assitantPlayerID") as! [Int]).compactMap({Int($0)})).count
            let sec_assitsCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "TeamID == %i AND assitantPlayerID == %i AND gameID == %i AND activeState == true",homeTeam, homePlayerIDs[x], gameID)).value(forKeyPath: "sec_assitantPlayerID") as! [Int]).compactMap({Int($0)})).count
            let plusTotal = goalCount + assitsCount + sec_assitsCount
            let playerLine = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", homePlayerIDs[x])).value(forKeyPath: "lineNum") as! [Int]).compactMap({Int($0)}))[0]
            var plusMinusTotal:Int = 0
            if (playerLine <= 3){
                let againstGoalCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "TeamID == %i AND againstFLine == %i AND gameID == %i AND activeState == true", awayTeam, playerLine, gameID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})).count
                plusMinusTotal = plusTotal - againstGoalCount
            }else{
                let againstGoalCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "TeamID == %i AND againstDLine == %i AND gameID == %i AND activeState == true", awayTeam, playerLine, gameID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})).count
                plusMinusTotal = plusTotal - againstGoalCount
                
            }
            
            homePlayerStatsArray[x] = homePlayerStatsArray[x] + "In Game Plus/Minus: \(String(plusMinusTotal))"
            
        }
    }
    
    func away_playerStatsProcessing(){
    
        // get array of away players primary IDs
        awayPlayerIDs = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == true", String(awayTeam))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        
        for x in 0..<awayPlayerIDs.count{
            //-------------------- goal count -----------------------
            // get number fos goals from player based oin looping player id
            let nextPlayerCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "goalPlayerID == %i AND gameID == %i AND activeState == true", awayPlayerIDs[x], gameID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})).count
            // if number of goals is not 0 aka the player scorerd atleast once
            // as goals to player stats if not set as zero
            
            awayPlayerStatsArray.append("Goals: \(nextPlayerCount)\n")
            // ------------------ assits count -----------------------------
            // get number of assist from player based on looping player id
            let nextPlayerAssitCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "assitantPlayerID == %i AND gameID == %i AND activeState == true", awayPlayerIDs[x], gameID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})).count
            let sec_nextPlayerAssitCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "assitantPlayerID == %i AND gameID == %i AND activeState == true", awayPlayerIDs[x], gameID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})).count
            // if number of assits is not 0 aka the player did not get assist atleast once
            //  set assist num to 0
            if (nextPlayerAssitCount != 0 || sec_nextPlayerAssitCount != 0){
                awayPlayerStatsArray[x] = awayPlayerStatsArray[x] + "Assits: \(String(nextPlayerAssitCount + sec_nextPlayerAssitCount)) \n"
            }else{
                awayPlayerStatsArray[x] = awayPlayerStatsArray[x] + "Assits: 0 \n"
            }
            // ------------------ plus minus count -----------------------------
            // get current looping player's plus minus
            let goalCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "TeamID == %i AND assitantPlayerID == %i AND gameID == %i AND activeState == true", awayTeam, awayPlayerIDs[x], gameID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})).count
            let assitsCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "TeamID == %i AND assitantPlayerID == %i AND gameID == %i AND activeState == true",awayTeam, awayPlayerIDs[x], gameID)).value(forKeyPath: "assitantPlayerID") as! [Int]).compactMap({Int($0)})).count
            let sec_assitsCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "TeamID == %i AND assitantPlayerID == %i AND gameID == %i AND activeState == true",awayTeam, awayPlayerIDs[x], gameID)).value(forKeyPath: "sec_assitantPlayerID") as! [Int]).compactMap({Int($0)})).count
            let plusTotal = goalCount + assitsCount + sec_assitsCount
            let playerLine = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", awayPlayerIDs[x])).value(forKeyPath: "lineNum") as! [Int]).compactMap({Int($0)}))[0]
            var plusMinusTotal:Int = 0
            if (playerLine <= 3){
                let againstGoalCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "TeamID == %i AND againstFLine == %i AND gameID == %i AND activeState == true", homeTeam, playerLine, gameID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})).count
                plusMinusTotal = plusTotal - againstGoalCount
            }else{
                let againstGoalCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "TeamID == %i AND againstDLine == %i AND gameID == %i AND activeState == true", homeTeam, playerLine, gameID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})).count
                plusMinusTotal = plusTotal - againstGoalCount
                
            }
            
            awayPlayerStatsArray[x] = awayPlayerStatsArray[x] + "In Game Plus/Minus: \(String(plusMinusTotal))"
        }
        
    }
    
    func goalieStatsProcessing(){
        
        goalieIDArray = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType == %@ AND activeState == true", String(homeTeam), "G")).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        
        for x in 0..<goalieIDArray.count{
            print("Goalie ID", goalieIDArray[x])
            //----------- goals against avg -------------------------
            let numberOfHomeGames = ((realm.objects(newGameTable.self).filter(NSPredicate(format: "homeTeamID == %i AND activeState == true", homeTeam)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)})).count
            let numberOfAwayGames = ((realm.objects(newGameTable.self).filter(NSPredicate(format: "opposingTeamID == %i AND activeState == true", homeTeam)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)})).count
            let numberOfGoalsAgainst = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "goalieID == %i AND activeState == true", goalieIDArray[x], homeTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)})).count
            
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
    
    func home_teamStatsProcessing(){
        
        // --------------------- GF (Goals FOr home team) -----------------------------------
        let goalsFor = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND activeState == true", (gameID), homeTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)})).count
        teamStatsVar.append(String(goalsFor))
      
        // -------------------- SF (Shots for home team) ------------------------------------
        let shotsFor =  ((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND activeState == true", (gameID), homeTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)})).count
        teamStatsVar.append(String(shotsFor))
        // --------------------  GA (Goals against for home team) -------------------------------
        let goalsAgainst = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND activeState == true", (gameID), awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)})).count
        teamStatsVar.append(String(goalsAgainst))
        // --------------------  SA (Shots against for home team) -------------------------------
        let shotsAgainst = ((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND activeState == true", (gameID), awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)})).count
        teamStatsVar.append(String(shotsAgainst))
        // -------------------- SOG (Shots on goal for home team) -------------------------------------
        let shotsOnGoal = ((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND activeState == true", (gameID), awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)})).count
        teamStatsVar.append(String(shotsOnGoal))
        // ------------------- PPG (Power Power Play Goals for home team) ------------------------
        let powerPlayGoals = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND powerPlay == true AND activeState == true", (gameID), homeTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)})).count
        teamStatsVar.append(String(powerPlayGoals))
        // -------------------- PIM (Penalty in minutes against home team)
        let penaltyMinutesAgainstMinor = ((realm.objects(penaltyTable.self).filter(NSPredicate(format: "gameID == %i AND teamID == %i AND penaltyType == %@ AND activeState == true", (gameID), homeTeam, "Minor")).value(forKeyPath: "penaltyID") as! [Int]).compactMap({Int($0)})).count
        let penaltyMinutesAgainstMajor = ((realm.objects(penaltyTable.self).filter(NSPredicate(format: "gameID == %i AND teamID == %i AND penaltyType == %@ AND activeState == true", (gameID), homeTeam, "Major")).value(forKeyPath: "penaltyID") as! [Int]).compactMap({Int($0)})).count
       
        let totalMinutes = (penaltyMinutesAgainstMinor * 2) + (penaltyMinutesAgainstMajor * 2)
        teamStatsVar.append(String(totalMinutes))
        
        print("Team Stats Vars:", teamStatsVar)
    }
    
    // Returns count of items in tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableView == homePlayerStatsTableView){
            
            return(homePlayerIDs.count)
        }else if (tableView == awayPlayerStatsTableView){
            
            return(awayPlayerIDs.count)
        }else if (tableView == goalieStatsTableView){
            
            return(goalieIDArray.count)
        }else{
            return(teamStatsType.count)
        }
    }
    //Assign values for tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            if (tableView == homePlayerStatsTableView){
                
                let cell:customCurrentStatsCell = self.homePlayerStatsTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! customCurrentStatsCell
                cell.detailedHomePlayerNameLabel!.text = homePlayerNames[indexPath.row]
                cell.detailedHomePlayerStatsLabel?.text = self.homePlayerStatsArray[indexPath.row]
                
                return cell
            }else if (tableView == awayPlayerStatsTableView){
                
                let cell:customCurrentStatsCell = self.awayPlayerStatsTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! customCurrentStatsCell
                cell.detailedAwayPlayerNameLabel!.text = awayPlayerNames[indexPath.row]
                cell.detailedAwayPlayerStatsLabel?.text = self.awayPlayerStatsArray[indexPath.row]
                
                return cell
            }else if (tableView == goalieStatsTableView){
                
                let cell:customCurrentStatsCell = self.goalieStatsTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! customCurrentStatsCell
                cell.detailedHomeGoalieNameLabel!.text = homeGoalieNames[indexPath.row]
                cell.detailedHomeGoalieStatsLabel?.text = self.goalieStatsArray[indexPath.row]
                
                return cell
            }else{
                let cell:customCurrentStatsCell = self.teamStatsTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! customCurrentStatsCell
                cell.teamStatNameLabel!.text = teamStatsType[indexPath.row]
                cell.teamStatValueLabel?.text = self.teamStatsVar[indexPath.row]
                
                return cell
            }
        }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if (tableView == homePlayerStatsTableView){
            
            return("Player Stats for \(homeTeamName!)")
        }else if (tableView == awayPlayerStatsTableView){
            
             return("Player Stats for \(awayTeamName!)")
        }else if (tableView == goalieStatsTableView){
            
            return("Goalie Stats for \(homeTeamName!)")
        }else{
            return("Current Game Stats for \(homeTeamName!)")
        }
    }
    
    
}
