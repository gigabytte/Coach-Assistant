//
//  Player Stats View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-08-19.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import RealmSwift

class Locker_Room_Player_Stats_View_Controller: UIViewController, UIPopoverPresentationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var playerInfoTableView: UITableView!
    @IBOutlet weak var teamLogoImageView: UIImageView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var seasonNumberLabel: UILabel!
    @IBOutlet weak var teamSeasonRecordLabel: UILabel!
    @IBOutlet weak var teamInfoAreaView: UIView!
    
    var selectedTeamID: Int!
    var gameIDArray: [Int] = [Int]()
    var teamStatsAvgArray: [[Int]] = [[], [], [], [], [],[]]
    var teamStatsArray: [String] = [String]()
    var homePlayerIDs: [Int] = [Int]()
    var homePlayerNames: [String] = [String]()
    var homePlayerNumber: [Int] = [Int]()
    var homePlayerPosition: [String] = [String]()
    var homePlayerBool: [Bool] = [Bool]()
    
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(myMethod(notification:)), name: NSNotification.Name(rawValue: "homePageRefresh"), object: nil)
        
        playerInfoTableView.dataSource = self
        playerInfoTableView.delegate = self
        
        onLoad()
        // Do any additional setup after loading the view.
    }
    
    
    
    func onLoad(){
        
        let realm = try! Realm()
        
        selectedTeamID =  UserDefaults.standard.integer(forKey: "defaultHomeTeamID")
        
        
        let teamObjc = realm.object(ofType: teamInfoTable.self, forPrimaryKey: selectedTeamID)
        
        // add tap gesture to team logo
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(teamLogoTapped(tapGestureRecognizer:)))
        teamInfoAreaView.isUserInteractionEnabled = true
        teamInfoAreaView.addGestureRecognizer(tapGestureRecognizer)
        
        
        
        recordLabelProcessing()
        playerNameInfo()
        teamInfoGrabber()
        viewColour()
    }
    
    
    
    func viewColour(){
        
        playerInfoTableView.tableFooterView = UIView()
        
        // set border around team logo and make imag
        roundedCorners().tableViewTopLeftRight(tableviewType: playerInfoTableView)
        teamLogoImageView.heightAnchor.constraint(equalToConstant: teamLogoImageView.frame.height).isActive = true
        teamLogoImageView.setRounded()

    }
    
    func teamInfoGrabber(){
        let realm = try! Realm()
         let teamObjc = realm.object(ofType: teamInfoTable.self, forPrimaryKey: selectedTeamID)
        
        if let teamName = teamObjc?.nameOfTeam{
            if teamName != ""{
                teamNameLabel.text = teamName
            }else{
                teamNameLabel.text = "Unknow Team Name"
            }
        }
        
        if let teamSeason = teamObjc?.seasonYear{
            if teamSeason != 0{
                seasonNumberLabel.text = String(teamSeason)
            }else{
                seasonNumberLabel.text = "2020"
            }
        }
        
        
        if let URL = teamObjc?.teamLogoURL{
            if URL != ""{
                let readerResult = imageReader(fileName: ("\((teamObjc?.nameOfTeam)!)_ID_\((teamObjc?.teamID)!)_team_logo"))
                teamLogoImageView.image = readerResult
            }
        }
        
        
        
    }
    
    func recordLabelProcessing(){
        
        let realm = try! Realm()
    
        let homeTeamWinCount = (realm.objects(newGameTable.self).filter(NSPredicate(format: "tieGameBool == false AND winingTeamID == %i AND activeState == true AND activeGameStatus == false", selectedTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)}).count
        let homeTeamTieCount =  (realm.objects(newGameTable.self).filter(NSPredicate(format: "tieGameBool == true AND homeTeamID == %i AND activeState == true AND activeGameStatus == false", selectedTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)}).count
        let homeTeamLooseCount =  (realm.objects(newGameTable.self).filter(NSPredicate(format: "tieGameBool == false AND losingTeamID == %i AND activeState == true AND activeGameStatus == false", selectedTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)}).count
        
        teamSeasonRecordLabel.text = "W:\(String(homeTeamWinCount))-L:\(String(homeTeamLooseCount))-T:\(String(homeTeamTieCount))"
    }
    
    func openTeamAbout(){
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let popupVC = storyboard.instantiateViewController(withIdentifier: "Team_About_Popup_View_Controller") as! Team_About_Popup_View_Controller
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = .crossDissolve
        let pVC = popupVC.popoverPresentationController
        pVC?.permittedArrowDirections = .any
        pVC?.delegate = self
        
        present(popupVC, animated: true, completion: nil)
        print("Team About Presented!")
    }
    
    func openPlayerAbout(playerID: Int){
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let popupVC = storyboard.instantiateViewController(withIdentifier: "Player_About_Popup_View_Controller") as! Player_About_Popup_View_Controller
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = .crossDissolve
        let pVC = popupVC.popoverPresentationController
        pVC?.permittedArrowDirections = .any
        pVC?.delegate = self
        
        
        popupVC.passedPlayerID = playerID
        
        present(popupVC, animated: true, completion: nil)
        print("Team About Presented!")
    }
    
    func imageReader(fileName: String) -> UIImage{
        
        var retreivedImage: UIImage!
        
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let URLs = dir.appendingPathComponent("TeamLogo")
            let newURL = URLs.appendingPathComponent(fileName)
            
            do {
                let readData = try Data(contentsOf: newURL)
                retreivedImage = UIImage(data: readData)
                
            } catch {
                print("Team logo read error")
               
            }
        }
        if retreivedImage != nil{
            return(retreivedImage)
        }else{
            print("hi")
            return(UIImage(named: "temp_profile_pic_icon")!)
        }
    }
    
    func playerImageReader(fileName: String) -> UIImage{
        
        var retreivedImage: UIImage!
        
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let URLs = dir.appendingPathComponent("PlayerImages")
            let newURL = URLs.appendingPathComponent(fileName)
            
            do {
                let readData = try Data(contentsOf: newURL)
                retreivedImage = UIImage(data: readData)
                
            } catch {
                print("Player logo read error")
            }
        }
        if retreivedImage != nil{
            return(retreivedImage)
        }else{
            
            return(UIImage(named: "temp_profile_pic_icon")!)
        }
    }
    
    func fatalErrorAlert(_ msg: String){
        
        let errorAlert = UIAlertController(title: localizedString().localized(value:"Whoops!"), message: localizedString().localized(value:"\(msg)"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(errorAlert, animated: true, completion: nil)
        
    }
    
    func playerNameInfo(){
        
        let realm = try! Realm()
        
        homePlayerIDs = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@", String(selectedTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        homePlayerBool = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@", String(selectedTeamID))).value(forKeyPath: "activeState") as! [Bool]).compactMap({Bool($0)})
        
        if (homePlayerIDs.isEmpty != true){
            for x in 0..<homePlayerIDs.count{
                
                let queryPlayerName = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %ie", homePlayerIDs[x])).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)})).first
                let queryPlayerNumber = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i", homePlayerIDs[x])).value(forKeyPath: "jerseyNum") as! [Int]).compactMap({Int($0)})).first
                let queryPlayerPosition = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i", homePlayerIDs[x])).value(forKeyPath: "positionType") as! [String]).compactMap({String($0)})).first
                
                homePlayerNames.append(queryPlayerName!)
                homePlayerNumber.append(queryPlayerNumber!)
                homePlayerPosition.append(playerPositionConverter().realmInpuToString(rawInput: queryPlayerPosition!))
            }
        }else{
            homePlayerNames[0] = "No Players Found"
            
        }
        
    }
    
    
    func teamStatsProcessing(){
        
        let realm = try! Realm()
        
        gameIDArray = ((realm.objects(newGameTable.self).filter(NSPredicate(format: "homeTeamID == %i OR opposingTeamID == %i AND activeState == true", selectedTeamID, selectedTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)}))
        
        for x in 0..<gameIDArray.count{
            
            // --------------------- GFA (Goals FOr home team) -----------------------------------
            let goalsFor = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND activeState == true", gameIDArray[x], selectedTeamID)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)})).count
            teamStatsAvgArray[0].append(goalsFor)
            
            // -------------------- SFA (Shots for home team) ------------------------------------
            let shotsFor =  ((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND activeState == true", gameIDArray[x], selectedTeamID)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)})).count
            teamStatsAvgArray[1].append(shotsFor)
            // --------------------  GAA (Goals against for home team) -------------------------------
            let goalsAgainst = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID != %i AND activeState == true", gameIDArray[x], selectedTeamID)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)})).count
            teamStatsAvgArray[2].append(goalsAgainst)
            // --------------------  SAA (Shots against for home team) -------------------------------
            let shotsAgainst = ((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID != %i AND activeState == true", gameIDArray[x], selectedTeamID)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)})).count
            teamStatsAvgArray[3].append(shotsAgainst)
            // ------------------- PPGA (Power Power Play Goals for home team) ------------------------
            let powerPlayGoals = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND powerPlay == true AND activeState == true", gameIDArray[x], selectedTeamID)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)})).count
            teamStatsAvgArray[4].append(powerPlayGoals)
            
            // ------------------- PPP (Power Power Play Goals for home team) ------------------------
            let numPowerPlays = ((realm.objects(penaltyTable.self).filter(NSPredicate(format: "gameID == %i AND teamID != %i AND activeState == true", gameIDArray[x], selectedTeamID)).value(forKeyPath: "penaltyID") as! [Int]).compactMap({Int($0)})).count
            
            let powerPlayPer = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND powerPlay == true AND activeState == true", gameIDArray[x], selectedTeamID)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)})).count
            if (powerPlayPer != 0){
                let powerPlayAVG = numPowerPlays / powerPlayPer
                teamStatsAvgArray[5].append(powerPlayAVG)
            }else{
                teamStatsAvgArray[5].append(0)
            }
            
            
        }
        // computer avg based on data set in 2d teamStatsAvgArray arrary
        // PPP STATS GEN
        let pppAVG = teamStatsAvgArray[5].reduce(.zero, +)
        if pppAVG != 0 {
            teamStatsArray.append("PPP: " + String(pppAVG / teamStatsAvgArray[5].count) + "%")
        }else{
            teamStatsArray.append("PPP: 0%")
        }
        // PPGA STATS GEN
        let ppgaAVG = teamStatsAvgArray[4].reduce(.zero, +)
        if ppgaAVG != 0{
            teamStatsArray.append("PPGA: " + String(ppgaAVG / teamStatsAvgArray[4].count) + "%")
        }else{
            teamStatsArray.append("PPGA: 0%")
        }
        // GFA STATS GEN
        let gfaAVG = teamStatsAvgArray[0].reduce(.zero, +)
        if gfaAVG != 0{
            teamStatsArray.append("GFA: " + String(gfaAVG / teamStatsAvgArray[0].count) + "%")
        }else{
            teamStatsArray.append("GFA: 0%")
        }
        // SFA STATS GEN
        let sfaAVG = teamStatsAvgArray[1].reduce(.zero, +)
        if sfaAVG != 0{
            teamStatsArray.append("SFA: " + String(sfaAVG / teamStatsAvgArray[1].count) + "%")
        }else{
            teamStatsArray.append("SFA: 0%")
        }
        // GAA STATS GEN
        let gaaAVG = teamStatsAvgArray[2].reduce(.zero, +)
        if gaaAVG != 0{
            teamStatsArray.append("GAA: " + String(gaaAVG / teamStatsAvgArray[2].count) + "%")
        }else{
            teamStatsArray.append("GAA: 0%")
        }
        // SAA STATS GEN
        let saaAVG = teamStatsAvgArray[3].reduce(.zero, +)
        if saaAVG != 0{
            teamStatsArray.append("SAA: " + String(saaAVG / teamStatsAvgArray[3].count) + "%")
        }else{
            teamStatsArray.append("SAA: 0%")
        }
        
        
    }
    
    
    @objc func myMethod(notification: NSNotification){
        homePlayerNames.removeAll()
        homePlayerIDs.removeAll()
        homePlayerNumber.removeAll()
        homePlayerPosition.removeAll()
        
        selectedTeamID =  UserDefaults.standard.integer(forKey: "defaultHomeTeamID")
        
        playerNameInfo()
        teamInfoGrabber()
       
        DispatchQueue.main.async {
            self.playerInfoTableView.reloadData()
          
        }
        
    }
    
    
    @objc func teamLogoTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        print("Opening Home Team About")
        openTeamAbout()
        
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        if (tableView == playerInfoTableView){
            
            return("Player Profiles")
        }
         return("Player Profiles")
    }
    // Returns count of items in tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableView == playerInfoTableView){
            return(homePlayerIDs.count)
        }
         return(homePlayerIDs.count)
    }
    //Assign values for tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var count: Int = 0
        
        let cell:customLockerRoomStatsCell = self.playerInfoTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! customLockerRoomStatsCell
        
       if (tableView == playerInfoTableView){
        
            cell.playerNameLabel!.text = homePlayerNames[indexPath.row]
            cell.playerPositionLabel?.text = homePlayerPosition[indexPath.row]
            cell.playerNumberLabel?.text = " #\(homePlayerNumber[indexPath.row])"
            
            if homePlayerBool[indexPath.row] == false{
                cell.deletedPlayerIcon.isHidden = false
            }
           //cell.playerProfileImage.layer.masksToBounds = true
            let readerResult = playerImageReader(fileName: ("\(homePlayerNames[indexPath.row])_ID_\(homePlayerIDs[indexPath.row])_player_logo"))
            if readerResult != nil{
                cell.playerProfileImage.image = readerResult
               
            }
        
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        openPlayerAbout(playerID: homePlayerIDs[indexPath.row])
    }
    

}

extension UIImageView {
    
    func setRounded() {
       
        self.layer.borderWidth = 3
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = CGFloat(roundf(Float(self.frame.size.width / 2.0)))
    }
}
