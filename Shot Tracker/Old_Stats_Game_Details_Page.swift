//
//  Old_Stats_Game_Details_Page.swift
//  Shot Tracker
//
//  Created by Ahad Ahmed on 2019-02-22.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class Old_Stats_Game_Details_Page: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var SeletedGame: Int!
    var homeTeam: Int!
    var awayTeam: Int!
    var homePlayerIDs: [Int] = [Int]()
    var awayPlayerIDs: [Int] = [Int]()
    var homePlayerStatsArray: [String] = [String]()
    var awayPlayerStatsArray: [String] = [String]()
    
    @IBOutlet weak var homeTeamNameTextField: UILabel!
    @IBOutlet weak var awayTeamNameTextField: UILabel!
    @IBOutlet weak var homeTeamScoreTextField: UILabel!
    @IBOutlet weak var awayTeamScoreTextField: UILabel!
    @IBOutlet weak var homeNumShotTextField: UILabel!
    @IBOutlet weak var awayNumShotTextField: UILabel!
    @IBOutlet weak var homePlayerStatsTable: UITableView!
    @IBOutlet weak var awayPlayerStatsTable: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var homeTeamRecordLabel: UILabel!
    @IBOutlet weak var awayTeamRecordLabel: UILabel!
    
    let textCellIdentifier = "cell"
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Selected team", SeletedGame)
        
        homeTeam = realm.object(ofType: teamInfoTable.self, forPrimaryKey: realm.object(ofType: newGameTable.self, forPrimaryKey: SeletedGame)?.homeTeamID)?.teamID
        awayTeam = realm.object(ofType: teamInfoTable.self, forPrimaryKey: realm.object(ofType: newGameTable.self, forPrimaryKey: SeletedGame)?.opposingTeamID)?.teamID
        
        recordLabelProcessing()
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
        navBarProcessing()
        
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
        print(homePlayerStatsArray)
        print(awayPlayerStatsArray)
       
    }
    // func gets count for number of wins, losses and ties and displays them
    // appropriate label
    func recordLabelProcessing(){
    
        let homeTeamWinCount = (realm.objects(newGameTable.self).filter(NSPredicate(format: "tieGameBool == false AND winingTeamID == %i AND activeState == true", homeTeam)).value(forKeyPath: "gameID") as! [Int]).compactMap({String($0)}).count
        
        let homeTeamTieCount = (realm.objects(newGameTable.self).filter(NSPredicate(format: "tieGameBool == true AND homeTeamID == %i AND activeState == true", homeTeam)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)}).count
        
        let awayTeamHomeTieCount = (realm.objects(newGameTable.self).filter(NSPredicate(format: "tieGameBool == true AND opposingTeamID == %i AND activeState == true", homeTeam)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)}).count
  
        let homeTeamLooseCount =  (realm.objects(newGameTable.self).filter(NSPredicate(format: "tieGameBool == false AND losingTeamID == %i AND activeState == true", homeTeam)).value(forKeyPath: "gameID") as! [Int]).compactMap({String($0)}).count
        
        
        let awayTeamWinCount = (realm.objects(newGameTable.self).filter(NSPredicate(format: "tieGameBool == false AND winingTeamID == %i AND activeState == true", awayTeam)).value(forKeyPath: "gameID") as! [Int]).compactMap({String($0)}).count
      
        let awayTeamTieCount = (realm.objects(newGameTable.self).filter(NSPredicate(format: "tieGameBool == true AND opposingTeamID == %i AND activeState == true" ,awayTeam)).value(forKeyPath: "gameID") as! [Int]).compactMap({String($0)}).count
        
        let homeTeamAwayTieCount = (realm.objects(newGameTable.self).filter(NSPredicate(format: "tieGameBool == true AND homeTeamID == %i AND activeState == true", awayTeam)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)}).count

        let awayTeamLooseCount =  (realm.objects(newGameTable.self).filter(NSPredicate(format: "tieGameBool == false AND losingTeamID == %i AND activeState == true", awayTeam)).value(forKeyPath: "gameID") as! [Int]).compactMap({String($0)}).count
        
        homeTeamRecordLabel.text = "W:\(homeTeamWinCount)-L:\(homeTeamLooseCount)-T:\(String(homeTeamTieCount + awayTeamHomeTieCount))"
        awayTeamRecordLabel.text = "W:\(awayTeamWinCount)-L:\(awayTeamLooseCount)-T:\(String(awayTeamTieCount + homeTeamAwayTieCount))"
    }
    
     func teamNameInitialize(){
     
         // query realm for team naames based on newest game
         let homeTeamNameString = realm.object(ofType: teamInfoTable.self, forPrimaryKey: realm.object(ofType: newGameTable.self, forPrimaryKey: SeletedGame)?.homeTeamID)!
         let awayTeamNameString = realm.object(ofType: teamInfoTable.self, forPrimaryKey: realm.object(ofType: newGameTable.self, forPrimaryKey: SeletedGame)?.opposingTeamID)!
         // align text in text field as well assign text value to text field to team name
         homeTeamNameTextField.text = homeTeamNameString.nameOfTeam
         homeTeamNameTextField.textAlignment = .center
         awayTeamNameTextField.text = awayTeamNameString.nameOfTeam
         awayTeamNameTextField.textAlignment = .center
     }
    
     func scoreInitialize() -> (Double, Double){
     
     // query realm for goal count based on newest gam
         let gameID = realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)
         let homeScoreFilter = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND activeState == true", SeletedGame, homeTeam!)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        
         let awayScoreFilter = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND activeState == true", SeletedGame, awayTeam!)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        
         // align text to center and assigned text field the value of homeScoreFilter query
         homeTeamScoreTextField.text = String(homeScoreFilter)
         homeTeamScoreTextField.textAlignment = .center
         awayTeamScoreTextField.text = String(awayScoreFilter)
         awayTeamScoreTextField.textAlignment = .center
        
         return(Double(homeScoreFilter), Double(awayScoreFilter))
         }
    
         func numShotInitialize() -> (Double, Double){
         
         let newGameFilter = realm.object(ofType: newGameTable.self, forPrimaryKey: SeletedGame);
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
    
    func navBarProcessing() {
        if (homeTeam != nil && awayTeam != nil){
            let home_teamNameFilter = realm.object(ofType: teamInfoTable.self, forPrimaryKey: homeTeam)?.nameOfTeam
            let away_teamNameFilter = realm.object(ofType: teamInfoTable.self, forPrimaryKey: awayTeam)?.nameOfTeam
            // get new gametable objects with filktered by gameID where >=0
            let newGameTableData = realm.objects(newGameTable.self).filter(NSPredicate(format: "gameID == %i AND activeGameStatus == false AND activeState == true", SeletedGame)).value(forKeyPath: "dateGamePlayed") as! [Date]
            
            // convert dates array type to string type
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy HH:mm"
            let dateString = formatter.string(from: newGameTableData[0])
            navBar.topItem!.title = "\(home_teamNameFilter!) vs \(away_teamNameFilter!) on \(dateString)"
        }else{
            print("Error Unable to Gather Team Name, Nav Bar Has Defaulted")
            
        }
    }
    
     func home_playerStatsProcessing(){
     
         let newGameFilter = realm.object(ofType: newGameTable.self, forPrimaryKey: SeletedGame);
        
         homePlayerIDs = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == true", String(newGameFilter!.homeTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        
         for x in 0..<homePlayerIDs.count{
         //-------------------- goal count -----------------------
         // get number fos goals from player based oin looping player id
         let nextPlayerCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "goalPlayerID == %i AND gameID == %i AND activeState == true", homePlayerIDs[x], newGameFilter!.gameID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({Int($0)})).count
         // if number of goals is not 0 aka the player scorerd atleast once
         // ass goals to player stats if not set as zero
         
         let homePlayerName = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", homePlayerIDs[x])).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)})
         let homePlayerNum = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", homePlayerIDs[x])).value(forKeyPath: "jerseyNum") as! [Int]).compactMap({String($0)})
         homePlayerStatsArray.append("\(homePlayerName[0])'s #\(homePlayerNum[0]) Stats\nGoals: \(nextPlayerCount)\n")
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
         print("home player passed")
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
         awayPlayerStatsArray.append("\(homePlayerName[0])'s #\(homePlayerNum[0]) Stats\nGoals: \(nextPlayerCount)\n")
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
        print("away player passed")
     
     }
    
     // Returns count of items in tableView
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
         let newGameFilter = realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?);
             if (tableView == homePlayerStatsTable){
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check is appropriate segue is being used
        if (segue.identifier == "iceSurfaceSegue"){
            // set var vc as destination segue
            let vc = segue.destination as! Old_Game_Ice_View
            vc.SeletedGame = SeletedGame
        }
    }

}
