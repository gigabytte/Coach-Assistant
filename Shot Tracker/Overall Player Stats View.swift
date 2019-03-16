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
    @IBOutlet weak var forwardLineStatsTable: UITableView!
    @IBOutlet weak var defenseLineStatsTable: UITableView!
    
    var homePlayerStatsArray: [String] = [String]()
    var forwardLineStatsArray:  [String] = [String]()
    var defenseLineStatsArray:  [String] = [String]()
    var homePlayerIDs: [Int] = [Int]()
    var forwardLinePlayerIDs: [Int] = [Int]()
    var defenseLinePlayerIDs: [Int] = [Int]()
    var homeTeamID :Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homePlayerIDs = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == true", String(homeTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        forwardLinePlayerIDs = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND lineNum >= %i AND activeState == true", String(homeTeamID), 4)).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        defenseLinePlayerIDs = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@  AND lineNum <= %i AND activeState == true", String(homeTeamID), 3)).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        playerStatsProcessing()
        
        playerSatsTable.layer.cornerRadius = 10
        forwardLineStatsTable.layer.cornerRadius = 10
        defenseLineStatsTable.layer.cornerRadius = 10
       
        playerSatsTable.dataSource = self
        playerSatsTable.delegate = self
        forwardLineStatsTable.dataSource = self
        forwardLineStatsTable.delegate = self
        defenseLineStatsTable.dataSource = self
        defenseLineStatsTable.delegate = self
        

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
    
    func forwardLinePorcessing(){
        
        
        
    }

    // Returns count of items in tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableView == playerSatsTable){
            return((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == true", String(homeTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({String($0)}).count)
        }else if (tableView == forwardLineStatsTable){
            return((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND lineNum <= %i AND activeState == true", String(homeTeamID), 3)).value(forKeyPath: "lineNum") as! [Int]).compactMap({String($0)}).count)
        }else{
            
            return((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND lineNum >= %i AND activeState == true", String(homeTeamID), 4)).value(forKeyPath: "lineNum") as! [Int]).compactMap({String($0)}).count)
        }
    }
    //Assign values for tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (tableView == playerSatsTable){
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel!.numberOfLines = 0;
            cell.textLabel?.text = homePlayerStatsArray[indexPath.row]
            return cell
        }else if (tableView == forwardLineStatsTable){
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel!.numberOfLines = 0;
            //if (tableView == homePlayerStatsTable){
            cell.textLabel?.text = forwardLineStatsArray[indexPath.row]
            return cell
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel!.numberOfLines = 0;
            cell.textLabel?.text = defenseLineStatsArray[indexPath.row]
            return cell
            
        }
    }

}
