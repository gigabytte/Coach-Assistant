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

    }
    // on button press perform CVS export functions
    @IBAction func exportCVSButtonAction(_ sender: UIButton) {
        
        //teamInfoTableRealmProcessing()
        //createCSVTeamInfo()
        //shotMarkerRealmProcessing(cordSetIDArray: [String], tempGameIDArray: [String])
        createCSVShotMarkerTable()
        
    }
    // on button press perform CVS import functions
    @IBAction func importCVSButtonAction(_ sender: UIButton) {
        
        
    }
    
    func createCSVTeamInfo(){
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let dateString = formatter.string(from: date)
        
        let fileName = "Team_Info_Table_" + dateString + ".csv"
        var csvText = "teamID,nameOfTeam\n"
        print(teamInfoTableRealmProcessing().teamIDArray.count )
        for x in 0..<teamInfoTableRealmProcessing().teamIDArray.count {
            
            let teamIDVar = teamInfoTableRealmProcessing().teamIDArray[x]
            let teamNameVar = teamInfoTableRealmProcessing().nameOfTeamArray[x]
            
            let newLine = String(teamIDVar) + ", " + teamNameVar + "\n"
            csvText.append(newLine)
        
        }
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(fileName)
            
            do {
                
                try csvText.write(to: fileURL, atomically: false, encoding: .utf8)
                
                print(fileURL)
                
            } catch {
                
                print("\(error)")
                
            }
            
            }
        }
    
    
    func teamInfoTableRealmProcessing() -> (teamIDArray: [String], nameOfTeamArray: [String]) {
        
        let realm = try! Realm()
        
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
        let teamIDArray = tempTeamIDArray
        let nameOfTeamArray = tempTeamNameArray
        return(teamIDArray, nameOfTeamArray)
    }
    
    func createCSVShotMarkerTable(){
        /*let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let dateString = formatter.string(from: date)
        
        let fileName = "Shot_Marker_Table_" + dateString + ".csv"
        var csvText = "cordsetID,gameID,TeamID,playerID,periodNumSet,xCordSet,yCordSet,shotLocation\n"
        
        var tempTeamIDArray: [String] = shotMarkerRealmProcessing().0!
        var tempPlayerIDArray: [String] = shotMarkerRealmProcessing().1!
        var tempPeriodNUmSetArray: [String] = shotMarkerRealmProcessing().periodNumSet
        var tempXCordArray: [String] = shotMarkerRealmProcessing().xCordShot
        var tempYCordSetArray: [String] = shotMarkerRealmProcessing().yCordShot
        var tempShotLocationArray: [String] = shotMarkerRealmProcessing().shotLocation
        
        for x in 0..<shotMarkerRealmProcessing().cordSetIDArray.count {
            var teamIDVar, playerIDVar, periodNumSetVar, xCordVar, yCordVar, shotLocationVar: String
            (teamIDVar, playerIDVar, periodNumSetVar, xCordVar, yCordVar, shotLocationVar) = ("", "", "", "", "", "")
            let cordSetIDVar = shotMarkerRealmProcessing().cordSetIDArray[x]
            let gameIDVar = shotMarkerRealmProcessing().gameIDArray[x]
            var loopStart = shotMarkerRealmProcessing().teamIDArray.count
            if (shotMarkerRealmProcessing().teamIDArray.count != 0){ loopStart = loopStart - 1}
            for y in 0..<loopStart{
                if (shotMarkerRealmProcessing().teamIDArray[x] != "/"){
                    teamIDVar += ", \(String(shotMarkerRealmProcessing().teamIDArray[x]))"
                    playerIDVar += ", \( String(shotMarkerRealmProcessing().playerIDArray[x]))"
                    periodNumSetVar += ", \(String(shotMarkerRealmProcessing().periodNumSet[x]))"
                    xCordVar += ", \(String(shotMarkerRealmProcessing().xCordShot[x]))"
                    yCordVar += ", \(String(shotMarkerRealmProcessing().yCordShot[x]))"
                    shotLocationVar += ", \(String(shotMarkerRealmProcessing().shotLocation[x]))"
                }else{
                    tempTeamIDArray.remove(at: y)
                    tempPlayerIDArray.remove(at: y)
                    tempPeriodNUmSetArray.remove(at: y)
                    tempXCordArray.remove(at: y)
                    tempYCordSetArray.remove(at: y)
                    tempShotLocationArray.remove(at: y)
                    break;
                }
            //tempTeamIDArray.joined(separator: ",")
            let newLine = String(cordSetIDVar) + "," + gameIDVar + "," + teamIDVar + "," + playerIDVar + "," + periodNumSetVar + "," + xCordVar + "," + yCordVar + "," + shotLocationVar + "\n"
            csvText.append(newLine)
            }
        }
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(fileName)
            do {
                try csvText.write(to: fileURL, atomically: false, encoding: .utf8)
                print(fileURL)
            } catch {
                print("\(error)")
            }
            }*/
        }
    
    func shotMarkerRealmProcessing(cordSetIDArray: [String], tempGameIDArray: [String]) -> ([String]?, [String]?) {
        
        let realm = try! Realm()
        var startLoop: Int!
        var cordSetIDCount =  realm.objects(shotMarkerTable.self).filter("cordSetID >= 0").count
        var tempCordSetID: [String] = [String]()
        var tempGameIDArray: [String] = [String]()
        var tempteamIDArray: [String] = [String]()
        var tempplayerIDArray: [String] = [String]()
        var tempperiodNumSet: [String] = [String]()
        var tempxCordShot: [String] = [String]()
        var tempyCordShot: [String] = [String]()
        var tempShotLocation: [String] = [String]()
        //print(cordSetIDCount)
        if(cordSetIDCount != 1){ startLoop = 1}
        //print(cordSetIDCount)
        /*for i in 0..<0{
            let cordIDValue = realm.object(ofType: shotMarkerTable.self, forPrimaryKey: i)!.cordSetID;
            let gameIDValue = realm.object(ofType: shotMarkerTable.self, forPrimaryKey: i)!.gameID;
            let currentCordID = realm.object(ofType: shotMarkerTable.self, forPrimaryKey: i as Int?);
            tempCordSetID.append(String(cordIDValue))
            tempGameIDArray.append(String(gameIDValue))
            tempteamIDArray = tempteamIDArray + ((currentCordID?.TeamID.compactMap({String($0)}))!)
            tempteamIDArray.append("/")
            tempplayerIDArray = tempplayerIDArray + ((currentCordID?.playerID.compactMap({String($0)}))!)
            tempplayerIDArray.append("/")
            tempperiodNumSet = tempperiodNumSet + ((currentCordID?.periodNumSet.compactMap({String($0)}))!)
            tempperiodNumSet.append("/")
            tempxCordShot = tempxCordShot + ((currentCordID?.xCordShot.compactMap({String($0)}))!)
            tempxCordShot.append("/")
            tempyCordShot = tempyCordShot + ((currentCordID?.yCordShot.compactMap({String($0)}))!)
            tempyCordShot.append("/")
            tempShotLocation = tempShotLocation + ((currentCordID?.shotLocation.compactMap({String($0)}))!)
            tempShotLocation.append("/")
            print(i)
        }*/
        for i in 0..<10 {
            print(i)
        }
        print(tempCordSetID)
        let cordSetIDArray = tempCordSetID
        let gameIDArray = tempGameIDArray
        let teamIDArray = tempteamIDArray
        let playerIDArray = tempplayerIDArray
        let periodNumSet = tempperiodNumSet
        let xCordShot = tempxCordShot
        let yCordShot = tempyCordShot
        let shotLocation = tempShotLocation
        
        return(cordSetIDArray, tempGameIDArray)
    }


    func playerInfoTableLoop() {
        
        
    }
    
    func newGameTableLoop(){
        
        
    }
    
    func goalMarkerTableLoop(){
        
        
        
    }
 
    func creatCVS(){
        
        
        
    }
}
