//
//  Settings Assign Players View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-09-03.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import RealmSwift
import  Realm

class Settings_Assign_Players_View_Controller: UIViewController, UITableViewDelegate, UITableViewDataSource,  UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var assignPlayersToTeamButton: UIButton!
    @IBOutlet weak var playersTableView: UITableView!
    @IBOutlet weak var teamPickerView: UIPickerView!
    @IBOutlet weak var popUpView: UIView!
    
    var teamIDArray: [Int] = [Int]()
    var teamNameArray: [String] = [String]()
    var playerIDArray: [Int] = [Int]()
    var playerNameArray: [String] = [String]()
    var playerJerseyNumArray: [Int] = [Int]()
    var playerLineTypeArray: [String] = [String]()
    var playerLineNumArray: [Int] = [Int]()
    var selecteTableViewIndexArray: [Int] = [Int]()
    
    var selectedTeamID: Int!
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // give background blur effect
        // add blur effect to view along with popUpView
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.addSubview(popUpView)
        
        playersTableView.dataSource = self
        playersTableView.delegate = self
        
        teamPickerView.delegate = self
        teamPickerView.dataSource = self
        
        onLoad()
     
    }
    
    func onLoad(){
        
        let realm = try! Realm()
        
        teamIDArray = ((realm.objects(teamInfoTable.self).value(forKeyPath: "teamID") as! [Int]).compactMap({Int($0)}))
        selectedTeamID = teamIDArray.first
        
        for ID in teamIDArray{
            let teamObjc = realm.object(ofType: teamInfoTable.self, forPrimaryKey: ID)
            
            teamNameArray.append(teamObjc!.nameOfTeam)
        }
        
        viewColour()
    }
    
    func viewColour(){
        
        popUpView.backgroundColor = systemColour().viewColor()
        popUpView.layer.cornerRadius = 10
        roundedCorners().tableViewTopLeftRight(tableviewType: playersTableView)
        roundedCorners().buttonBottomDouble(bottonViewType: assignPlayersToTeamButton)
    }
    
    func genRealmPrimaryID() -> Int{
        
        let realm = try! Realm()
        
        if (realm.objects(playerInfoTable.self).max(ofProperty: "playerID") as Int? != nil){
            return (realm.objects(playerInfoTable.self).max(ofProperty: "playerID") as Int? ?? 0) + 1;
        }else{
            return (realm.objects(playerInfoTable.self).max(ofProperty: "playerID") as Int? ?? 0);
        }
    }
    
    
    func fatalErroMSG(_ msg: String){
        
        let errorAlert = UIAlertController(title: localizedString().localized(value:"Whoops!"), message: localizedString().localized(value:"\(msg)"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(errorAlert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func closeButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "deleteOldValues"), object: nil, userInfo: ["state":"any"])
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func assignPlayersButton(_ sender: UIButton) {
        
        let realm = try! Realm()
        if assignPlayersToTeamButton.alpha == 1.0{
        
            for tableViewIndex in selecteTableViewIndexArray.reversed(){
                
                let newPlayer = playerInfoTable()
                
                newPlayer.playerID = genRealmPrimaryID()
                
                try! realm.write{
                    
                    newPlayer.playerName = playerNameArray[tableViewIndex]
                    newPlayer.jerseyNum = playerJerseyNumArray[tableViewIndex]
                    newPlayer.lineNum = playerLineNumArray[tableViewIndex]
                    newPlayer.positionType = playerLineTypeArray[tableViewIndex]
                    newPlayer.TeamID = String(selectedTeamID)
                    realm.add(newPlayer, update: true)
                }
               
                
            }
            // delete all effected values from arrays
            playerNameArray = playerNameArray
                .enumerated()
                .filter { !selecteTableViewIndexArray.contains($0.offset) }
                .map { $0.element }
            playerJerseyNumArray = playerJerseyNumArray
                .enumerated()
                .filter { !selecteTableViewIndexArray.contains($0.offset) }
                .map { $0.element }
            playerLineNumArray = playerLineNumArray
                .enumerated()
                .filter { !selecteTableViewIndexArray.contains($0.offset) }
                .map { $0.element }
            playerLineTypeArray = playerLineTypeArray
                .enumerated()
                .filter { !selecteTableViewIndexArray.contains($0.offset) }
                .map { $0.element }
            
            // remove all effected cells from tableview
            DispatchQueue.main.async {
                self.playersTableView.reloadData()
            }
            selecteTableViewIndexArray.removeAll()
            
            if playerNameArray.isEmpty == true{
                assignPlayersToTeamButton.alpha = 0.3
                
            }
        }else{
            fatalErroMSG("All players have been sorted please close popup")
        }
        
        print("Assigning Players")
    }
    // --------------------------- picker view stuffssss -----------------------------------------------
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       return teamIDArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return teamNameArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedTeamID = teamIDArray[row]
    }
    // -----------------------------------------------------------------------------
    // ------------------------------ table view stufffsssss ----------------------------------------
    // Returns count of items in tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return playerNameArray.count
        
    }
    //Assign values for tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell:customPlayerImportCell = self.playersTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! customPlayerImportCell
        
        cell.playerNameLabel.text = playerNameArray[indexPath.row]
        cell.playerJerseyNumLabel.text = "#\(playerJerseyNumArray[indexPath.row])"
        
        return cell
    }
    
    // Select item from tableView
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if playersTableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCell.AccessoryType.checkmark{
             playersTableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
            playersTableView.deselectRow(at: indexPath, animated: true)
           
            selecteTableViewIndexArray.removeAll{$0 == indexPath.row}
            
        }else{
            playersTableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
            selecteTableViewIndexArray.append(indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // ---------------------------------------------------------------------------------------------------------
}
