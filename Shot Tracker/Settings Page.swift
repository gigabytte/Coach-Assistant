//
//  Settings Page.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-02-12.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import MessageUI

class Settings_Page: UIViewController {
    
    @IBOutlet weak var exportCVSButton: UIButton!
    @IBOutlet weak var importCVSButton: UIButton!
    @IBOutlet weak var sucessProcessText: UILabel!
    @IBOutlet weak var backupDateLabel: UILabel!
    @IBOutlet weak var wipeDataButton: UIButton!
    
    var realm = try! Realm()
    var successImport: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wipeDataButton.backgroundColor = .clear
        wipeDataButton.layer.cornerRadius = 5
        wipeDataButton.layer.borderWidth = 1
        wipeDataButton.layer.borderColor = UIColor.black.cgColor
        exportCVSButton.layer.cornerRadius = 5
        importCVSButton.layer.cornerRadius = 5
        
        // Do any additional setup after loading the view.
        
        // round corners of export and import buttons
        exportCVSButton.layer.cornerRadius = 10
        importCVSButton.layer.cornerRadius = 10
        
        backupUpDateCheck()
        promptMessage()
    }
    @IBAction func defaultsButton(_ sender: UIBarButtonItem) {
        
        self.performSegue(withIdentifier: "defaultTeamSelectionSettings", sender: nil);
    }
    // on buttoin press delete all of relam data
    @IBAction func wipeDataButton(_ sender: Any) {
       deleteDataPrompt()
    }
    
    // on button press perform CVS export functions
    @IBAction func exportCVSButtonAction(_ sender: UIButton) {
        // run confirmation alert
        confirmationLocalAlert()
        
    }
    // on button press perform CVS import functions
    @IBAction func importCVSButtonAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "importPopUpSegue", sender: nil);
    }
    
    func backupUpDateCheck(){
        
        if(UserDefaults.standard.object(forKey: "lastBackup") != nil){
            backupDateLabel.text = "Last Known Backup: \(UserDefaults.standard.object(forKey: "lastBackup") as! String)"
        }else{
            backupDateLabel.isHidden = true
        }
        
    }
    
    func promptMessage(){
        if (successImport != nil){
            if (successImport != true){
                self.sucessProcessText.text = "Please Try Importing Again"
                self.sucessProcessText.textAlignment = .center
                self.sucessProcessText.textColor = UIColor.red
            }else{
                self.sucessProcessText.text = "Import was Successful"
                self.sucessProcessText.textAlignment = .center
                self.sucessProcessText.textColor = UIColor.red
            }
        }else{
            self.sucessProcessText.isHidden = true
        }
    }
    
    
    // creats csv file for  team info table
    func createCSVTeamInfo(){
        
        let TeamIDCount =  realm.objects(teamInfoTable.self).filter("teamID >= 0").count
        var tempTeamNameArray: [String] = [String]()
        var tempActiveStateArray: [String] = [String]()
        // print(TeamIDCount)
        for i in 0..<TeamIDCount{
            
            let teamNameValue = realm.object(ofType: teamInfoTable.self, forPrimaryKey:i)!.nameOfTeam;
            let activeStateValue = realm.object(ofType: teamInfoTable.self, forPrimaryKey:i)!.activeState;
            tempTeamNameArray.append(teamNameValue)
            tempActiveStateArray.append(String(activeStateValue))
        }
     
        let fileName = "Realm_Team_Info_Table" + ".csv"
        var csvText = "nameOfTeam,activeState\n"
        for x in 0..<tempTeamNameArray.count {
            
            let teamNameVar = tempTeamNameArray[x]
            let activeStateVar = tempActiveStateArray[x]
            
            let newLine = teamNameVar + "," + activeStateVar + "\n"
            if(x == tempTeamNameArray.count){
                newLine.dropLast()
                newLine.dropLast()
            }
            csvText.append(newLine)
        }
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(fileName)
            
            do {
                try csvText.write(to: fileURL, atomically: false, encoding: .utf8)
                print("Team CSV File URL: ", fileURL)
            } catch {
                print("\(error)")
            }
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
            if(x == tempPlayerNameArray.count){
                newLine.dropLast()
                newLine.dropLast()
            }
            csvText.append(newLine)
        }
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(fileName)
            
            do {
                try csvText.write(to: fileURL, atomically: false, encoding: .utf8)
                print("Player Info CSV File URL: ", fileURL)
            } catch {
                print("\(error)")
            }
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
            tempTieBool.append(String(tieBoolValue))
            tempActiveGameStatus.append(String(activeGameStatusValue))
            tempActiveState.append(String(activeStateValue))
            
        }
        
        let fileName = "Realm_New_Game_Info_Table" + ".csv"
        var csvText = "dateGamePlayed,opposingTeamID,homeTeamID,gameType,gameLocation,winingTeamID,losingTeamID,tieBool,activeGameStatus,activeState\n"
        for x in 0..<newGameIDCount {
        
            let dateGamePlayerVar = tempDateGamePlayed[x]
            let opposingTeamIDVar = tempOpposingTeamID[x]
            let homeTeamIDVar = tempHomeTeamID[x]
            let gameTypeVar = tempGameType[x]
            let locationVar = tempLocation[x]
            let winingTeamVar = tempWiningTeam[x]
            let losingTeamVar = tempLosingTeam[x]
            let tieBoolVar = tempTieBool[x]
            let activeGameStatusVar = tempActiveGameStatus[x]
            let activeStateVar = tempActiveState[x]
            
            let newLine =  dateGamePlayerVar + "," + opposingTeamIDVar + "," + homeTeamIDVar + "," + gameTypeVar + "," + locationVar + "," + winingTeamVar + "," + losingTeamVar + "," + tieBoolVar + "," + activeGameStatusVar + "," + activeStateVar + "\n"
            if(x == newGameIDCount){
                newLine.dropLast()
                newLine.dropLast()
            }
            csvText.append(newLine)
        }
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(fileName)
            
            do {
                try csvText.write(to: fileURL, atomically: false, encoding: .utf8)
                print("New Game Info CSV File URL: ", fileURL)
            } catch {
                print("\(error)")
            }
        }
    }
    // creats csv file for goal marker table
    func createCSVGoalMarkerTable(){
        
        let goalMarkerIDCount =  realm.objects(goalMarkersTable.self).filter("cordSetID >= 0").count
        var tempgameID: [String] = [String]()
        var tempgoalType: [String] = [String]()
        var temppowerPlay: [String] = [String]()
        var tempTeamID: [String] = [String]()
        var tempgoalieID: [String] = [String]()
        var tempgoalPlayerID: [String] = [String]()
        var tempassitantPlayerID: [String] = [String]()
        var tempsec_assitantPlayerID: [String] = [String]()
        var againstFLine: [String] = [String]()
        var againstDLine: [String] = [String]()
        var tempperiodNumSet: [String] = [String]()
        var tempxCordGoal: [String] = [String]()
        var tempyCordGoal: [String] = [String]()
        var tempshotLocation: [String] = [String]()
        var tempactiveState: [String] = [String]()
        
        
        for i in 0..<goalMarkerIDCount{
            
            let gameID = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.gameID
            let goalType = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.goalType
            let powerPlay = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.powerPlay
            let TeamID = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.TeamID
            let goalieID = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.goalieID
            let goalPlayerID = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.goalPlayerID
            let assitantPlayerID = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.assitantPlayerID
            let sec_assitantPlayerID = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.sec_assitantPlayerID
            let againstFLineNum = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.againstFLine
            let againstDLineNum = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.againstDLine
            let periodNumSet = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.periodNum
            let xCordGoal = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.xCordGoal
            let yCordGoal = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.yCordGoal
            let shotLocation = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.shotLocation
            let activeState = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.activeState
            tempgameID.append(String(gameID))
            tempgoalType.append(goalType)
            temppowerPlay.append(String(powerPlay))
            tempTeamID.append(String(TeamID))
            tempgoalieID.append(String(goalieID))
            tempgoalPlayerID.append(String(goalPlayerID))
            tempassitantPlayerID.append(String(assitantPlayerID))
            tempsec_assitantPlayerID.append(String(sec_assitantPlayerID))
            againstFLine.append(String(againstFLineNum))
            againstDLine.append(String(againstDLineNum))
            tempperiodNumSet.append(String(periodNumSet))
            tempxCordGoal.append(String(xCordGoal))
            tempyCordGoal.append(String(yCordGoal))
            tempshotLocation.append(String(shotLocation))
            tempactiveState.append(String(activeState))
            
        }
        
        let fileName = "Realm_Goal_Marker_Table" + ".csv"
        var csvText = "gameID,goalType,powerPlay,TeamID,goalieID,goalPlayerID,assitantPlayerID,sec_assitantPlayerID,againstFLine,againstDLine,periodNumSet,xCordGoal,yCordGoal,shotLocation,activeState\n"
        for x in 0..<goalMarkerIDCount{
            
            let gameIDVar = tempgameID[x]
            let goalTypeVar = tempgoalType[x]
            let powerPlayVar = temppowerPlay[x]
            let teamIDVar = tempTeamID[x]
            let goalieIDVar = tempgoalieID[x]
            let goalPlayerIDVar = tempgoalPlayerID[x]
            let assitIDVar = tempassitantPlayerID[x]
            let sec_assitIDVar = tempsec_assitantPlayerID[x]
            let againstFLineVar = againstFLine[x]
            let againstDLineVar = againstDLine[x]
            let periodNumVar = tempperiodNumSet[x]
            let xCordVar = tempxCordGoal[x]
            let yCordVar = tempyCordGoal[x]
            let shotLocationVar = tempshotLocation[x]
            let activeStateVar = tempactiveState[x]
            
            let newLine =  gameIDVar + "," + goalTypeVar + "," + powerPlayVar + "," + teamIDVar + "," + goalieIDVar + "," + goalPlayerIDVar + "," + assitIDVar + "," + sec_assitIDVar + "," + againstFLineVar + "," + againstDLineVar + "," + periodNumVar + "," + xCordVar + "," + yCordVar + "," + shotLocationVar + "," + activeStateVar + "\n"
            if(x == goalMarkerIDCount){
                newLine.dropLast()
                newLine.dropLast()
            }
            csvText.append(newLine)
        }
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(fileName)
            
            do {
                try csvText.write(to: fileURL, atomically: false, encoding: .utf8)
                print("Goal Marker Table CSV File URL: ", fileURL)
            } catch {
                print("\(error)")
            }
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
            if(x == shotMarkerIDCount){
                newLine.dropLast()
                newLine.dropLast()
            }
            csvText.append(newLine)
        }
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(fileName)
            
            do {
                try csvText.write(to: fileURL, atomically: false, encoding: .utf8)
                print("Shot Marker Table CSV File URL: ", fileURL)
            } catch {
                print("\(error)")
            }
        }
    }
    
    
    
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
    
    
    // display prompt before excuting realm deletion
    func deleteDataPrompt(){
        
        // create the alert
        let dataDelete = UIAlertController(title: "App Data Deletion", message: "Would you like to wipe all data stored locally on this device?", preferredStyle: UIAlertController.Style.alert)
        dataDelete.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        // add an action (button)
        dataDelete.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive, handler: {action in
            try? self.realm.write ({
                //delete contents of DB
                self.realm.deleteAll()
            })
            UserDefaults.standard.set(nil, forKey: "defaultHomeTeamID")
        }))
        
        // show the alert
        self.present(dataDelete, animated: true, completion: nil)
        
    }
    // display success alert if export succesful
    func successLocalAlert(){
        
        // create the alert
        let sucessfulExportAlert = UIAlertController(title: "Succesful Export", message: "All App Data was Succesfully Exported Locally", preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        sucessfulExportAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(sucessfulExportAlert, animated: true, completion: nil)
        
    }

    func confirmationLocalAlert(){
        
        // create confirmation alert to save to local storage
        let exportAlert = UIAlertController(title: "Confirmation Alert", message: "Are you sure you would like to export all App Data to you Local Storage?", preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        exportAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        exportAlert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: { action in
            self.oldCSVFileFinder()
            self.createCSVTeamInfo()
            self.createCSVPlayerInfo()
            self.createCSVNewGameInfo()
            self.createCSVGoalMarkerTable()
            self.createCSVShotMarkerTable()
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
    
    // delay loop
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}

