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

class Home_Page_View_Controller: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var oldStatsButton: UIButton!
    @IBOutlet weak var addTeamPlayerButton: UIButton!
    @IBOutlet weak var editTeamPlayerButton: UIButton!
    
    
    let realm = try! Realm()
    // active status bool used to check if a game is ongoing
    var activeStatus: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder() // To get shake gesture
        
        
        // Do any additional setup after loading the view, typically from a nib.
        // check is usr has selected a a deafult team yet
        if(((realm.objects(teamInfoTable.self).filter(NSPredicate(format: "activeState == %@", NSNumber(value: true))).value(forKeyPath: "teamID") as! [Int]).compactMap({String($0)})).count != 0){
            // check if deafult team has been selected on load
            if ((UserDefaults.standard.object(forKey: "defaultHomeTeamID")) == nil){
                  delay(0.5){
                    self.performSegue(withIdentifier: "defaultTeamSelection", sender: nil);
                }
                }else{
                    print("Default Home Team ID: \(UserDefaults.standard.object(forKey: "defaultHomeTeamID") as! Int)")
            }
        }else{
            // if no default team has been selected on load and no teams present
            // redirect to team add team page VC
            delay(0.5){
                print("No Teams Found on Start")
                self.performSegue(withIdentifier: "addTeamSegueFromMain", sender: nil);
            }
        }
        // run on going game funtion to dynamically chnage new game button text based on
        // game status
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
    
    // cherck is game if currently running function
    func onGoingGame(){
        // based on activeStaus bool the New Game Button text chnages dynamically
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
    // func checks if there is atleast one goalie from each team to prevent new game errors; returns bool
    func goalieChecker() -> Bool{
        
        let goalieOne = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID >= %i AND positionType == %@ AND activeState == %@", 0, "G" , NSNumber(value: true))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        let goalieTwo = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID >= %i AND positionType == %@ AND activeState == %@", 0, "G" , NSNumber(value: true))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        
        if (goalieOne.first != nil && goalieOne.first != goalieTwo.last){
            
            return true
        }else{
            return false
        }
    }
    
    // func checks if there is atleast one player from each team to prevent new game errors; returns bool
    func playerChecker() -> Bool{
        
        let playerOne = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID >= %i AND positionType != %@ AND activeState == %@", 0, "G" , NSNumber(value: true))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        let playerTwo = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID >= %i AND positionType != %@ AND activeState == %@", 0, "G" , NSNumber(value: true))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        if (playerOne.first != nil && playerOne.first != playerTwo.last){
            
            return true
        }else{
            return false
        }
        
    }
    
    // func checks if there is atleast two teams prevent new game errors; returns bool
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
    @IBAction func editTeamButton(_ sender: UIButton) {
        if(goalieChecker() == true && playerChecker() == true && teamChecker() == true){
            self.performSegue(withIdentifier: "editTeamPlayerSegue", sender: nil);
            
        }else{
            // if teams or players are not avaiable top be pulled alert error appears
            dataReturnNilAlert()
        }
    }
    
    @IBAction func newGameButton(_ sender: UIButton) {
       
            // check if team one returns nil and that team one isnt team two
            // check for only one team entered and or no team entered
            if (activeStatus != true){
                if(goalieChecker() == true && playerChecker() == true && teamChecker() == true){
                    UserDefaults.standard.set(true, forKey: "newGameStarted")
                    self.performSegue(withIdentifier: "newGameButtonSegue", sender: nil);
                    
                }else{
                    // if teams or players are not avaiable top be pulled alert error appears
                    dataReturnNilAlert()
                }
            }else{
                // check if user has chnaged the default team while a game is ongoing or if this a new game all together
                if ((UserDefaults.standard.object(forKey: "defaultHomeTeamID") as! Int) == (realm.object(ofType: teamInfoTable.self, forPrimaryKey: realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.homeTeamID))?.teamID || (realm.object(ofType: newGameTable.self, forPrimaryKey: (self.realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?))?.activeGameStatus) == false){
                    if(goalieChecker() == true && playerChecker() == true && teamChecker() == true){
                        let tempHomeTeamID  = (self.realm.object(ofType: newGameTable.self, forPrimaryKey: self.realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.homeTeamID)!
                        let tempAwayTeamID  = (self.realm.object(ofType: newGameTable.self, forPrimaryKey: self.realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.opposingTeamID)!
                        UserDefaults.standard.set(tempHomeTeamID, forKey: "homeTeam")
                        UserDefaults.standard.set(tempAwayTeamID, forKey: "awayTeam")
                        UserDefaults.standard.set(true, forKey: "newGameStarted")
                        self.performSegue(withIdentifier: "skipTeamSelectionSegue", sender: nil);
                    }else{
                        // if teams or players are not avaiable top be pulled alert error appears
                        dataReturnNilAlert()
                    }
                }else{
                    // present a alert controller if default team has been chnaged while a game is ongoing
                    // create the alert
                    let misMatchedDefault = UIAlertController(title: "Deactive Default Team", message: "Your default team has been deactivated, please re-activate your orginal default team or close this game", preferredStyle: UIAlertController.Style.alert)
                    // add an action (button)
                    misMatchedDefault.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    // add an action (button)
                    misMatchedDefault.addAction(UIAlertAction(title: "Close Game", style: UIAlertAction.Style.destructive, handler: { action in
                        // set current game to not active
                        try! self.realm.write{
                            self.realm.object(ofType: newGameTable.self, forPrimaryKey: (self.realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?))?.activeGameStatus = false
                        }
                        // change defaults based on user selection to close game
                        self.newGameButton.setTitle("New Game", for: .normal)
                        self.activeStatus = false
                    }))
                    // show the alert
                    self.present(misMatchedDefault, animated: true, completion: nil)
                    
                    print("user has changed default team and cannot procceed with current on going game!")
            }
        }
         //self.onGoingGame()
    }
    @IBAction func oldStatsButton(_ sender: UIButton) {
        if(goalieChecker() == true && playerChecker() == true && teamChecker() == true){
            self.performSegue(withIdentifier: "oldStatsPopUpSegue", sender: nil);
            
        }else{
            // if teams or players are not avaiable top be pulled alert error appears
            dataReturnNilAlert()
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
    
    // delay loop
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}
