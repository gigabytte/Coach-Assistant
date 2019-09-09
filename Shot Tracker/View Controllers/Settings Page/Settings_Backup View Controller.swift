//
//  Settings_Backup View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-19.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import SwiftyStoreKit
import MobileCoreServices
import Zip

final class Settings_Backup_View_Controller: UITableViewController, UIPopoverPresentationControllerDelegate{
    
    @IBOutlet weak var backToiClkoudLabel: UILabel!
    @IBOutlet var backupTableView: UITableView!
    @IBOutlet weak var icloudToggleSwitch: UISwitch!
    @IBOutlet weak var backupDateLabel: UILabel!
    @IBOutlet weak var backupLabel: UILabel!
    @IBOutlet weak var importLabel: UILabel!
    
    var successImport: Bool!
    var productID: String!
    var runOnceBool: Bool = false
    var importPlayersBool: Int!
    
    var csvText_newGameTable: String!
    var csvText_faceoffTable: String!
    var csvText_goalMarkerTable: String!
    var csvText_overallStatsTable: String!
    var csvText_penaltyInfoTable: String!
    var csvText_playerInfoTable: String!
    var csvText_shotMarkerTable: String!
    var csvText_teamInfoTable: String!
    
    
    var pathURLs: [URL] = [URL]()
    
    var playerNamesFromCSV: [String] = [String]()
    var playerJerseyNumFromCSV: [Int] = [Int]()
    var playerLineNumFromCSV: [Int] = [Int]()
    var playerLineTypeFromCSV: [String] = [String]()
    
    var teamNameFromCSV: [String] = [String]()
    var teamSeasonYearFromCSV: [Int] = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(myMethod(notification:)), name: NSNotification.Name(rawValue: "backupSettingsPageRefresh"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(myColorMethod(notification:)), name: NSNotification.Name(rawValue: "darModeToggle"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(myResetMethod(notification:)), name: NSNotification.Name(rawValue: "deleteOldValues"), object: nil)
        
        productID = universalValue().coachAssistantProID
        // check is icloud conatiner exsiss on user icloud account

        backupUpDateCheck()
    
        
        // check icloud exprt criteria
        reloadView()
        print("Back Up View Controller Called")
        viewColour()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (UserDefaults.standard.bool(forKey: "userPurchaseConf") != true && runOnceBool == false){
            upgradeNowAlert()
            runOnceBool = true
        }
        reloadView()
        print("Back Up View Controller Appeared")
    }
    
    func viewColour(){
        
        self.tableView.backgroundColor = systemColour().tableViewColor()
    }
    
    @objc func myColorMethod(notification: NSNotification){
        viewColour()
    }
    
    @objc func myResetMethod(notification: NSNotification){
        playerLineNumFromCSV.removeAll()
        playerLineTypeFromCSV.removeAll()
        playerNamesFromCSV.removeAll()
        playerJerseyNumFromCSV.removeAll()
    }
    
    func reloadView(){
        
        icloudToggleSwitch.isOn = UserDefaults.standard.bool(forKey: "iCloudBackupToggle")
        
        if (UserDefaults.standard.bool(forKey: "userPurchaseConf") == true){
            if (icloudAccountCheck().isICloudContainerAvailable() == true){
                if (icloudToggleSwitch.isOn == true){
                    
                    print("User can export to iCloud")
                    backupLabel.text = "iCloud Backup"
                    importLabel.text = "Import Game Saves from iCloud"
                    
                    
                }else{
                    print("User cannot export to iCLoud!")
                    
                    backupLabel.text = "Backup Locally"
                    importLabel.text = "Import Backup Game Saves Locally"
                    
                }
            }else{
                print("USer not logged in icloud")
                missingIcloudCredsAlert()
            }
        }else{
            print("User is not PRO yet cannot use iCloud")
            icloudToggleSwitch.isUserInteractionEnabled = false
            icloudToggleSwitch.alpha = 0.5
            backToiClkoudLabel.alpha = 0.5
          
        }
    }
    
    @objc func myMethod(notification: NSNotification){
     
        delayClass().delay(0.5){
            self.importAlert(message: localizedString().localized(value: "Your data was Successfully Imported!"))
        }
    }
    
    
    
    @IBAction func icouldToggleSwitch(_ sender: Any) {
        
        if (icloudToggleSwitch.isOn == true && icloudAccountCheck().isICloudContainerAvailable() == true){
            
            
            backupLabel.text = "iCloud Backup"
            importLabel.text = "Import iCloud Backup"
        
            UserDefaults.standard.set(true, forKey: "iCloudBackupToggle")
        }else {
            icloudToggleSwitch.isOn = false
            missingIcloudCredsAlert()
            backupLabel.text = "Backup Locally"
            importLabel.text = "Import Backup Locally"
            
            
            UserDefaults.standard.set(false, forKey: "iCloudBackupToggle")
        }
    }
    
    
    
    func backupUpDateCheck(){
        
        if(UserDefaults.standard.object(forKey: "lastBackup") != nil){
            backupDateLabel.text = "Last Known Backup: \(UserDefaults.standard.object(forKey: "lastBackup") as! String)"
        }else{
            backupDateLabel.text = "Backup has not been Performed!"
        }
        
    }
  
    // creats csv file for  team info table
    func createCSVTeamInfo(){
        
        let realm = try! Realm()
        
        let TeamIDCount =  realm.objects(teamInfoTable.self).filter("teamID >= 0").count
        var tempTeamNameArray: [String] = [String]()
        var tempSeasonYearArray: [String] = [String]()
        var tempTeamLogoURLArray: [String] = [String]()
        var tempActiveStateArray: [String] = [String]()
        // print(TeamIDCount)
        for i in 0..<TeamIDCount{
            
            let teamNameValue = realm.object(ofType: teamInfoTable.self, forPrimaryKey:i)!.nameOfTeam;
            let seasonYearValue = realm.object(ofType: teamInfoTable.self, forPrimaryKey:i)!.seasonYear;
            let teamLogoURL = realm.object(ofType: teamInfoTable.self, forPrimaryKey:i)!.teamLogoURL;
            let activeStateValue = realm.object(ofType: teamInfoTable.self, forPrimaryKey:i)!.activeState;
            tempTeamNameArray.append(teamNameValue)
            tempSeasonYearArray.append(String(seasonYearValue))
            tempTeamLogoURLArray.append(String(teamLogoURL))
            tempActiveStateArray.append(String(activeStateValue))
        }
        
        csvText_teamInfoTable = "nameOfTeam,seasonYear,teamLogoURL,activeState\n"
        for x in 0..<tempTeamNameArray.count {
            
            let teamNameVar = tempTeamNameArray[x]
            let seaonYearVar = tempSeasonYearArray[x]
            let teamLogoURLVar = tempTeamLogoURLArray[x]
            let activeStateVar = tempActiveStateArray[x]
            
            let newLine = teamNameVar + "," + seaonYearVar + "," + teamLogoURLVar + "," + activeStateVar + "\n"
            csvText_teamInfoTable.append(newLine)
        }
        /*if (icloudToggleSwitch.isOn == true){
            localDocumentWriter(fileName: teamInfoTableFileName, csvText: csvText_teamInfoTable)
            iCloudDocumentWriter(fileName: teamInfoTableFileName)
        }else{
            localDocumentWriter(fileName: teamInfoTableFileName, csvText: csvText_teamInfoTable)
        }*/
        
       
    }
    // creats csv file for player info table
    func createCSVPlayerInfo(){
        
         let realm = try! Realm()
        
        let playerIDCount =  realm.objects(playerInfoTable.self).filter("playerID >= 0").count
        var tempPlayerNameArray: [String] = [String]()
        var tempjerseyNum: [String] = [String]()
        var tempPositionType: [String] = [String]()
        var tempTeamID: [String] = [String]()
        var tempLineNum: [String] = [String]()
        var tempGoalCount: [String] = [String]()
        var tempAssitsCount: [String] = [String]()
        var tempShotCount: [String] = [String]()
        var tempPlusMinus: [String] = [String]()
        var tempPlayerLogoURL: [String] = [String]()
        var tempActiveState: [String] = [String]()
        
        for i in 0..<playerIDCount{
            
            let playerNameValue = realm.object(ofType: playerInfoTable.self, forPrimaryKey:i)!.playerName;
            let jerseyNum = realm.object(ofType: playerInfoTable.self, forPrimaryKey:i)!.jerseyNum;
            let positionType = realm.object(ofType: playerInfoTable.self, forPrimaryKey:i)!.positionType;
            let TeamID = realm.object(ofType: playerInfoTable.self, forPrimaryKey:i)!.TeamID;
            let lineNum = realm.object(ofType: playerInfoTable.self, forPrimaryKey:i)!.lineNum;
            let goalCount = realm.object(ofType: playerInfoTable.self, forPrimaryKey:i)!.goalCount;
            let assitsCount = realm.object(ofType: playerInfoTable.self, forPrimaryKey:i)!.assitsCount;
            let shotCount = realm.object(ofType: playerInfoTable.self, forPrimaryKey:i)!.shotCount;
            let plusMinus = realm.object(ofType: playerInfoTable.self, forPrimaryKey:i)!.plusMinus;
            let playerLogoURL = realm.object(ofType: playerInfoTable.self, forPrimaryKey:i)!.playerLogoURL
            let activeState = realm.object(ofType: playerInfoTable.self, forPrimaryKey:i)!.activeState;
            tempPlayerNameArray.append(playerNameValue)
            tempjerseyNum.append(String(jerseyNum))
            tempPositionType.append(positionType)
            tempTeamID.append(TeamID)
            tempLineNum.append(String(lineNum))
            tempGoalCount.append(String(goalCount))
            tempAssitsCount.append(String(assitsCount))
            tempShotCount.append(String(shotCount))
            tempPlusMinus.append(String(plusMinus))
            tempPlayerLogoURL.append(String(playerLogoURL))
            tempActiveState.append(String(activeState))
            
        }
        
        csvText_playerInfoTable = "playerName,jerseyNum,positionType,TeamID,lineNum,goalCount,assitsCount,shotCount,plusMinus,playerLogoURL,activeState\n"
        for x in 0..<tempPlayerNameArray.count {
            
            let playerNameVar = tempPlayerNameArray[x]
            let playerJerseyNum = tempjerseyNum[x]
            let playerPositionTypeVar = tempPositionType[x]
            let playerTeamIDVar = tempTeamID[x]
            let playerLineNumVar = tempLineNum[x]
            let playerGoalCountVar = tempGoalCount[x]
            let playerAssitsCountVar = tempAssitsCount[x]
            let playerShotCountVar = tempShotCount[x]
            let playerPlusMinusVar = tempPlusMinus[x]
            let playerLogoURLVar = tempPlayerLogoURL[x]
            let playerActiveStateVar = tempActiveState[x]
            
            let newLine =  playerNameVar + "," + playerJerseyNum + "," + playerPositionTypeVar + "," + playerTeamIDVar + "," + playerLineNumVar + "," + playerGoalCountVar + "," + playerAssitsCountVar + "," + playerShotCountVar + "," + playerPlusMinusVar + "," + playerLogoURLVar + "," + playerActiveStateVar + "\n"
            csvText_playerInfoTable.append(newLine)
        }
        
    }
    // creats csv file for new game table
    func createCSVNewGameInfo(){
        
         let realm = try! Realm()
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        _ = formatter.string(from: date)
        
        let newGameIDCount =  realm.objects(newGameTable.self).filter("gameID >= 0").count
        var tempDateGamePlayed: [String] = [String]()
        var tempOpposingTeamID: [String] = [String]()
        var tempHomeTeamID: [String] = [String]()
        var tempGameType: [String] = [String]()
        var tempLocation: [String] = [String]()
        var tempWiningTeam: [String] = [String]()
        var tempLosingTeam: [String] = [String]()
        var tempSeasonYear: [String] = [String]()
        var tempTieBool: [String] = [String]()
        var tempActiveGameStatus: [String] = [String]()
        var tempActiveState: [String] = [String]()
        
        for i in 0..<newGameIDCount{
            
            let dateGamePlayedValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.dateGamePlayed;
            let opposingTeamIDValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.opposingTeamID;
            let homeTeamIDValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.homeTeamID;
            let gameTypeValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.gameType;
            let locationValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.gameLocation;
            let winingTeamValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.winingTeamID;
            let losingTeamValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.losingTeamID;
            let seasonYearValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.seasonYear;
            let tieBoolValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.tieGameBool;
            let activeGameStatusValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.activeGameStatus;
            let activeStateValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.activeState;
            let dateString = formatter.string(from: dateGamePlayedValue!)
            tempDateGamePlayed.append(dateString)
            tempOpposingTeamID.append(String(opposingTeamIDValue))
            tempHomeTeamID.append(String(homeTeamIDValue))
            tempGameType.append(gameTypeValue)
            tempLocation.append(locationValue)
            tempWiningTeam.append(String(winingTeamValue))
            tempLosingTeam.append(String(losingTeamValue))
            tempSeasonYear.append(String(seasonYearValue))
            tempTieBool.append(String(tieBoolValue))
            tempActiveGameStatus.append(String(activeGameStatusValue))
            tempActiveState.append(String(activeStateValue))
            
        }
        
        csvText_newGameTable = "dateGamePlayed,opposingTeamID,homeTeamID,gameType,gameLocation,winingTeamID,losingTeamID,seasonYear,tieBool,activeGameStatus,activeState\n"
        for x in 0..<newGameIDCount {
            
            let dateGamePlayerVar = tempDateGamePlayed[x]
            let opposingTeamIDVar = tempOpposingTeamID[x]
            let homeTeamIDVar = tempHomeTeamID[x]
            let gameTypeVar = tempGameType[x]
            let locationVar = tempLocation[x]
            let winingTeamVar = tempWiningTeam[x]
            let losingTeamVar = tempLosingTeam[x]
            let seasonYearVar = tempSeasonYear[x]
            let tieBoolVar = tempTieBool[x]
            let activeGameStatusVar = tempActiveGameStatus[x]
            let activeStateVar = tempActiveState[x]
            
            let newLine =  dateGamePlayerVar + "," + opposingTeamIDVar + "," + homeTeamIDVar + "," + gameTypeVar + "," + locationVar + "," + winingTeamVar + "," + losingTeamVar + "," + seasonYearVar + "," + tieBoolVar + "," + activeGameStatusVar + "," + activeStateVar + "\n"
 
            csvText_newGameTable.append(newLine)
        }
       
       
    }
    // creats csv file for goal marker table
    func createCSVGoalMarkerTable(){
        
         let realm = try! Realm()
        
        let goalMarkerIDCount =  realm.objects(goalMarkersTable.self).filter("cordSetID >= 0").count
        var tempgameID: [String] = [String]()
        var tempgoalType: [String] = [String]()
        var temppowerPlay: [String] = [String]()
        var temppowerPlayID: [String] = [String]()
        var tempTeamID: [String] = [String]()
        var tempgoalieID: [String] = [String]()
        var tempgoalPlayerID: [String] = [String]()
        var tempassitantPlayerID: [String] = [String]()
        var tempsec_assitantPlayerID: [String] = [String]()
        var tempperiodNumSet: [String] = [String]()
        var tempxCordGoal: [String] = [String]()
        var tempyCordGoal: [String] = [String]()
        var tempshotLocation: [String] = [String]()
        var tempactiveState: [String] = [String]()
        
        
        for i in 0..<goalMarkerIDCount{
            
            let gameID = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.gameID
            let goalType = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.goalType
            let powerPlay = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.powerPlay
            let powerPlayID = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.powerPlayID
            let TeamID = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.TeamID
            let goalieID = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.goalieID
            let goalPlayerID = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.goalPlayerID
            let assitantPlayerID = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.assitantPlayerID
            let sec_assitantPlayerID = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.sec_assitantPlayerID
            let periodNumSet = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.periodNum
            let xCordGoal = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.xCordGoal
            let yCordGoal = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.yCordGoal
            let shotLocation = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.shotLocation
            let activeState = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.activeState
            tempgameID.append(String(gameID))
            tempgoalType.append(goalType)
            temppowerPlay.append(String(powerPlay))
            temppowerPlayID.append(String(powerPlayID))
            tempTeamID.append(String(TeamID))
            tempgoalieID.append(String(goalieID))
            tempgoalPlayerID.append(String(goalPlayerID))
            tempassitantPlayerID.append(String(assitantPlayerID))
            tempsec_assitantPlayerID.append(String(sec_assitantPlayerID))
            tempperiodNumSet.append(String(periodNumSet))
            tempxCordGoal.append(String(xCordGoal))
            tempyCordGoal.append(String(yCordGoal))
            tempshotLocation.append(String(shotLocation))
            tempactiveState.append(String(activeState))
            
        }
        
        csvText_goalMarkerTable = "gameID,goalType,powerPlay,powerPlayID,TeamID,goalieID,goalPlayerID,assitantPlayerID,sec_assitantPlayerID,periodNumSet,xCordGoal,yCordGoal,shotLocation,activeState\n"
        for x in 0..<goalMarkerIDCount{
            
            let gameIDVar = tempgameID[x]
            let goalTypeVar = tempgoalType[x]
            let powerPlayVar = temppowerPlay[x]
            let powerPlayIDVar = temppowerPlayID[x]
            let teamIDVar = tempTeamID[x]
            let goalieIDVar = tempgoalieID[x]
            let goalPlayerIDVar = tempgoalPlayerID[x]
            let assitIDVar = tempassitantPlayerID[x]
            let sec_assitIDVar = tempsec_assitantPlayerID[x]
            let periodNumVar = tempperiodNumSet[x]
            let xCordVar = tempxCordGoal[x]
            let yCordVar = tempyCordGoal[x]
            let shotLocationVar = tempshotLocation[x]
            let activeStateVar = tempactiveState[x]
            
            let newLine =  gameIDVar + "," + goalTypeVar + "," + powerPlayVar + "," + powerPlayIDVar + "," + teamIDVar + "," + goalieIDVar + "," + goalPlayerIDVar + "," + assitIDVar + "," + sec_assitIDVar +
                "," + periodNumVar + "," + xCordVar + "," + yCordVar + "," + shotLocationVar + "," + activeStateVar + "\n"
 
            csvText_goalMarkerTable.append(newLine)
        }
   
        
       
    }
    // creats csv file for shot marker table
    func createCSVShotMarkerTable(){
        
        let realm = try! Realm()
        
        let shotMarkerIDCount =  realm.objects(shotMarkerTable.self).filter("cordSetID >= 0").count
        var tempgameID: [String] = [String]()
        var tempTeamID: [String] = [String]()
        var tempgoalieID: [String] = [String]()
        var tempperiodNumSet: [String] = [String]()
        var tempxCordGoal: [String] = [String]()
        var tempyCordGoal: [String] = [String]()
        var tempshotLocation: [String] = [String]()
        var tempactiveState: [String] = [String]()
        
        
        for i in 0..<shotMarkerIDCount{
            
            let gameID = realm.object(ofType: shotMarkerTable.self, forPrimaryKey:i)!.gameID
            let TeamID = realm.object(ofType: shotMarkerTable.self, forPrimaryKey:i)!.TeamID
            let goalieID = realm.object(ofType: shotMarkerTable.self, forPrimaryKey:i)!.goalieID
            let periodNumSet = realm.object(ofType: shotMarkerTable.self, forPrimaryKey:i)!.periodNum
            let xCordGoal = realm.object(ofType: shotMarkerTable.self, forPrimaryKey:i)!.xCordShot
            let yCordGoal = realm.object(ofType: shotMarkerTable.self, forPrimaryKey:i)!.yCordShot
            let shotLocation = realm.object(ofType: shotMarkerTable.self, forPrimaryKey:i)!.shotLocation
            let activeState = realm.object(ofType: shotMarkerTable.self, forPrimaryKey:i)!.activeState
            tempgameID.append(String(gameID))
            tempTeamID.append(String(TeamID))
            tempgoalieID.append(String(goalieID))
            tempperiodNumSet.append(String(periodNumSet))
            tempxCordGoal.append(String(xCordGoal))
            tempyCordGoal.append(String(yCordGoal))
            tempshotLocation.append(String(shotLocation))
            tempactiveState.append(String(activeState))
            
        }
        
        csvText_shotMarkerTable = "gameID,TeamID,goalieID,periodNumSet,xCordGoal,yCordGoal,shotLocation,activeState\n"
        for x in 0..<shotMarkerIDCount{
            
            let gameIDVar = tempgameID[x]
            let teamIDVar = tempTeamID[x]
            let goalieIDVar = tempgoalieID[x]
            let periodNumVar = tempperiodNumSet[x]
            let xCordVar = tempxCordGoal[x]
            let yCordVar = tempyCordGoal[x]
            let shotLocationVar = tempshotLocation[x]
            let activeStateVar = tempactiveState[x]
            
            let newLine =  gameIDVar + "," + teamIDVar + "," + goalieIDVar + "," + periodNumVar + "," + xCordVar + "," + yCordVar + "," + shotLocationVar + "," + activeStateVar + "\n"
      
            csvText_shotMarkerTable.append(newLine)
        }
 
    }
    
    // creats csv file for penalty table
    func createCSVPenaltyTable(){
        
        let realm = try! Realm()
        
        let shotMarkerIDCount =  realm.objects(penaltyTable.self).filter("penaltyID >= 0").count
        var tempGameID: [String] = [String]()
        var tempPlayerID: [String] = [String]()
        var tempPenaltyType: [String] = [String]()
        var tempTimeOfOffense: [String] = [String]()
        var tempxCord: [String] = [String]()
        var tempyCord: [String] = [String]()
        var tempactiveState: [String] = [String]()
        
        
        for i in 0..<shotMarkerIDCount{
            
            let gameID = realm.object(ofType: penaltyTable.self, forPrimaryKey:i)!.gameID
            let playerID = realm.object(ofType: penaltyTable.self, forPrimaryKey:i)!.playerID
            let penaltyType = realm.object(ofType: penaltyTable.self, forPrimaryKey:i)!.penaltyType
            let timeOfOffense = realm.object(ofType: penaltyTable.self, forPrimaryKey:i)!.timeOfOffense
            let xCord = realm.object(ofType: penaltyTable.self, forPrimaryKey:i)!.xCord
            let yCord = realm.object(ofType: penaltyTable.self, forPrimaryKey:i)!.yCord
            let activeState = realm.object(ofType: penaltyTable.self, forPrimaryKey:i)!.activeState
            tempGameID.append(String(gameID))
            tempPlayerID.append(String(playerID))
            tempPenaltyType.append(String(penaltyType))
            tempTimeOfOffense.append(dateToString.dateToStringFormatter(unformattedDate: timeOfOffense!))
            tempxCord.append(String(xCord))
            tempyCord.append(String(yCord))
            tempactiveState.append(String(activeState))
            
        }
        
        csvText_penaltyInfoTable = "gameID,playerID,penaltyType,timeOfOffense,xCord,yCord,activeState\n"
        for x in 0..<shotMarkerIDCount{
            
            let gameIDVar = tempGameID[x]
            let playerIDVar = tempPlayerID[x]
            let penaltyTypeVar = tempPenaltyType[x]
            let timeOfOffenseVar = tempTimeOfOffense[x]
            let xCordVar = tempxCord[x]
            let yCordVar = tempyCord[x]
            let activeStateVar = tempactiveState[x]
            
            let newLine =  gameIDVar + "," + playerIDVar + "," + penaltyTypeVar + "," + timeOfOffenseVar + "," + xCordVar + "," + yCordVar + "," + activeStateVar + "\n"

            csvText_penaltyInfoTable.append(newLine)
        }

        
    }
    
    
    // creats csv file for Overall stats table
    func createCSVOverallStatsTable(){
        
        let realm = try! Realm()
        
        let overallIDCount =  realm.objects(overallStatsTable.self).filter("overallStatsID >= 0").count
        var tempGameID: [String] = [String]()
        var tempPlayerID: [String] = [String]()
        var tempLineNum: [String] = [String]()
        var tempGoalCount: [String] = [String]()
        var tempAssistCount: [String] = [String]()
        var tempPlusMinus: [String] = [String]()
        var tempactiveState: [String] = [String]()
        
        
        for i in 0..<overallIDCount{
            
            let gameID = realm.object(ofType: overallStatsTable.self, forPrimaryKey:i)!.gameID
            let playerID = realm.object(ofType: overallStatsTable.self, forPrimaryKey:i)!.playerID
            let lineNum = realm.object(ofType: overallStatsTable.self, forPrimaryKey:i)!.lineNum
            let goalCount = realm.object(ofType: overallStatsTable.self, forPrimaryKey:i)!.goalCount
            let assistCount = realm.object(ofType: overallStatsTable.self, forPrimaryKey:i)!.assistCount
            let plusMinus = realm.object(ofType: overallStatsTable.self, forPrimaryKey:i)!.plusMinus
            let activeState = realm.object(ofType: overallStatsTable.self, forPrimaryKey:i)!.activeState
            tempGameID.append(String(gameID))
            tempPlayerID.append(String(playerID))
            tempLineNum.append(String(lineNum))
            tempGoalCount.append(String(goalCount))
            tempAssistCount.append(String(assistCount))
            tempPlusMinus.append(String(plusMinus))
            tempactiveState.append(String(activeState))
            
        }
        
        csvText_overallStatsTable = "gameID,playerID,lineNum,goalCount,assistCount,plusMinus,activeState\n"
        for x in 0..<overallIDCount{
            
            let gameIDVar = tempGameID[x]
            let playerIDVar = tempPlayerID[x]
            let lineNumVar = tempLineNum[x]
            let goalCountVar = tempGoalCount[x]
            let assistCountVar = tempAssistCount[x]
            let plusMinusVar = tempPlusMinus[x]
            let activeStateVar = tempactiveState[x]
            
            let newLine =  gameIDVar + "," + playerIDVar + "," + lineNumVar + "," + goalCountVar + "," + assistCountVar + "," + plusMinusVar + "," + activeStateVar + "\n"
 
            csvText_overallStatsTable.append(newLine)
        }
 
        
    }
    
    // creats csv file for Overall stats table
    func createCSVFaceoffStatsTable(){
        
        let realm = try! Realm()
        
        let overallIDCount =  realm.objects(faceOffInfoTable.self).filter("faceoffID >= 0").count
        var tempGameID: [String] = [String]()
        var tempWiningPlayerID: [String] = [String]()
        var tempLoosingPlayerID: [String] = [String]()
        var tempPeriodNum: [String] = [String]()
        var tempFaceoffLocationCode: [String] = [String]()
        var tempactiveState: [String] = [String]()
        
        
        for i in 0..<overallIDCount{
            
            let gameID = realm.object(ofType: faceOffInfoTable.self, forPrimaryKey:i)!.gameID
            let winingPlayerID = realm.object(ofType: faceOffInfoTable.self, forPrimaryKey:i)!.winingPlayerID
            let losingPlayerID = realm.object(ofType: faceOffInfoTable.self, forPrimaryKey:i)!.losingPlayerID
            let periodNum = realm.object(ofType: faceOffInfoTable.self, forPrimaryKey:i)!.periodNum
            let faceoffLocationCode = realm.object(ofType: faceOffInfoTable.self, forPrimaryKey:i)!.faceoffLocationCode
            let activeState = realm.object(ofType: faceOffInfoTable.self, forPrimaryKey:i)!.activeState
            tempGameID.append(String(gameID))
            tempWiningPlayerID.append(String(winingPlayerID))
            tempLoosingPlayerID.append(String(losingPlayerID))
            tempPeriodNum.append(String(periodNum))
            tempFaceoffLocationCode.append(String(faceoffLocationCode))
            tempactiveState.append(String(activeState))
            
        }
        
        csvText_faceoffTable = "gameID,winingPlayerID,losingPlayerID,periodNum,faceoffLocationCode,activeState\n"
        for x in 0..<overallIDCount{
            
            let gameIDVar = tempGameID[x]
            let winingPlayerIDVar = tempWiningPlayerID[x]
            let losingPlayerIDVar = tempLoosingPlayerID[x]
            let periodNumVar = tempPeriodNum[x]
            let faceoffLocationCodeVar = tempFaceoffLocationCode[x]
            let activeStateVar = tempactiveState[x]
            
            let newLine =  gameIDVar + "," + winingPlayerIDVar + "," + losingPlayerIDVar + "," + periodNumVar + "," + faceoffLocationCodeVar + "," + activeStateVar + "\n"
    
            csvText_faceoffTable.append(newLine)
        }
        
     
        
    }
    
    func lineTypeFormatChecker(lineType: String) -> Bool{
        switch lineType.trimmingCharacters(in: .whitespacesAndNewlines) {
        case "LW":
            return true
        case "RW":
            return true
        case "LD":
            return true
        case "RD":
            return true
        case "G":
            return true
        default:
            return false
        }
    }
    
    func lineNumeFormatChecker(lineNum: Int) -> Bool{
        if lineNum <= 6 && lineNum >= 0 {
            return true
        }
        return false
    }
    
    func importPlayersFormatChecker(fileName: URL) -> Bool{
        
        var firstFileContentsParsed: [[String]] = [[String]]()
        var playerInfoMultiArray = [[String]]()
        
        do {
            firstFileContentsParsed =  (try String(contentsOf: fileName, encoding: .utf8)).components(separatedBy: "\n").map{ $0.components(separatedBy: ",") }
        } catch {
            print("Error Finding Contents of File")
            fatalErrorAlert("Error Attempting to Find Contents of File has failed. Please make sure you are importing a compatible file")
            
        }
        
         if firstFileContentsParsed[0].count == 4 {
            // copy contents of old array into newly formatted array
            for x in 1..<firstFileContentsParsed.count{
                if firstFileContentsParsed[x][0] != "" && firstFileContentsParsed[x][0] != "\r" && firstFileContentsParsed[x][0] != "\n"{
                   
                    playerInfoMultiArray.append(firstFileContentsParsed[x])
                 
                }
            }
     
            // start at second row ignore first one
            for x in 0..<playerInfoMultiArray.count{
                if playerInfoMultiArray[x].count == 4 {
                    // check to see if player name is filled in
                    if playerInfoMultiArray[x][0] == ""{
                         fatalErrorAlert("Player Name Error ocuured attempting to parse the player file imported, please refer to the CSV file format on coachassistant.ca")
                        return false
                        
                    }else{
                        
                        // append player name if format right
                        playerNamesFromCSV.append(playerInfoMultiArray[x][0])
                        // check to see if the player name has a jersey number
                        if playerInfoMultiArray[x][1] == "" && canCast().clastToInt(valueToCast: playerInfoMultiArray[x][1]) == false {
                            fatalErrorAlert("Jersey Number Error ocuured attempting to parse the player file imported, please refer to the CSV file format on coachassistant.ca")
                            return false
                        }else{
                       
                            // append jersey number if format right
                            playerJerseyNumFromCSV.append(Int(playerInfoMultiArray[x][1])!)
                        
                            // check to see if the player name has a line number
                            if playerInfoMultiArray[x][2] == "" && canCast().clastToInt(valueToCast: playerInfoMultiArray[x][2]) == false{
                                fatalErrorAlert("Line Number Error ocuured attempting to parse the player file imported, please refer to the CSV file format on coachassistant.ca")
                                return false
                            }else{
                                if lineNumeFormatChecker(lineNum: Int(playerInfoMultiArray[x][2])!) == true{
                                    // append line number if format right
                                    playerLineNumFromCSV.append(Int(playerInfoMultiArray[x][2])!)
                                    // check to see if the player name has a line type
                                    if playerInfoMultiArray[x][3] == "" && lineTypeFormatChecker(lineType: playerInfoMultiArray[x][3]) == false{
                                        fatalErrorAlert("Line Type Error ocuured attempting to parse the player file imported, please refer to the CSV file format on coachassistant.ca")
                                        return false
                                    }else{
                                        // append line type if format right
                                        playerLineTypeFromCSV.append((playerInfoMultiArray[x][3]).trimmingCharacters(in: .whitespacesAndNewlines))
                                        
                                    }
                                }else{
                                    fatalErrorAlert("Line Number Error ocuured attempting to parse the player file imported, please refer to the CSV file format on coachassistant.ca")
                                    return false
                                }
                               
                            }
                        }
                    }
                }else{
                    fatalErrorAlert("ERROR, Attempting to parse the player file imported, please refer to the CSV file format on coachassistant.ca")
                    return false
                }
            }
            return true
        }else{
            fatalErrorAlert("ERROR, Attempting to parse the player file imported, please refer to the CSV file format on coachassistant.ca")
            return false
        }
    }

    
    // convert csv files to string then convert [[string]] to team table in realm
    func csvStringToRealmTeamTable(fileName: URL) -> Bool{

        var firstFileContentsParsed: [[String]] = [[String]]()
        var teamInfoMultiArray = [[String]]()
        // get contents of specfic csv file and place into array above
        do {
            firstFileContentsParsed =  (try String(contentsOf: fileName, encoding: .utf8)).components(separatedBy: "\n").map{ $0.components(separatedBy: ",") }
        } catch {
            print("Error Finding Containts of File")
            fatalErrorAlert("ERROR, attempting to find contents of file has failed. Please make sure you are importing a compatible file")
        }
    
        var rowIndexCount: Int = 0
        
        // copy contents of old array into newly formatted array
        for x in 1..<firstFileContentsParsed.count{
            
            if firstFileContentsParsed[x].indices.contains(0) {
                if firstFileContentsParsed[x][0] != "" && firstFileContentsParsed[x][0] != "\r" && firstFileContentsParsed[x][0] != "\n"{
                
                    // check to see if 2d row is already created
                    if !teamInfoMultiArray.indices.contains(rowIndexCount){
                        teamInfoMultiArray.append(["", ""])
                    }
                   
                    // add team name to array
                    teamInfoMultiArray[rowIndexCount][0] = (firstFileContentsParsed[x][0])
                    
                }
            }
            if firstFileContentsParsed[x].indices.contains(1) {
                if firstFileContentsParsed[x][1] != "" && firstFileContentsParsed[x][1] != "\r" && firstFileContentsParsed[x][1] != "\n"{
                
                    // check to see if 2d row is already created
                    if !teamInfoMultiArray.indices.contains(rowIndexCount){
                        teamInfoMultiArray.append(["", ""])
                    }
                    // add team name to array
                    teamInfoMultiArray[rowIndexCount][1] = (firstFileContentsParsed[x][1])
                }
            }
            rowIndexCount = rowIndexCount + 1
        }
        
            for x in 0..<teamInfoMultiArray.count{
                if (teamInfoMultiArray[x].count == 2){
                    if teamInfoMultiArray[x][0] == ""{
                        print("Error Finding Containts of File team name")
                        fatalErrorAlert("Team Name ERROR ocuured attempting to parse the player file imported, please refer to the CSV file format on coachassistant.ca")
                        return false
                    }else{
                        teamNameFromCSV.append(teamInfoMultiArray[x][0])
                        if teamInfoMultiArray[x][1] != "" {
                            let value = (teamInfoMultiArray[x][1]).trimmingCharacters(in: .whitespacesAndNewlines)
                            if canCast().clastToInt(valueToCast: value) == true && Int(value)! >= 1990 {
                                teamSeasonYearFromCSV.append(Int(value)!)
                            }else{
                                teamSeasonYearFromCSV.append(getDate().getYear())
                            }
                
                        }else{
                            teamSeasonYearFromCSV.append(getDate().getYear())
                        }
                    }
                }else{
                    fatalErrorAlert("ERROR, Attempting to parse the team file imported, please refer to the CSV file format on coachassistant.ca")
                    return false
                    
                }
            }

            return true
    }

    
    // func used to delete old CSV files stored in file manager app
    func oldCSVFileFinder(){
        let fileManager = FileManager.default
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let documentsPath = documentsUrl.path
        
        do {
            if let documentPath = documentsPath
            {
                let fileNames = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
                print("all files in cache: \(fileNames)")
                for fileName in fileNames {
                    
                    if (fileName.hasSuffix(".csv"))
                    {
                        let filePathName = "\(documentPath)/\(fileName)"
                        try fileManager.removeItem(atPath: filePathName)
                    }
                }
                
                let files = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
                print("all files in cache after deleting images: \(files)")
            }
            
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }
    
    func zipGameSaves(fileURL: [URL]){
        do {
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                
                let tempUrl = dir.appendingPathComponent("GameSaves")
                let fileURLSaveLocation = tempUrl.appendingPathComponent("gameSavesBackup.zip")
                
                try Zip.zipFiles(paths: fileURL, zipFilePath: fileURLSaveLocation, password: nil, progress: { (progress) -> () in
                    print(progress)
                }) //Zip
            }
        }catch{
            print("Failed to Zip Files")
        }
        
    }
    
    func decompressZipGameSaves(){
        do {
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                
                let tempUrl = dir.appendingPathComponent("GameSaves")
                let fileURL = tempUrl.appendingPathComponent("gameSavesBackup.zip")
                try Zip.quickUnzipFile(fileURL, progress: { (progress) in
                    print(progress)
                    
                })
            }
        }catch{
            print("Unable to unzip gamesaves file")
                
        }
        
    }
    
    func localBackupWriter() -> URL{
        var filesToShare = [Any]()
        var finalZipRestingPlace: URL!
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let realmFileSearch = dir.appendingPathComponent("default.realm")
            
            if FileManager.default.fileExists(atPath: realmFileSearch.path) {
                
                let tempUrl = dir.appendingPathComponent("Backups")
                finalZipRestingPlace = tempUrl.appendingPathComponent("coachAssistantBackup.zip")
                do {
                    try Zip.zipFiles(paths: [realmFileSearch], zipFilePath: finalZipRestingPlace, password: nil, progress: { (progress) -> () in
                        print(progress)
                        if progress == 1.0{
                            // Make the activityViewContoller which shows the share-view
                            // Add the path of the file to the Array
                            filesToShare.append(finalZipRestingPlace!)
                            
                            let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
                            activityViewController.excludedActivityTypes = [UIActivity.ActivityType.print, UIActivity.ActivityType.assignToContact]
                            // Show the share-view
                            activityViewController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                                if completed {
                                    let date = "\(getDate().getYear()).\(getDate().getMonth()).\(getDate().getDay())"
                                    
                                    UserDefaults.standard.set(date, forKey: "lastBackup")
                                    self.backupUpDateCheck()
                                }
                                // User completed activity
                            }
                            
                            self.present(activityViewController, animated: true, completion: nil)
                            if let popOver = activityViewController.popoverPresentationController {
                                popOver.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
                                popOver.sourceView = self.backupTableView
                                
                            }
                            
                        }
                    })
                    
                }catch{
                    print("Failed to Zip Files")
                    self.fatalErrorAlert("Failed to Zip Files")
                }
                
            }else{
                print("cant find realm file")
            }
        }
        return finalZipRestingPlace
    }
    
    
    func iCloudDocumentWriter(fileURL: URL){
        
        var isDir:ObjCBool = false
        
        if FileManager.default.fileExists(atPath: fileURL.path, isDirectory: &isDir) {
            do {
                try FileManager.default.removeItem(at: fileURL)
            }
            catch {
                //Error handling
                print("Error in removing item from icloud container")
                fatalErrorAlert("Error in removing old files from iCloud container, please contact support")
            }
        }
        
        do {
            try FileManager.default.copyItem(at: fileURL, to: fileURL)
            let date = "\(getDate().getYear()).\(getDate().getMonth()).\(getDate().getDay())"
            
            UserDefaults.standard.set(date, forKey: "lastBackup")
            self.backupUpDateCheck()
        }
        catch {
            //Error handling
            print("Error in coping item from local directory to icloud container")
            fatalErrorAlert("Error in coping item from local directory to icloud container, please contact support")
        }
        
    }
    
    func unZipBackup(documentURL: URL){
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let realmFileSearch = dir.appendingPathComponent("default.realm")
            
            if FileManager.default.fileExists(atPath: realmFileSearch.path) {
                do{
                    try FileManager.default.removeItem(at: realmFileSearch)
                }catch let error as NSError{
                    print(error)
                }
            }
            
            try! Zip.unzipFile(documentURL, destination: dir, overwrite: true, password: nil, progress: { (progress) in
                print(progress)
                if progress == 1.0{
                    if !FileManager.default.fileExists(atPath: realmFileSearch.path){
                        let pathExt = realmFileSearch.pathExtension
                        print("path ext is: \(pathExt)")
                        if pathExt != "realm"{
                            self.fatalErrorAlert("File failed inspection test. Make sure the file being imported is of type 'default.realm'. Import aborted")
                            do{
                                try FileManager.default.removeItem(at: realmFileSearch)
                            }catch let error as NSError{
                                print(error)
                            }
                        }else{
                            self.reloadAppAlert()
                        }
                       
                    }
                }
            }, fileOutputHandler: { (result) in
                if !result.isFileURL == true{
                    print("Unable to locate unzipped file, Whoops!")
                }
            })
            
        }
    }
    
    func showUIDocumentController(){
        
        let importMenu = UIDocumentPickerViewController(documentTypes: [String(kUTTypeCommaSeparatedText), String(kUTTypeZipArchive)], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
    }
    
   
    
    // -------------------------------------------------------- swifty store kit stuffss ------------------------------------------------------
    func productRetrieve(){
        
        SwiftyStoreKit.retrieveProductsInfo([productID]) { result in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                print("Product: \(product.localizedDescription), price: \(priceString)")
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
            }
            else {
                print("Error: \(String(describing: result.error))")
                self.purchaseErrorAlert(alertMsg: "An upgrade cannot be found an unknown error occured. Please contact support.")
            }
        }
    }
    
    func productPurchase(){
        
        SwiftyStoreKit.purchaseProduct(productID, quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                UserDefaults.standard.set(true, forKey: "userPurchaseConf")
                self.reloadAppAlert()
                
            case .error(let error):
                switch error.code {
                case .unknown:
                    print("Unknown error. Please contact support")
                    self.purchaseErrorAlert(alertMsg: "Unknown error. Please contact support")
                case .clientInvalid:
                    print("Not allowed to make the payment")
                case .paymentCancelled:
                    break
                case .paymentInvalid:
                    print("The purchase identifier was invalid")
                case .paymentNotAllowed:
                    print("The device is not allowed to make the payment")
                    self.purchaseErrorAlert(alertMsg: "The device is not allowed to make the payment")
                case .storeProductNotAvailable:
                    print("The product is not available in the current storefront")
                    self.purchaseErrorAlert(alertMsg: "The product is not available in the current storefront")
                case .cloudServicePermissionDenied:
                    print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed:
                    print("Could not connect to the network")
                    self.purchaseErrorAlert(alertMsg: "Could not connect to the network, please make sure your are connected to the internet")
                case .cloudServiceRevoked:
                    print("User has revoked permission to use this cloud service")
                    self.purchaseErrorAlert(alertMsg: "Please update your account premisions or call Apple for furthur assitance regarding your cloud premissions")
                default:
                    print((error as NSError).localizedDescription)
                }
            }
        }
        
    }
    // ---------------------------------------------- popup viewcontroller stuffssssss --------------------------
    // popup default team selection view
    func popupPlayerAssignmentVC(){
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let popupVC = storyboard.instantiateViewController(withIdentifier: "Settings_Assign_Players_View_Controller") as! Settings_Assign_Players_View_Controller
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = .crossDissolve
        
        popupVC.playerNameArray = playerNamesFromCSV
        popupVC.playerJerseyNumArray = playerJerseyNumFromCSV
        popupVC.playerLineNumArray = playerLineNumFromCSV
        popupVC.playerLineTypeArray = playerLineTypeFromCSV
        
        let pVC = popupVC.popoverPresentationController
        pVC?.permittedArrowDirections = .any
        pVC?.delegate = self
        
        present(popupVC, animated: true, completion: nil)
        print("popupPlayerAssignmentVC is presentd")
        
        print(playerJerseyNumFromCSV)
    }
    // -------------------------------------------------------------------------------------------------------
    
    // --------------------------------------------------------------------------------------------------------------------------------
    // ----------------------------------------------- popup alerts -------------------------------------------------------------------
    
    func confirmationLocalAlert(){
        
        // create confirmation alert to save to local storage
        let exportAlert = UIAlertController(title: localizedString().localized(value:"Confirmation Alert"), message: localizedString().localized(value:"Are you sure you would like to export all App Data to your Local Storage?"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        exportAlert.addAction(UIAlertAction(title: localizedString().localized(value:"Cancel"), style: UIAlertAction.Style.default, handler: nil))
        exportAlert.addAction(UIAlertAction(title: localizedString().localized(value:"Continue"), style: UIAlertAction.Style.default, handler: { action in
            
           
            
            self.localBackupWriter()
     
            
        }))
        // show the alert
        self.present(exportAlert, animated: true, completion: nil)
        
    }
    
    func confirmationiCloudAlert(){
        
        // create confirmation alert to save to icloiud storage
        let exportAlert = UIAlertController(title: localizedString().localized(value:"Confirmation Alert"), message: localizedString().localized(value:"Are you sure you would like to export all App Data to your iCloud Account?"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        exportAlert.addAction(UIAlertAction(title: localizedString().localized(value:"Cancel"), style: UIAlertAction.Style.default, handler: nil))
        exportAlert.addAction(UIAlertAction(title: localizedString().localized(value:"Continue"), style: UIAlertAction.Style.default, handler: { action in
            
         
            
            self.iCloudDocumentWriter(fileURL: self.localBackupWriter())
            
        }))
        // show the alert
        self.present(exportAlert, animated: true, completion: nil)
        
    }
    
    func purchaseErrorAlert(alertMsg: String){
        // create the alert
        let alreadyProAlert = UIAlertController(title: "Whoops!", message: alertMsg, preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        alreadyProAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(alreadyProAlert, animated: true, completion: nil)
    }
    
    func importAlert(message: String){
        
        // create the alert
        let importAlert = UIAlertController(title: localizedString().localized(value: message), message: "", preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        importAlert.addAction(UIAlertAction(title: localizedString().localized(value: "OK"), style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(importAlert, animated: true, completion: nil)
    }
    
    
    // display prompt before excuting realm deletion
    func deleteDataPrompt(){
        let realm = try! Realm()
        // create the alert
        let dataDelete = UIAlertController(title: localizedString().localized(value: "App Data Deletion"), message: localizedString().localized(value: "Would you like to wipe all data stored locally on this device?"), preferredStyle: UIAlertController.Style.alert)
        dataDelete.addAction(UIAlertAction(title: localizedString().localized(value: "Cancel"), style: UIAlertAction.Style.cancel, handler: nil))
        // add an action (button)
        dataDelete.addAction(UIAlertAction(title: localizedString().localized(value: "Yes"), style: UIAlertAction.Style.destructive, handler: {action in
            try? realm.write ({
                //delete contents of DB
                realm.deleteAll()
            })
            UserDefaults.standard.removeObject(forKey: "defaultHomeTeamID")
        }))
        
        // show the alert
        self.present(dataDelete, animated: true, completion: nil)
        
    }
    // display success alert if export succesful
    func successLocalAlert(){
        
        // create the alert
        let sucessfulExportAlert = UIAlertController(title: localizedString().localized(value: "Succesful Export"), message: localizedString().localized(value: "All App Data was Succesfully Exported Locally"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        sucessfulExportAlert.addAction(UIAlertAction(title: localizedString().localized(value: "Cancel"), style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(sucessfulExportAlert, animated: true, completion: nil)
        
    }
    
    // upgrade alert used to display the use cases for upgrading to pro
    func upgradeNowAlert(){
     
        // create the alert
        let notPro = UIAlertController(title: localizedString().localized(value: "You're Missing Out!"), message: localizedString().localized(value: "Upgrade now and unlock the ability to backup your teams stats to the Cloud! Coach Assistant Pro memebers get iCloud backup and import access across all devices with PRO!"), preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        notPro.addAction(UIAlertAction(title: localizedString().localized(value:"No Thanks"), style: UIAlertAction.Style.default, handler: nil))
        // add an action (button)
        notPro.addAction(UIAlertAction(title: localizedString().localized(value:"Upgrade Now!"), style: UIAlertAction.Style.destructive, handler: { action in
            self.productRetrieve()
            self.productPurchase()
        }))
        // show the alert
        self.present(notPro, animated: true, completion: nil)
        
        
    }
    
    func missingIcloudCredsAlert(){
        
        // create the alert
        let sucessfulExportAlert = UIAlertController(title: localizedString().localized(value:"iCloud Error"), message: localizedString().localized(value:"In order to backup to iCloud you must first be logged into and or have access to an iCloud account"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        sucessfulExportAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(sucessfulExportAlert, animated: true, completion: nil)
    }
    
    func icloudOnAlert(){
        // create the alert
        let icloudOnALert = UIAlertController(title: localizedString().localized(value:"iCloud Backup On"), message: localizedString().localized(value:"Backups and Imports will now be made in conjuntion with iCloud, to export / import locally on this device please toggle off 'Backup to iCloud'"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        icloudOnALert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(icloudOnALert, animated: true, completion: nil)
        
    }
    
    func reloadAppAlert(){
        
        // create the alert
        let reloadAppAlert = UIAlertController(title: localizedString().localized(value: "App Restart Needed!"), message: localizedString().localized(value:"Please reload app for chnages to take full effect."), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        reloadAppAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            self.reloadView()
        }))
        
        // show the alert
        self.present(reloadAppAlert, animated: true, completion: nil)
    }
    
    func fatalErrorAlert(_ msg: String){
        
        let errorAlert = UIAlertController(title: localizedString().localized(value:"Whoops!"), message: localizedString().localized(value:"\(msg)"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(errorAlert, animated: true, completion: nil)
        
    }
    
    func importPlayersTeamTypeAlert(){
        
        let errorAlert = UIAlertController(title: localizedString().localized(value:"Import File Type"), message: localizedString().localized(value: "Would you like to Import Players or Teams"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        errorAlert.addAction(UIAlertAction(title: "Import Players", style: UIAlertAction.Style.default, handler: { action in
            self.importPlayersBool = 0
            self.showUIDocumentController()
        }))
        // add an action (button)
        errorAlert.addAction(UIAlertAction(title: "Import Teams", style: UIAlertAction.Style.default, handler: { action in
            self.importPlayersBool = 1
            self.showUIDocumentController()
        }))
        // add an action (button)
        errorAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        // show the alert
        self.present(errorAlert, animated: true, completion: nil)
        
    }
    
    
    // -------------------------------------------------------------------------------------------------------------------------------------
    
    // ----------------------------------------------- tableview stuffssss -------------------------------------------------------------
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        switch indexPath.section {
        case 1:
            switch indexPath.row{
            case 0:
                if (icloudToggleSwitch.isOn == true){
                    confirmationiCloudAlert()
                    
                }else{
                    confirmationLocalAlert()
                }
                break

            default:
                print("FATAL CELL SELECTION ERROR")
                break
            }
        case 2:
            switch indexPath.row{
            case 0:
                
                self.importPlayersBool = 2
                self.showUIDocumentController()
                
                break
            case 1:
                importPlayersTeamTypeAlert()
                
                break
            default:
                print("FATAL CELL SELECTION ERROR")
                break
            }
        case 3:
            print("Asking User to delete app data")
            deleteDataPrompt()
            break
        default:
            print("FATAL CELL SELECTION ERROR")
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------
    // -------------------------------------------------------- segeu stuffsss ----------------------------------------------------------------
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check is appropriate segue is being used
        if (segue.identifier == "importPopUpSegue"){
            // set var vc as destination segue
            let vc = segue.destination as! Import_Pop_Up_View
            if (icloudToggleSwitch.isOn == true){
                vc.importFromIcloudBool = true
            }else{
                vc.importFromIcloudBool = false
            }
            
        }
    }
    
}
// --------------------------------------------------------------------------------------------------------------------------------
extension Settings_Backup_View_Controller: UIDocumentPickerDelegate,UINavigationControllerDelegate{
    
    func genRealmPrimaryID() -> Int{
        
        let realm = try! Realm()
        
        if (realm.objects(teamInfoTable.self).max(ofProperty: "teamID") as Int? != nil){
            return (realm.objects(teamInfoTable.self).max(ofProperty: "teamID") as Int? ?? 0) + 1;
        }else{
            return (realm.objects(teamInfoTable.self).max(ofProperty: "teamID") as Int? ?? 0);
            
        }
    }
    
    func documentPicker(_ documentPicker: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        switch importPlayersBool{
        case 0:
            if  urls.count > 1 {
                fatalErrorAlert("No more than one file can be selected please select a player CSV file.")
            }else {
                // passed multi file selection checker
                
                // check to see if player csv file format is correct
                if importPlayersFormatChecker(fileName: urls.first!) == true{
                    popupPlayerAssignmentVC()
                    importPlayersBool = nil
                }
                
                return
                
            }
            break
        case 1:
            if  urls.count > 1 {
                fatalErrorAlert("No more than one file can be selected please select a team CSV file.")
            }else {
                // passed multi file selection checker
                if csvStringToRealmTeamTable(fileName: urls.first!) == true{
                    
                    let realm = try! Realm()
                    
                    print(teamNameFromCSV)
                    
                    for x in 0..<teamNameFromCSV.count{
                        let newTeam = teamInfoTable()
                        newTeam.teamID = genRealmPrimaryID()
                        
                        try! realm.write{
                            newTeam.nameOfTeam = teamNameFromCSV[x]
                            newTeam.seasonYear = teamSeasonYearFromCSV[x]
                            newTeam.activeState = true
                            realm.add(newTeam, update: true)
                        }
                    }
                    importAlert(message: "All Teams Imported Suyccessfully!")
                    importPlayersBool = nil
                }
                
                return
                
            }
            break
        case 2:
            if  urls.count > 1 {
                fatalErrorAlert("Please import your 'coachAssistantBackup.zip file. THe file selected does not meet this criteria.'")
            }else {
                unZipBackup(documentURL: urls.first!)
                return
            }
            break
        default:
            fatalErrorAlert("Unable to determine course of action based on file imported. Please try again.")
            break
        }
        

    }
    
    func documentMenu(_ documentMenu: UIDocumentPickerViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("document Picker Was Cancelled")
        controller.dismiss(animated: true, completion: nil)
    }
    
}
