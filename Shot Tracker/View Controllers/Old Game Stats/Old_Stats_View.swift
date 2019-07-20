//
//  Old_Stats_View.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-01-31.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//
import UIKit
import Realm
import RealmSwift

class Old_Stats_View: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate{
    
    @IBAction func unwindToOldSats(segue: UIStoryboardSegue) {}
    @IBOutlet weak var noGameFoundLabel: UILabel!
    
    let realm = try! Realm()
    //Create variable to hold Gamelist to pick from
    // Data model: These strings will be the data for the table view cells
    var newGameIDs: [String] = [String]()
    var homeTeamID: [Int] = [Int]()
    var awayTeamID: [Int] = [Int]()
    var newGameDates: [String] = [String]()
    var homeTeamName: [String] = [String]()
    var awayTeamName: [String] = [String]()
    var gameType: [String] = [String]()
    var passedGameID: Int!
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
    // don't forget to hook this up from the storyboard
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder() // To get shake gesture
        
        newGameDataProcessing()
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        tableView.layer.cornerRadius = 10
        tableView.delegate = self
        tableView.dataSource = self
        
        if newGameDates.isEmpty == true{
            print("No Game Found on Load")
            noGameFoundLabel.isHidden = false
        }else{
            noGameFoundLabel.isHidden = true
        }
        
    }
    
    // We are willing to become first responder to get shake motion
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    // Enable detection of shake motion
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            /* let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
             let newViewController = storyBoard.instantiateViewController(withIdentifier: "Help_View_Controller") as! Help_Guide_View_Controller
             self.present(newViewController, animated: true, completion: nil)*/
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let popupVC = storyboard.instantiateViewController(withIdentifier: "Help_View_Controller") as! Help_Guide_View_Controller
            popupVC.modalPresentationStyle = .overCurrentContext
            popupVC.modalTransitionStyle = .crossDissolve
            let pVC = popupVC.popoverPresentationController
            pVC?.permittedArrowDirections = .any
            pVC?.delegate = self
            
            present(popupVC, animated: true, completion: nil)
            print("Help Guide Presented!")
        }
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        //presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "Back_To_Home", sender: self)
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
        print(homeTeamID)
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
        print(newGameDates)
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newGameIDs.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:UITableViewCell = (self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell?)!
        // get new gametable objects with filktered by gameID where >=0
        homeTeamName = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "teamID == %i AND activeState == true", homeTeamID[indexPath.row])).value(forKeyPath: "nameOfTeam") as! [String]).compactMap({String($0)}).reversed()
        awayTeamName = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "teamID == %i AND activeState == true", awayTeamID[indexPath.row])).value(forKeyPath: "nameOfTeam") as! [String]).compactMap({String($0)}).reversed()
        gameType = (realm.objects(newGameTable.self).filter(NSPredicate(format: "gameID == %i AND activeState == true", Int(newGameIDs[indexPath.row])!)).value(forKeyPath: "gameType") as! [String]).compactMap({String($0)}).reversed()
        
        let homeTeamScore = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND activeState == true", newGameIDs[indexPath.row], homeTeamID[indexPath.row])).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        
        let awayTeamScore = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND activeState == true", newGameIDs[indexPath.row], awayTeamID[indexPath.row])).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        
        // set the text from the data model
        cell.textLabel?.text = "\n\(gameType[0]) Game, \(homeTeamName[0]) vs \(awayTeamName[0]) on date \(String(self.newGameDates[indexPath.row])), \(homeTeamScore) - \(awayTeamScore)\n"
        cell.textLabel!.numberOfLines = 0;
        cell.textLabel?.textAlignment = .center
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        UserDefaults.standard.set(Int(newGameIDs[indexPath.row]), forKey: "gameID")
        UserDefaults.standard.set(Int(homeTeamID[indexPath.row]), forKey: "homeTeam")
        UserDefaults.standard.set(Int(awayTeamID[indexPath.row]), forKey: "awayTeam")
        UserDefaults.standard.set(true, forKey: "oldStatsBool")
        self.performSegue(withIdentifier: "segueToOldSatsGameView", sender: nil);
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation

    
}














