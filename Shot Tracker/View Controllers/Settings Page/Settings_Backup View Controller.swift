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

final class Settings_Backup_View_Controller: UITableViewController {
    
    @IBOutlet weak var backToiClkoudLabel: UILabel!
    @IBOutlet var backupTableView: UITableView!
    @IBOutlet weak var icloudToggleSwitch: UISwitch!
    @IBOutlet weak var backupDateLabel: UILabel!
    @IBOutlet weak var backupLabel: UILabel!
    @IBOutlet weak var importLabel: UILabel!
    
    
    
    var realm = try! Realm()
    var successImport: Bool!
    var productID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(myMethod(notification:)), name: NSNotification.Name(rawValue: "backupSettingsPageRefresh"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(myColorMethod(notification:)), name: NSNotification.Name(rawValue: "darModeToggle"), object: nil)
        
        productID = universalValue().coachAssistantProID
        // check is icloud conatiner exsiss on user icloud account

        backupUpDateCheck()
    
        
        // check icloud exprt criteria
        reloadView()
        print("Back Up View Controller Called")
        viewColour()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (UserDefaults.standard.bool(forKey: "userPurchaseConf") != true){
            upgradeNowAlert()
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
    
    func reloadView(){
        
        icloudToggleSwitch.isOn = UserDefaults.standard.bool(forKey: "iCloudBackupToggle")
        
        if (UserDefaults.standard.bool(forKey: "userPurchaseConf") == true){
            if (icloudAccountCheck().isICloudContainerAvailable() == true){
                if (icloudToggleSwitch.isOn == true){
                    
                    print("User can export to iCloud")
                    backupLabel.text = "iCloud Backup"
                    importLabel.text = "Import iCloud Backup"
                    
                    
                }else{
                    print("User cannot export to iCLoud!")
                    
                    backupLabel.text = "Backup Locally"
                    importLabel.text = "Import Backup Locally"
                    
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
     
        delay(0.5){
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
    
    // on buttoin press delete all of relam data
    @IBAction func wipeDataButton(_ sender: Any) {
        deleteDataPrompt()
    }
    
    // on button press perform CVS export functions
    @IBAction func exportCVSButtonAction(_ sender: UIButton) {
        // run confirmation alert
        if (icloudToggleSwitch.isOn == true){
            confirmationiCloudAlert()
            
        }else{
            confirmationLocalAlert()
        }
        
    }
    // on button press perform CVS import functions
    @IBAction func importCVSButtonAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "importPopUpSegue", sender: nil);
    }
    
    func backupUpDateCheck(){
        
        if(UserDefaults.standard.object(forKey: "lastBackup") != nil){
            backupDateLabel.text = "Last Known Backup: \(UserDefaults.standard.object(forKey: "lastBackup") as! String)"
        }else{
            backupDateLabel.text = "Backup has not been Performed!"
        }
        
    }
    
    /*@IBAction func visitWebsiteButton(_ sender: Any) {
        
        let actionSheet = UIAlertController(title: localizedString().localized(value:"Import Troubles?"), message: localizedString().localized(value:"Exported your teams stats before you updated Coach Assistant? You might have a legacy stats template! Dont worry you won't loose all your stats. We have a easy to use guide, check it out!"), preferredStyle: .actionSheet)
        
        
        let openAction = UIAlertAction(title: localizedString().localized(value:"open"), style: .default, handler: { (alert: UIAlertAction!) -> Void in
            guard let url = URL(string: universalValue().legacyWebsiteURLHelp) else { return }
            UIApplication.shared.open(url)
        })
        // tapp anywhere outside of popup alert controller
        let cancelAction = UIAlertAction(title: localizedString().localized(value:"Cancel"), style: .cancel, handler: { (alert: UIAlertAction!) -> Void in
            print("didPress Cancel")
        })
        // Add the actions to your actionSheet
        actionSheet.addAction(openAction)
        actionSheet.addAction(cancelAction)
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: visitWebsiteButton.frame.origin.x, y: visitWebsiteButton.frame.origin.y, width: visitWebsiteButton.frame.width / 2, height: visitWebsiteButton.frame.height)
            
        }
        // Present the controller
        self.present(actionSheet, animated: true, completion: nil)
        
    }*/
    
    // creats csv file for  team info table
    func createCSVTeamInfo(){
        
        let TeamIDCount =  realm.objects(teamInfoTable.self).filter("teamID >= 0").count
        var tempTeamNameArray: [String] = [String]()
        var tempSeasonYearArray: [String] = [String]()
        var tempActiveStateArray: [String] = [String]()
        // print(TeamIDCount)
        for i in 0..<TeamIDCount{
            
            let teamNameValue = realm.object(ofType: teamInfoTable.self, forPrimaryKey:i)!.nameOfTeam;
            let seasonYearValue = realm.object(ofType: teamInfoTable.self, forPrimaryKey:i)!.seasonYear;
            let activeStateValue = realm.object(ofType: teamInfoTable.self, forPrimaryKey:i)!.activeState;
            tempTeamNameArray.append(teamNameValue)
            tempSeasonYearArray.append(String(seasonYearValue))
            tempActiveStateArray.append(String(activeStateValue))
        }
        
        let fileName = "Realm_Team_Info_Table" + ".csv"
        var csvText = "nameOfTeam,seasonYear,activeState\n"
        for x in 0..<tempTeamNameArray.count {
            
            let teamNameVar = tempTeamNameArray[x]
            let seaonYearVar = tempSeasonYearArray[x]
            let activeStateVar = tempActiveStateArray[x]
            
            let newLine = teamNameVar + "," + seaonYearVar + "," + activeStateVar + "\n"
            csvText.append(newLine)
        }
        
        if (icloudToggleSwitch.isOn == true){
            localDocumentReader(fileName: fileName, csvText: csvText)
            iCloudDocumentReader(fileName: fileName)
        }else{
            localDocumentReader(fileName: fileName, csvText: csvText)
        }
    }
    // creats csv file for player info table
    func createCSVPlayerInfo(){
        
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
            tempActiveState.append(String(activeState))
            
        }
        
        let fileName = "Realm_Player_Info_Table" + ".csv"
        var csvText = "playerName,jerseyNum,positionType,TeamID,lineNum,goalCount,assitsCount,shotCount,plusMinus,activeState\n"
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
            let playerActiveStateVar = tempActiveState[x]
            
            let newLine =  playerNameVar + "," + playerJerseyNum + "," + playerPositionTypeVar + "," + playerTeamIDVar + "," + playerLineNumVar + "," + playerGoalCountVar + "," + playerAssitsCountVar + "," + playerShotCountVar + "," + playerPlusMinusVar + "," + playerActiveStateVar + "\n"
            csvText.append(newLine)
        }
        
        if (icloudToggleSwitch.isOn == true){
            localDocumentReader(fileName: fileName, csvText: csvText)
            iCloudDocumentReader(fileName: fileName)
        }else{
            localDocumentReader(fileName: fileName, csvText: csvText)
        }
    }
    // creats csv file for new game table
    func createCSVNewGameInfo(){
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let dateString = formatter.string(from: date)
        
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
        
        let fileName = "Realm_New_Game_Info_Table" + ".csv"
        var csvText = "dateGamePlayed,opposingTeamID,homeTeamID,gameType,gameLocation,winingTeamID,losingTeamID,seasonYear,tieBool,activeGameStatus,activeState\n"
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
 
            csvText.append(newLine)
        }
        
        if (icloudToggleSwitch.isOn == true){
            localDocumentReader(fileName: fileName, csvText: csvText)
            iCloudDocumentReader(fileName: fileName)
        }else{
            localDocumentReader(fileName: fileName, csvText: csvText)
        }
    }
    // creats csv file for goal marker table
    func createCSVGoalMarkerTable(){
        
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
        
        let fileName = "Realm_Goal_Marker_Table" + ".csv"
        var csvText = "gameID,goalType,powerPlay,powerPlayID,TeamID,goalieID,goalPlayerID,assitantPlayerID,sec_assitantPlayerID,periodNumSet,xCordGoal,yCordGoal,shotLocation,activeState\n"
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
 
            csvText.append(newLine)
        }
        
        if (icloudToggleSwitch.isOn == true){
            localDocumentReader(fileName: fileName, csvText: csvText)
            iCloudDocumentReader(fileName: fileName)
        }else{
            localDocumentReader(fileName: fileName, csvText: csvText)
        }
    }
    // creats csv file for shot marker table
    func createCSVShotMarkerTable(){
        
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
        
        let fileName = "Realm_Shot_Marker_Table" + ".csv"
        var csvText = "gameID,TeamID,goalieID,periodNumSet,xCordGoal,yCordGoal,shotLocation,activeState\n"
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
      
            csvText.append(newLine)
        }
        
        if (icloudToggleSwitch.isOn == true){
            localDocumentReader(fileName: fileName, csvText: csvText)
            iCloudDocumentReader(fileName: fileName)
        }else{
            localDocumentReader(fileName: fileName, csvText: csvText)
        }
    }
    
    // creats csv file for penalty table
    func createCSVPenaltyTable(){
        
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
        
        let fileName = "Realm_Penalty_Table" + ".csv"
        var csvText = "gameID,playerID,penaltyType,timeOfOffense,xCord,yCord,activeState\n"
        for x in 0..<shotMarkerIDCount{
            
            let gameIDVar = tempGameID[x]
            let playerIDVar = tempPlayerID[x]
            let penaltyTypeVar = tempPenaltyType[x]
            let timeOfOffenseVar = tempTimeOfOffense[x]
            let xCordVar = tempxCord[x]
            let yCordVar = tempyCord[x]
            let activeStateVar = tempactiveState[x]
            
            let newLine =  gameIDVar + "," + playerIDVar + "," + penaltyTypeVar + "," + timeOfOffenseVar + "," + xCordVar + "," + yCordVar + "," + activeStateVar + "\n"

            csvText.append(newLine)
        }
        if (icloudToggleSwitch.isOn == true){
            localDocumentReader(fileName: fileName, csvText: csvText)
            iCloudDocumentReader(fileName: fileName)
        }else{
            localDocumentReader(fileName: fileName, csvText: csvText)
        }
    }
    
    
    // creats csv file for Overall stats table
    func createCSVOverallStatsTable(){
        
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
        
        let fileName = "Realm_Overall_Stats_Table" + ".csv"
        var csvText = "gameID,playerID,lineNum,goalCount,assistCount,plusMinus,activeState\n"
        for x in 0..<overallIDCount{
            
            let gameIDVar = tempGameID[x]
            let playerIDVar = tempPlayerID[x]
            let lineNumVar = tempLineNum[x]
            let goalCountVar = tempGoalCount[x]
            let assistCountVar = tempAssistCount[x]
            let plusMinusVar = tempPlusMinus[x]
            let activeStateVar = tempactiveState[x]
            
            let newLine =  gameIDVar + "," + playerIDVar + "," + lineNumVar + "," + goalCountVar + "," + assistCountVar + "," + plusMinusVar + "," + activeStateVar + "\n"
 
            csvText.append(newLine)
        }
        if (icloudToggleSwitch.isOn == true){
            localDocumentReader(fileName: fileName, csvText: csvText)
            iCloudDocumentReader(fileName: fileName)
        }else{
            localDocumentReader(fileName: fileName, csvText: csvText)
        }
    }
    
    // creats csv file for Overall stats table
    func createCSVFaceoffStatsTable(){
        
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
        
        let fileName = "Realm_Faceoff_Stats_Table" + ".csv"
        var csvText = "gameID,winingPlayerID,losingPlayerID,periodNum,faceoffLocationCode,activeState\n"
        for x in 0..<overallIDCount{
            
            let gameIDVar = tempGameID[x]
            let winingPlayerIDVar = tempWiningPlayerID[x]
            let losingPlayerIDVar = tempLoosingPlayerID[x]
            let periodNumVar = tempPeriodNum[x]
            let faceoffLocationCodeVar = tempFaceoffLocationCode[x]
            let activeStateVar = tempactiveState[x]
            
            let newLine =  gameIDVar + "," + winingPlayerIDVar + "," + losingPlayerIDVar + "," + periodNumVar + "," + faceoffLocationCodeVar + "," + activeStateVar + "\n"
    
            csvText.append(newLine)
        }
        if (icloudToggleSwitch.isOn == true){
            localDocumentReader(fileName: fileName, csvText: csvText)
            iCloudDocumentReader(fileName: fileName)
        }else{
            localDocumentReader(fileName: fileName, csvText: csvText)
        }
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
        
        // create the alert
        let dataDelete = UIAlertController(title: localizedString().localized(value: "App Data Deletion"), message: localizedString().localized(value: "Would you like to wipe all data stored locally on this device?"), preferredStyle: UIAlertController.Style.alert)
        dataDelete.addAction(UIAlertAction(title: localizedString().localized(value: "Cancel"), style: UIAlertAction.Style.cancel, handler: nil))
        // add an action (button)
        dataDelete.addAction(UIAlertAction(title: localizedString().localized(value: "Yes"), style: UIAlertAction.Style.destructive, handler: {action in
            try? self.realm.write ({
                //delete contents of DB
                self.realm.deleteAll()
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
        let reloadAppAlert = UIAlertController(title: localizedString().localized(value:"Restart App"), message: localizedString().localized(value:"Please Exit and Close app In order to gain full pro feature set."), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        reloadAppAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            self.reloadView()
        }))
        
        // show the alert
        self.present(reloadAppAlert, animated: true, completion: nil)
    }
    
    func localDocumentReader(fileName: String, csvText: String){
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(fileName)
            
            do {
                try csvText.write(to: fileURL, atomically: false, encoding: .utf8)
                //print("Penalty Table CSV File URL: ", fileURL)
            } catch {
                print("\(error)")
            }
        }
    }
    
    func iCloudDocumentReader(fileName: String){
        
        guard let localDocumentsURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).last else { return }
        
        let fileURL = localDocumentsURL.appendingPathComponent(fileName)
        
        guard let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents").appendingPathComponent(fileName) else { return }
        
        var isDir:ObjCBool = false
        
        if FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: &isDir) {
            do {
                try FileManager.default.removeItem(at: iCloudDocumentsURL)
            }
            catch {
                //Error handling
                print("Error in remove item")
            }
        }
        
        do {
            try FileManager.default.copyItem(at: fileURL, to: iCloudDocumentsURL)
        }
        catch {
            //Error handling
            print("Error in copy item")
        }
    }
    
    
    
    func confirmationLocalAlert(){
        
        // create confirmation alert to save to local storage
        let exportAlert = UIAlertController(title: localizedString().localized(value:"Confirmation Alert"), message: localizedString().localized(value:"Are you sure you would like to export all App Data to your Local Storage?"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        exportAlert.addAction(UIAlertAction(title: localizedString().localized(value:"Cancel"), style: UIAlertAction.Style.default, handler: nil))
        exportAlert.addAction(UIAlertAction(title: localizedString().localized(value:"Continue"), style: UIAlertAction.Style.default, handler: { action in
            self.oldCSVFileFinder()
            self.createCSVTeamInfo()
            self.createCSVPlayerInfo()
            self.createCSVNewGameInfo()
            self.createCSVGoalMarkerTable()
            self.createCSVShotMarkerTable()
            self.createCSVPenaltyTable()
            self.createCSVOverallStatsTable()
            self.createCSVFaceoffStatsTable()
            // save last know backup to user defaults
            let currentDateTime = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy HH:mm"
            let dateString = formatter.string(from: currentDateTime)
            UserDefaults.standard.set(dateString, forKey: "lastBackup")
            self.backupUpDateCheck()
        }))
        // show the alert
        self.present(exportAlert, animated: true, completion: nil)
        
    }
    
    func confirmationiCloudAlert(){
        
        // create confirmation alert to save to local storage
        let exportAlert = UIAlertController(title: localizedString().localized(value:"Confirmation Alert"), message: localizedString().localized(value:"Are you sure you would like to export all App Data to your iCloud Account?"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        exportAlert.addAction(UIAlertAction(title: localizedString().localized(value:"Cancel"), style: UIAlertAction.Style.default, handler: nil))
        exportAlert.addAction(UIAlertAction(title: localizedString().localized(value:"Continue"), style: UIAlertAction.Style.default, handler: { action in
            self.oldCSVFileFinder()
            self.createCSVTeamInfo()
            self.createCSVPlayerInfo()
            self.createCSVNewGameInfo()
            self.createCSVGoalMarkerTable()
            self.createCSVShotMarkerTable()
            self.createCSVPenaltyTable()
            self.createCSVOverallStatsTable()
            self.createCSVFaceoffStatsTable()
            // save last know backup to user defaults
            let currentDateTime = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy HH:mm"
            let dateString = formatter.string(from: currentDateTime)
            UserDefaults.standard.set(dateString, forKey: "lastBackup")
            self.backupUpDateCheck()
        }))
        // show the alert
        self.present(exportAlert, animated: true, completion: nil)
        
    }
    
    
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
                print("Error: \(result.error)")
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
    
    
    func purchaseErrorAlert(alertMsg: String){
        // create the alert
        let alreadyProAlert = UIAlertController(title: "Whoops!", message: alertMsg, preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        alreadyProAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(alreadyProAlert, animated: true, completion: nil)
    }
    
    
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
                self.performSegue(withIdentifier: "importPopUpSegue", sender: nil);
                break
            default:
                break
            }
        case 3:
            print("Asking User to delete app data")
            deleteDataPrompt()
            break
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // delay loop
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
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
