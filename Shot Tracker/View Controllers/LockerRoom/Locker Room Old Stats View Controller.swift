//
//  Locker Room Old Stats View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-08-19.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import RealmSwift

class Locker_Room_Old_Stats_View_Controller: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var noGameFoundLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let realm = try! Realm()
    //Create variable to hold Gamelist to pick from
    // Data model: These strings will be the data for the table view cells
    var newGameIDs: [String] = [String]()
    var homeTeamID: [Int] = [Int]()
    var awayTeamID: [Int] = [Int]()
    var newGameDates: [String] = [String]()
    var passedGameID: Int!
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder() // To get shake gesture
        
        NotificationCenter.default.addObserver(self, selector: #selector(myMethod(notification:)), name: NSNotification.Name(rawValue: "homePageRefresh"), object: nil)
        
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
       onLoad()
        
    }
    
    // We are willing to become first responder to get shake motion
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        //presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "Back_To_Home", sender: self)
    }
    
    func onLoad(){
    
        newGameDataProcessing()
        
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 10
        tableView.delegate = self
        tableView.dataSource = self
        
        if newGameDates.isEmpty == true{
            
            noGameFoundLabel.isHidden = false
        }else{
            noGameFoundLabel.isHidden = true
        }
        
        viewColour()
    }
    
    func viewColour(){
        
        tableView.backgroundColor = systemColour().tableViewColor()
        tableView.tableFooterView = UIView()
    }
    
    func newGameDataProcessing() {
        
        
        // get new gametable objects with filktered by gameID where >=0
        let newGameTableData = realm.objects(newGameTable.self).filter(NSPredicate(format: "gameID >= 0 AND activeGameStatus == false AND activeState == true"))
        // get object oriented array of all game ID's
        let newGameTableIDData = newGameTableData.value(forKeyPath: "gameID") as! [Int]
        // append all ID's to array but porcessing in terms of strings
        newGameIDs = newGameTableIDData.compactMap({String($0)})
        // get new gametable ID's based on anything 0 and larger
        let newGameTableDateData = newGameTableData.value(forKeyPath: "dateGamePlayed") as! [Date]
        homeTeamID =  (realm.objects(newGameTable.self).filter(NSPredicate(format: "gameID >= %i AND activeGameStatus == false AND activeState == true", 0)).value(forKeyPath: "homeTeamID") as! [Int]).compactMap({Int($0)})
        awayTeamID =  (realm.objects(newGameTable.self).filter(NSPredicate(format: "gameID >= %i AND activeGameStatus == false AND activeState == true", 0)).value(forKeyPath: "opposingTeamID") as! [Int]).compactMap({Int($0)})
        // convert dates array type to string array type
        for date in newGameTableDateData{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            // append new string type array element to newGameData array
            newGameDates.append(dateFormatter.string(from: date))
        }
        newGameDates.reverse()
        newGameIDs.reverse()
       
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newGameIDs.count
    }
    
    @objc func myMethod(notification: NSNotification){
        newGameIDs.removeAll()
        homeTeamID.removeAll()
        awayTeamID.removeAll()
        newGameDates.removeAll()
        onLoad()
        
        tableView.reloadData()
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var homeTeamName: String = ""
        var awayTeamName: String = ""
        var gameType: String = ""
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = (self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell?)!
        // get new gametable objects with filktered by gameID where >=0
        if let homeTeamNameQuery = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "teamID == %i", homeTeamID[indexPath.row])).value(forKeyPath: "nameOfTeam") as! [String]).compactMap({String($0)}).first{
            if homeTeamNameQuery != ""{
                homeTeamName = homeTeamNameQuery
            }else{
                homeTeamName = "Unknow"
            }
        }
        if let awayTeamNameQuery = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "teamID == %i", awayTeamID[indexPath.row])).value(forKeyPath: "nameOfTeam") as! [String]).compactMap({String($0)}).first{
            if awayTeamNameQuery != ""{
                 awayTeamName = awayTeamNameQuery
            }else{
                awayTeamName = "Unknown"
            }
        }
        if let gameTypeQuery = (realm.objects(newGameTable.self).filter(NSPredicate(format: "gameID == %i AND activeState == true", Int(newGameIDs[indexPath.row])!)).value(forKeyPath: "gameType") as! [String]).compactMap({String($0)}).first{
            if gameTypeQuery != ""{
                gameType = gameTypeQuery
            }else{
                gameType = "Unknown"
            }
        }
        
        let homeTeamScore = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND activeState == true", Int(newGameIDs[indexPath.row])!, homeTeamID[indexPath.row])).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        
        let awayTeamScore = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND activeState == true", Int(newGameIDs[indexPath.row])!, awayTeamID[indexPath.row])).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        
        // set the text from the data model
        cell.textLabel?.text = "\n\(gameType) Game, \(homeTeamName) vs \(awayTeamName) on date \(String(self.newGameDates[indexPath.row])), \(homeTeamScore) - \(awayTeamScore)\n"
        cell.textLabel!.numberOfLines = 0;
        cell.textLabel?.textAlignment = .center
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        UserDefaults.standard.set(Int(newGameIDs[indexPath.row]), forKey: "gameID")
        UserDefaults.standard.set(Int(homeTeamID[indexPath.row]), forKey: "homeTeam")
        UserDefaults.standard.set(Int(awayTeamID[indexPath.row]), forKey: "awayTeam")
        UserDefaults.standard.set(true, forKey: "oldStatsBool")
        self.performSegue(withIdentifier: "segueToOldSatsGameView", sender: nil);
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation
    
    
}
