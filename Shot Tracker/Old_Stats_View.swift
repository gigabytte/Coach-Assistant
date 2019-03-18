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

class Old_Stats_View: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
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
        newGameDataProcessing()
        // Register the table view cell class and its reuse id
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        tableView.layer.cornerRadius = 10
        tableView.delegate = self
        tableView.dataSource = self
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
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        // get new gametable objects with filktered by gameID where >=0
        homeTeamName = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "teamID == %i AND activeState == true", homeTeamID[indexPath.row])).value(forKeyPath: "nameOfTeam") as! [String]).compactMap({String($0)}).reversed()
        awayTeamName = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "teamID == %i AND activeState == true", awayTeamID[indexPath.row])).value(forKeyPath: "nameOfTeam") as! [String]).compactMap({String($0)}).reversed()
        gameType = (realm.objects(newGameTable.self).filter(NSPredicate(format: "gameID == %i AND activeState == true", Int(newGameIDs[indexPath.row])!)).value(forKeyPath: "gameType") as! [String]).compactMap({String($0)}).reversed()
        // set the text from the data model
        cell.textLabel?.text = "\n\(gameType[0]) Game, \(homeTeamName[0]) vs \(awayTeamName[0]) on date \(String(self.newGameDates[indexPath.row]))\n"
        cell.textLabel!.numberOfLines = 0;
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        passedGameID = Int(newGameIDs[indexPath.row])
        self.performSegue(withIdentifier: "oldStatsGameViewSegue", sender: nil);
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    // func used to pass varables on segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check is appropriate segue is being used
        if (segue.identifier == "oldStatsGameViewSegue"){
            // set var vc as destination segue
            let vc = segue.destination as! Old_Stats_Game_Details_Page
            vc.SeletedGame = passedGameID
        }
    }
    
}














