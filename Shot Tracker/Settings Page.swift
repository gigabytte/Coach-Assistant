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
    
    var realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // get rotation allowances of device
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // set auto rotation to true for current view
        appDelegate.shouldRotate = true
        // Do any additional setup after loading the view.
        
        // round corners of export and import buttons
        exportCVSButton.layer.cornerRadius = 10
        importCVSButton.layer.cornerRadius = 10
        // hide successful text fild y default on load
        sucessProcessText.isHidden = true
        // runn delay then present missing icloud account warning
        delay(0.5){
            if (self.isICloudContainerAvailable() != true){
                self.missingIcloudLogin()
            }
        }
    }
    // on button press perform CVS export functions
    @IBAction func exportCVSButtonAction(_ sender: UIButton) {
        // check is icloud account checker retuns true
        if (isICloudContainerAvailable() == true){
        confirmationiCloudAlert()
        }else{
            confirmationLocalAlert()
        }
        
    }
    // on button press perform CVS import functions
    @IBAction func importCVSButtonAction(_ sender: UIButton) {
        
        
    }
    // creats csv file for  team info table
    func createCSVTeamInfo(){
        
        let TeamIDCount =  realm.objects(teamInfoTable.self).filter("teamID >= 0").count
        var tempTeamIDArray: [String] = [String]()
        var tempTeamNameArray: [String] = [String]()
        // print(TeamIDCount)
        for i in 0..<TeamIDCount{
            
            let teamIDValue = realm.object(ofType: teamInfoTable.self, forPrimaryKey: i)!.teamID;
            let teamNameValue = realm.object(ofType: teamInfoTable.self, forPrimaryKey:i)!.nameOfTeam;
            tempTeamIDArray.append(String(teamIDValue))
            tempTeamNameArray.append(teamNameValue)
        }
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let dateString = formatter.string(from: date)
        
        let fileName = "Team_Info_Table_" + dateString + ".csv"
        var csvText = "teamID,nameOfTeam\n"
        for x in 0..<tempTeamIDArray.count {
            
            let teamIDVar = tempTeamIDArray[x]
            let teamNameVar = tempTeamNameArray[x]
            
            let newLine = String(teamIDVar) + ", " + teamNameVar + "\n"
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
        var tempPlayerIDArray: [String] = [String]()
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
            
            let playerIDValue = self.realm.object(ofType: playerInfoTable.self, forPrimaryKey: i)!.playerID;
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
            tempPlayerIDArray.append(String(playerIDValue))
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
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let dateString = formatter.string(from: date)
        
        let fileName = "Player_Info_Table_" + dateString + ".csv"
        var csvText = "playerID,playerName,jerseyNum,positionType,TeamID,lineNum,goalCount,assitsCount,shotCount,plusMinus,activeState\n"
        for x in 0..<tempPlayerIDArray.count {
            
            let playerIDVar = tempPlayerIDArray[x]
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
            
            let newLine =  playerIDVar + ", " + playerNameVar + ", " + playerJerseyNum + ", " + playerPositionTypeVar + ", " + playerTeamIDVar + ", " + playerLineNumVar + ", " + playerGoalCountVar + ", " + playerAssitsCountVar + ", " + playerShotCountVar + ", " + playerPlusMinusVar + ", " + playerActiveStateVar + "\n"
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
        var tempGameIDArray: [String] = [String]()
        var tempDateGamePlayed: [String] = [String]()
        var tempOpposingTeamID: [String] = [String]()
        var tempHomeTeamID: [String] = [String]()
        var tempGameType: [String] = [String]()
        var tempActiveState: [String] = [String]()
        
        for i in 0..<newGameIDCount{
            
            let gameIDValue = self.realm.object(ofType: newGameTable.self, forPrimaryKey: i)!.gameID;
            let dateGamePlayedValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.dateGamePlayed;
            let opposingTeamIDValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.opposingTeamID;
            let homeTeamIDValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.homeTeamID;
            let gameTypeValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.gameType;
            let activeStateValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.activeState;
            let dateString = formatter.string(from: dateGamePlayedValue!)
            tempGameIDArray.append(String(gameIDValue))
            tempDateGamePlayed.append(dateString)
            tempOpposingTeamID.append(String(opposingTeamIDValue))
            tempHomeTeamID.append(String(homeTeamIDValue))
            tempGameType.append(gameTypeValue)
            tempActiveState.append(String(activeStateValue))
            
        }

        let fileName = "New_Game_Info_Table_" + dateString + ".csv"
        var csvText = "gameID,dateGamePlayed,opposingTeamID,homeTeamID,gameType,activeState\n"
        for x in 0..<tempGameIDArray.count {
            
            let gameIDVar = tempGameIDArray[x]
            let dateGamePlayerVar = tempDateGamePlayed[x]
            let opposingTeamIDVar = tempOpposingTeamID[x]
            let homeTeamIDVar = tempHomeTeamID[x]
            let gameTypeVar = tempGameType[x]
            let activeStateVar = tempActiveState[x]
            
            let newLine =  gameIDVar + ", " + dateGamePlayerVar + ", " + opposingTeamIDVar + ", " + homeTeamIDVar + ", " + gameTypeVar + ", " + activeStateVar + "\n"
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
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let dateString = formatter.string(from: date)
        
        let newGameIDCount =  realm.objects(newGameTable.self).filter("gameID >= 0").count
        var tempGameIDArray: [String] = [String]()
        var tempDateGamePlayed: [String] = [String]()
        var tempOpposingTeamID: [String] = [String]()
        var tempHomeTeamID: [String] = [String]()
        var tempGameType: [String] = [String]()
        var tempActiveState: [String] = [String]()
        
        for i in 0..<newGameIDCount{
            
            let gameIDValue = self.realm.object(ofType: newGameTable.self, forPrimaryKey: i)!.gameID;
            let dateGamePlayedValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.dateGamePlayed;
            let opposingTeamIDValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.opposingTeamID;
            let homeTeamIDValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.homeTeamID;
            let gameTypeValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.gameType;
            let activeStateValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.activeState;
            let dateString = formatter.string(from: dateGamePlayedValue!)
            tempGameIDArray.append(String(gameIDValue))
            tempDateGamePlayed.append(dateString)
            tempOpposingTeamID.append(String(opposingTeamIDValue))
            tempHomeTeamID.append(String(homeTeamIDValue))
            tempGameType.append(gameTypeValue)
            tempActiveState.append(String(activeStateValue))
            
        }
        
        let fileName = "New_Game_Info_Table_" + dateString + ".csv"
        var csvText = "gameID,dateGamePlayed,opposingTeamID,homeTeamID,gameType,activeState\n"
        for x in 0..<tempGameIDArray.count {
            
            let gameIDVar = tempGameIDArray[x]
            let dateGamePlayerVar = tempDateGamePlayed[x]
            let opposingTeamIDVar = tempOpposingTeamID[x]
            let homeTeamIDVar = tempHomeTeamID[x]
            let gameTypeVar = tempGameType[x]
            let activeStateVar = tempActiveState[x]
            
            let newLine =  gameIDVar + ", " + dateGamePlayerVar + ", " + opposingTeamIDVar + ", " + homeTeamIDVar + ", " + gameTypeVar + ", " + activeStateVar + "\n"
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
    // creats csv file for shot marker table
    func createCSVShotMarkerTable(){
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let dateString = formatter.string(from: date)
        
        let newGameIDCount =  realm.objects(newGameTable.self).filter("gameID >= 0").count
        var tempGameIDArray: [String] = [String]()
        var tempDateGamePlayed: [String] = [String]()
        var tempOpposingTeamID: [String] = [String]()
        var tempHomeTeamID: [String] = [String]()
        var tempGameType: [String] = [String]()
        var tempActiveState: [String] = [String]()
        
        for i in 0..<newGameIDCount{
            
            let gameIDValue = self.realm.object(ofType: newGameTable.self, forPrimaryKey: i)!.gameID;
            let dateGamePlayedValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.dateGamePlayed;
            let opposingTeamIDValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.opposingTeamID;
            let homeTeamIDValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.homeTeamID;
            let gameTypeValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.gameType;
            let activeStateValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.activeState;
            let dateString = formatter.string(from: dateGamePlayedValue!)
            tempGameIDArray.append(String(gameIDValue))
            tempDateGamePlayed.append(dateString)
            tempOpposingTeamID.append(String(opposingTeamIDValue))
            tempHomeTeamID.append(String(homeTeamIDValue))
            tempGameType.append(gameTypeValue)
            tempActiveState.append(String(activeStateValue))
            
        }
        
        let fileName = "New_Game_Info_Table_" + dateString + ".csv"
        var csvText = "gameID,dateGamePlayed,opposingTeamID,homeTeamID,gameType,activeState\n"
        for x in 0..<tempGameIDArray.count {
            
            let gameIDVar = tempGameIDArray[x]
            let dateGamePlayerVar = tempDateGamePlayed[x]
            let opposingTeamIDVar = tempOpposingTeamID[x]
            let homeTeamIDVar = tempHomeTeamID[x]
            let gameTypeVar = tempGameType[x]
            let activeStateVar = tempActiveState[x]
            
            let newLine =  gameIDVar + ", " + dateGamePlayerVar + ", " + opposingTeamIDVar + ", " + homeTeamIDVar + ", " + gameTypeVar + ", " + activeStateVar + "\n"
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
    // check if user is logged into iclpoud account
    func isICloudContainerAvailable()->Bool {
        if let currentToken = FileManager.default.ubiquityIdentityToken {
            return true
        }
        else {
            return false
        }
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
    
    func confirmationiCloudAlert(){
        
        // create confirmation alert to save to icloud account
        let exportAlert = UIAlertController(title: "Confirmation Alert", message: "Are you sure you would like to export all App Data to iCloud?", preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        exportAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        exportAlert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: {action in
            self.createCSVTeamInfo()
            self.createCSVPlayerInfo()
            self.createCSVNewGameInfo()
            self.createCSVGoalMarkerTable()
            self.createCSVShotMarkerTable()
        }))
        // show the alert
        self.present(exportAlert, animated: true, completion: nil)
        
    }
    func confirmationLocalAlert(){
            
             // create confirmation alert to save to local storage
            let exportAlert = UIAlertController(title: "Confirmation Alert", message: "Are you sure you would like to export all App Data to you Local Storage?", preferredStyle: UIAlertController.Style.alert)
            // add an action (button)
            exportAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
            exportAlert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: { action in
                self.createCSVTeamInfo()
                self.createCSVPlayerInfo()
                self.createCSVNewGameInfo()
                self.createCSVGoalMarkerTable()
                self.createCSVShotMarkerTable()
            }))
            // show the alert
            self.present(exportAlert, animated: true, completion: nil)
            
        }
    func missingIcloudLogin(){
        
        // create indicating missing iCloud account
        let noIcloud = UIAlertController(title: "iCloud Account Error", message: "All data will be exported or imported via local storage if iCloud account is not present.", preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        noIcloud.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(noIcloud, animated: true, completion: nil)
        
    }
        
    // delay loop
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
        }
    }
