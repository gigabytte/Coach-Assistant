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
import StoreKit

class Home_Page_View_Controller: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var coachAssistantLogo: UIImageView!
    @IBOutlet weak var newGameConatinerView: UIView!
    @IBOutlet weak var lockerRoomContainerView: UIView!
    @IBOutlet weak var newGameView: UIView!
    @IBOutlet weak var lockerRoomView: UIView!
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var lockerRoomButton: UIButton!
    @IBAction func unwindHomePage(segue: UIStoryboardSegue) {}
    
    
    var lockerRoomViewStandardCon: NSLayoutConstraint!
    var newGameViewStandardCon: NSLayoutConstraint!
    var lockerRoomViewShrunkCon: NSLayoutConstraint!
    var newGameViewShrunkCon: NSLayoutConstraint!
    var lockerRoomViewExtendedCon: NSLayoutConstraint!
    var newGameViewExtendedCon: NSLayoutConstraint!
    var caLogoStandardCon: NSLayoutConstraint!
    var caLogoShrunkCon: NSLayoutConstraint!
    
    // active status bool used to check if a game is ongoing
    var activeStatus: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder() // To get shake gesture
        // set listener for notification after goalie is selected
        NotificationCenter.default.addObserver(self, selector: #selector(myMethod(notification:)), name: NSNotification.Name(rawValue: "homePageRefresh"), object: nil)
        
        onLoad()
        /*----------------------------------------------------------------
         uncomment code block if changes to DB tables are made or merger error is stated,
         build app then comment code again and build app like normal*/
        //let defaultPath = Realm.Configuration.defaultConfiguration.fileURL?.path
        //try! FileManager.default.removeItem(atPath: defaultPath!)
        /*________________________________________________________________*/
        
        // get Realm Databse file location
        print(Realm.Configuration.defaultConfiguration.fileURL!)
       
        viewContraintsGen(firstLoad: true)
        

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
    
    @objc func myMethod(notification: NSNotification){
        onLoad()
    }
    
    
    func viewContraintsGen(firstLoad: Bool){
       
        // standard view constraints both views are the same size
        newGameViewStandardCon = newGameView.widthAnchor.constraint(equalToConstant: self.view.frame.width / 2)
        lockerRoomViewStandardCon = lockerRoomView.widthAnchor.constraint(equalToConstant: self.view.frame.width / 2)
    
        // standard view constraints both views are the same size
        newGameViewExtendedCon = newGameView.widthAnchor.constraint(equalToConstant: (self.view.frame.width / 4) * 3)
        lockerRoomViewExtendedCon = lockerRoomView.widthAnchor.constraint(equalToConstant: (self.view.frame.width / 4) * 3)
        
        // standard view constraints both views are the same size
        newGameViewShrunkCon = newGameView.widthAnchor.constraint(equalToConstant: self.view.frame.width / 4)
        lockerRoomViewShrunkCon = lockerRoomView.widthAnchor.constraint(equalToConstant: self.view.frame.width / 4)
        
        
        
        if firstLoad == true{
            newGameViewStandardCon.isActive = true
            lockerRoomViewStandardCon.isActive = true
            newGameButton.tag = 10
            lockerRoomButton.tag = 10
        }

    }
    
    func onLoad(){
        
        let realm = try! Realm()
        // Do any additional setup after loading the view, typically from a nib.
        // check is usr has selected a a deafult team yet
        if(((realm.objects(teamInfoTable.self).filter(NSPredicate(format: "activeState == %@", NSNumber(value: true))).value(forKeyPath: "teamID") as! [Int]).compactMap({String($0)})).count != 0){
            // check if deafult team has been selected on load
            if ((UserDefaults.standard.object(forKey: "defaultHomeTeamID")) == nil){
                delay(0.3){
                    self.performSegue(withIdentifier: "defaultTeamSelection", sender: nil);
                }
            }else{
                
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
        
        // check the number of games the user has createrd and ask for a review
        if(((realm.objects(newGameTable.self).filter(NSPredicate(format: "activeState == %@", NSNumber(value: true))).value(forKeyPath: "gameID") as! [Int]).compactMap({String($0)})).count >= 3 && UserDefaults.standard.bool(forKey: "userReviewBool") != true) {
            
            UserDefaults.standard.set(true, forKey: "userReviewBool")
            SKStoreReviewController.requestReview()
            
        }
        
        
    }
    
    func containerIntializer(storyBoardID: String, containerView: UIView, VC: UIViewController){
       
        
        
        let controller = storyboard!.instantiateViewController(withIdentifier: storyBoardID)
        addChild(controller)
        //controller.view.translatesAutoresizingMaskIntoConstraints = true
        containerView.addSubview(controller.view)
    }
    
    // cherck is game if currently running function
    func onGoingGame(){
        let realm = try! Realm()
        // based on activeStaus bool the New Game Button text chnages dynamically
        if((realm.objects(newGameTable.self).filter(NSPredicate(format: "gameID >= %i AND activeState == %@", 0, NSNumber(value: true))).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)}).first != nil){
        // get lastest new game active status
            activeStatus = (realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.activeGameStatus)!
        
            if (activeStatus == true){
                newGameButton.setTitle(localizedString().localized(value: "Ongoing Game"), for: .normal)
                newGameButton.setNeedsLayout()
            }else{
                newGameButton.setTitle(localizedString().localized(value:"New Game"), for: .normal)
                newGameButton.setNeedsLayout()
            }
        }else{
            print("No New Game Data Yet")
        }
    }
    // func checks if there is atleast one goalie from each team to prevent new game errors; returns bool
    func goalieChecker() -> Bool{
        let realm = try! Realm()
        
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
        let realm = try! Realm()
        
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
        let realm = try! Realm()
        // get first an last team entered in DB
        let teamOne = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "teamID >= %i AND activeState == %@", 0, NSNumber(value: true))).value(forKeyPath: "teamID") as! [Int]).compactMap({Int($0)})
        let teamTwo = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "teamID >= %i AND activeState == %@", 0, NSNumber(value: true))).value(forKeyPath: "teamID") as! [Int]).compactMap({Int($0)})
        if (teamOne.first != nil && teamOne.first != teamTwo.last){
            
            return true
        }else{
            return false
        }
    }
    
    func newGameConatinerViewInializer(){
        
        newGameConatinerView.centerXAnchor.constraint(equalTo: newGameView.centerXAnchor).isActive = true
        newGameConatinerView.centerYAnchor.constraint(equalTo: newGameView.centerYAnchor).isActive = true
        
        newGameConatinerView.heightAnchor.constraint(equalTo: newGameConatinerView.widthAnchor, multiplier: 1.0/2.0).isActive = true
        
        view.addSubview(newGameConatinerView)
        
    }
    
    @IBAction func newGameButton(_ sender: UIButton) {
       
       
            
            switch self.newGameButton.tag {
            case 10:
                if (newGameRequirmentsChecker() == true){
                    self.lockerRoomButton.setTitle("Back", for: .normal)
                    self.newGameButton.setTitle("New Game", for: .normal)
                    
                    self.newGameViewExtendedCon.isActive = true
                    self.newGameViewStandardCon.isActive = false
                    self.newGameViewShrunkCon.isActive = false
                    self.lockerRoomViewStandardCon.isActive = false
                    self.lockerRoomViewExtendedCon.isActive = false
                    self.lockerRoomViewShrunkCon.isActive = true
                    
                    self.newGameConatinerView.isHidden = false
                    self.lockerRoomContainerView.isHidden = true
                    
                   
                    
                    UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                         self.newGameConatinerView.alpha = 1.0
                         self.view.layoutIfNeeded()
                    }, completion: { _ in
                        
                    })
                 
                    self.newGameButton.tag = 20
                    self.lockerRoomButton.tag = 30
                    // check is user is eligable to run a new game
                }
                break
            case 20:
                break
            default:
                self.lockerRoomButton.setTitle("LockerRoom", for: .normal)
                self.newGameButton.setTitle("New Game", for: .normal)
                
                self.newGameViewExtendedCon.isActive = false
                self.newGameViewStandardCon.isActive = true
                self.newGameViewShrunkCon.isActive = false
                self.lockerRoomViewStandardCon.isActive = true
                self.lockerRoomViewExtendedCon.isActive = false
                self.lockerRoomViewShrunkCon.isActive = false

                
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                    self.lockerRoomContainerView.alpha = 0.0
                    
                    self.view.layoutIfNeeded()
                }, completion: { _ in
                    
                    self.lockerRoomContainerView.isHidden = true
                })
                
                self.newGameButton.tag = 10
                self.lockerRoomButton.tag = 10
                break
            }
        
        
        
        
    }
    
    @IBAction func lockerRoomButton(_ sender: UIButton) {
        
        switch self.lockerRoomButton.tag {
        case 10:
            self.lockerRoomButton.setTitle("Locker Room", for: .normal)
            self.newGameButton.setTitle("Back", for: .normal)
            
            self.newGameViewExtendedCon.isActive = false
            self.newGameViewStandardCon.isActive = false
            self.newGameViewShrunkCon.isActive = true
            self.lockerRoomViewStandardCon.isActive = false
            self.lockerRoomViewExtendedCon.isActive = true
            self.lockerRoomViewShrunkCon.isActive = false
            
            self.lockerRoomContainerView.isHidden = false
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                self.view.layoutIfNeeded()
                self.newGameConatinerView.alpha = 0.0
                self.lockerRoomContainerView.alpha = 1.0
            }, completion: { _ in
                self.newGameConatinerView.isHidden = true
            })
            
            self.newGameButton.tag = 30
            self.lockerRoomButton.tag = 20
            break
        case 20:
            break
        default:
            self.lockerRoomButton.setTitle("LockerRoom", for: .normal)
            self.newGameButton.setTitle("New Game", for: .normal)
            
            self.newGameViewExtendedCon.isActive = false
            self.newGameViewStandardCon.isActive = true
            self.newGameViewShrunkCon.isActive = false
            self.lockerRoomViewStandardCon.isActive = true
            self.lockerRoomViewExtendedCon.isActive = false
            self.lockerRoomViewShrunkCon.isActive = false
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                self.newGameConatinerView.alpha = 0.0
                self.lockerRoomContainerView.alpha = 0.0
                 self.view.layoutIfNeeded()
               
            }, completion: { _ in
                
                self.newGameConatinerView.isHidden = true
                 self.lockerRoomContainerView.isHidden = true
            })
            
            //self.newGameConatinerView.isHidden = true
            
            self.newGameButton.tag = 10
            self.lockerRoomButton.tag = 10
            break
        }
        
        
    }
    
    @IBAction func editTeamButton(_ sender: UIButton) {
        if(goalieChecker() == true && playerChecker() == true && teamChecker() == true){
            
            if let mvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Edit_Team_Player_View_Controller") as? Edit_Team_Info_Page {
                self.present(mvc, animated: true, completion: nil)
            }
            
        }else{
            // if teams or players are not avaiable top be pulled alert error appears
            dataReturnNilAlert()
        }
    }
    
    func newGameRequirmentsChecker() -> Bool {
        let realm = try! Realm()
            // check if team one returns nil and that team one isnt team two
            // check for only one team entered and or no team entered
            if (activeStatus != true){
                if(goalieChecker() == true && playerChecker() == true && teamChecker() == true){
                    UserDefaults.standard.set(true, forKey: "newGameStarted")
                    // display conatiner view with new game view in it
                    
                    
                }else{
                    // if teams or players are not avaiable top be pulled alert error appears
                    dataReturnNilAlert()
                    return false
                }
            }else{
                // check if user has chnaged the default team while a game is ongoing or if this a new game all together
                if ((UserDefaults.standard.object(forKey: "defaultHomeTeamID") as! Int) == (realm.object(ofType: teamInfoTable.self, forPrimaryKey: realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.homeTeamID))?.teamID || (realm.object(ofType: newGameTable.self, forPrimaryKey: (realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?))?.activeGameStatus) == false){
                    if(goalieChecker() == true && playerChecker() == true && teamChecker() == true){
                        let tempHomeTeamID  = (realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.homeTeamID)!
                        let tempAwayTeamID  = (realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.opposingTeamID)!
                        UserDefaults.standard.set(tempHomeTeamID, forKey: "homeTeam")
                        UserDefaults.standard.set(tempAwayTeamID, forKey: "awayTeam")
                        UserDefaults.standard.set(true, forKey: "newGameStarted")
                        self.performSegue(withIdentifier: "skipTeamSelectionSegue", sender: nil);
                    }else{
                        // if teams or players are not avaiable top be pulled alert error appears
                        dataReturnNilAlert()
                        return false
                    }
                }else{
                    // present a alert controller if default team has been chnaged while a game is ongoing
                    // create the alert
                    let misMatchedDefault = UIAlertController(title: "Deactive Default Team", message: "Your default team has been deactivated, please re-activate your orginal default team or close this game", preferredStyle: UIAlertController.Style.alert)
                    // add an action (button)
                    misMatchedDefault.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    // add an action (button)
                    misMatchedDefault.addAction(UIAlertAction(title: "Close Game", style: UIAlertAction.Style.destructive, handler: { action in
                        // set current game to not active
                        try! realm.write{
                            realm.object(ofType: newGameTable.self, forPrimaryKey: (realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?))?.activeGameStatus = false
                        }
                        // change defaults based on user selection to close game
                        self.newGameButton.setTitle("New Game", for: .normal)
                        self.activeStatus = false
                    }))
                    // show the alert
                    self.present(misMatchedDefault, animated: true, completion: nil)
                    
                    print("user has changed default team and cannot procceed with current on going game!")
                    return false
            }
        }
        
        self.onGoingGame()
        return true
    }
    @IBAction func oldStatsButton(_ sender: UIButton) {
        if(goalieChecker() == true && playerChecker() == true && teamChecker() == true){
            self.performSegue(withIdentifier: "oldStatsPopUpSegue", sender: nil);
           
        }else{
            // if teams or players are not avaiable top be pulled alert error appears
            dataReturnNilAlert()
        }
        
    }
    @IBAction func settingButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "Home_To_Settings", sender: nil);
        print("Setting_View_Controller Presented!")
    }
    // if teams or players are not avaiable top be pulled alert error appears
    func dataReturnNilAlert(){
        
        // create the alert
        let nilAlert = UIAlertController(title: localizedString().localized(value:"Data Error"), message: localizedString().localized(value:"Please add atleast two teams, one player and one goalie for each corresponding team."), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        nilAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(nilAlert, animated: true, completion: nil)
        
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    // delay loop
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}
