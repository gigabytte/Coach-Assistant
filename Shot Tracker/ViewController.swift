//
//  ViewController.swift  Main Dashboard
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-01-10.
//  Copyright © 2019 MAG Industries. All rights reserved.
//
import UIKit
import RealmSwift
import Realm

class ViewController: UIViewController {
    
    let realm = try! Realm()
    var activeStatus: Bool!
    @IBOutlet weak var newGameButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // get rotation allowances of device
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // set auto rotation to true for current view
        appDelegate.shouldRotate = true
        
        delay(0.5){
            self.onGoingGame()
        }
        
        /*----------------------------------------------------------------
         uncomment code block if changes to DB tables are made or merger error is stated,
         build app then comment code again and build app like normal*/
        //let defaultPath = Realm.Configuration.defaultConfiguration.fileURL?.path
        //try! FileManager.default.removeItem(atPath: defaultPath!)
        /*________________________________________________________________*/
        
        // get Realm Databse file location
        print(Realm.Configuration.defaultConfiguration.fileURL)

    }
    
    func onGoingGame(){
        if((realm.objects(newGameTable.self).filter(NSPredicate(format: "gameID >= %i AND activeState == %@", 0, NSNumber(value: true))).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)}).first != nil){
        // get lastest new game active status
            activeStatus = (self.realm.object(ofType: newGameTable.self, forPrimaryKey: self.realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.activeGameStatus)!
        
            if (activeStatus == true){
                newGameButton.setTitle("Ongoing Game", for: .normal)
            }
        }else{
            print("No New Game Data Yet")
            
        }
    }
    
    func goalieChecker() -> Bool{
        
        let goalieOne = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID >= %i AND positionType == %@ AND activeState == %@", 0, "G" , NSNumber(value: true))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        let goalieTwo = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID >= %i AND positionType == %@ AND activeState == %@", 0, "G" , NSNumber(value: true))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        
        if (goalieOne.first != nil && goalieOne.first != goalieTwo.last){
            
            return true
        }else{
            return false
        }
    }
    func playerChecker() -> Bool{
        
        let playerOne = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID >= %i AND positionType != %@ AND activeState == %@", 0, "G" , NSNumber(value: true))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        let playerTwo = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID >= %i AND positionType != %@ AND activeState == %@", 0, "G" , NSNumber(value: true))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        if (playerOne.first != nil && playerOne.first != playerTwo.last){
            
            return true
        }else{
            return false
        }
        
    }
    
    func teamChecker() -> Bool{
        
        // get first an last team entered in DB
        let teamOne = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "teamID >= %i AND activeState == %@", 0, NSNumber(value: true))).value(forKeyPath: "teamID") as! [Int]).compactMap({Int($0)})
        let teamTwo = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "teamID >= %i AND activeState == %@", 0, NSNumber(value: true))).value(forKeyPath: "teamID") as! [Int]).compactMap({Int($0)})
        if (teamOne.first != nil && teamOne.first != teamTwo.last){
            
            return true
        }else{
            return false
        }
    }
    
    @IBAction func newGameButton(_ sender: UIButton) {
   
        // check if team one returns nil and that team one isnt team two
        // check for only one team entered and or no team entered
        if (activeStatus != true){
            if(goalieChecker() == true && playerChecker() == true && teamChecker() == true){
                self.performSegue(withIdentifier: "newGameButtonSegue", sender: nil);
                
            }else{
                // if teams or players are not avaiable top be pulled alert error appears
                dataReturnNilAlert()
            }
        }else{
            if(goalieChecker() == true && playerChecker() == true && teamChecker() == true){
                self.performSegue(withIdentifier: "skipTeamSelectionSegue", sender: nil);
            }else{
                // if teams or players are not avaiable top be pulled alert error appears
                dataReturnNilAlert()
            }
        }
    }
    // if teams or players are not avaiable top be pulled alert error appears
    func dataReturnNilAlert(){
        
        // create the alert
        let nilAlert = UIAlertController(title: "Data Error", message: "Please add atleast two teams, one player and one goalie for each corresponding team.", preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        nilAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(nilAlert, animated: true, completion: nil)
        
    }
    // func used to pass varables on segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check is appropriate segue is being used
        if (segue.identifier == "skipTeamSelectionSegue"){
            // set var vc as destination segue
            let vc = segue.destination as! New_Game_Page
            vc.newGameStarted = true
            vc.homeTeam =  self.realm.object(ofType: newGameTable.self, forPrimaryKey: self.realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.homeTeamID
            vc.awayTeam =  self.realm.object(ofType: newGameTable.self, forPrimaryKey: self.realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.opposingTeamID
            
        }
    }
    
    // delay loop
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}
