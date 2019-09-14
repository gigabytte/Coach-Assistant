//
//  LockerRoom View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-08-19.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import RealmSwift
import StoreKit

class LockerRoom_View_Controller: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var updatedUIContainerView: UIView!
    @IBOutlet weak var newGameBarButton: UIBarButtonItem!
    @IBOutlet weak var addPlayerButton: UIButton!
    @IBOutlet weak var oldStatsButton: UIButton!
    @IBOutlet weak var statsButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBAction func unwindHomePage(segue: UIStoryboardSegue) {}
    
    var passedTeamID: Int!
    
    // active status bool used to check if a game is ongoing
    var activeStatus: Bool!
    
    var blurEffectView: UIVisualEffectView!
    
    var tutorialPageViewController: Locker_Room_UIPageController? {
        didSet {
            tutorialPageViewController?.tutorialDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector: #selector(myMethod(notification:)), name: NSNotification.Name(rawValue: "homePageRefresh"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(myUIUpdateMethod(notification:)), name: NSNotification.Name(rawValue: "dismissedUIUpdate"), object: nil)

        if checkUserDefaults().isKeyPresentInUserDefaults(key: "uiUpdateBool") == true{
            if UserDefaults.standard.bool(forKey: "uiUpdateBool") != true{
                
                delay(0.2){
                    self.presentNewUIHelpBlur()
                    self.updatedUIContainerView.isHidden = false
                }
                
            }else{
                updatedUIContainerView.removeFromSuperview()
            }
        }else{
            
            delay(0.2){
                self.presentNewUIHelpBlur()
                self.updatedUIContainerView.isHidden = false
            }
        }
        
        onLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func presentNewUIHelpBlur(){
        // give background blur effect
        // add blur effect to view along with popUpView
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.addSubview(updatedUIContainerView)
    }
    
    func shpwAddTeamVC(){
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let popupVC = storyboard.instantiateViewController(withIdentifier: "addTeamVC") as! Add_Team_Page
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = .crossDissolve
    
        popupVC.noTeamsBool = true
        
        let pVC = popupVC.popoverPresentationController
        pVC?.permittedArrowDirections = .any
        pVC?.delegate = self
        
        self.present(popupVC, animated: true, completion: nil)
        print("Add_Team_Page Presented!")
    }
    
    func checkDefaultTeam(){
        if ((UserDefaults.standard.object(forKey: "defaultHomeTeamID")) == nil){
            delay(0.3){
                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let popupVC = storyboard.instantiateViewController(withIdentifier: "Default_Team_Selection") as! Team_Selection_View
                popupVC.modalPresentationStyle = .overCurrentContext
                popupVC.modalTransitionStyle = .crossDissolve
                let pVC = popupVC.popoverPresentationController
                pVC?.permittedArrowDirections = .any
                pVC?.delegate = self
                
                self.present(popupVC, animated: true, completion: nil)
                print("Default team selection Presented!")
            }
        }
    }
    
    func onLoad(){
        
        navBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "AvenirNext-Heavy", size: 35)!]
        // get Realm Databse file location
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        // Do any additional setup after loading the view, typically from a nib.
        noTeamsChecker()
        
        viewColour()
    }
    
    func viewColour(){
        
        self.view.backgroundColor = systemColour().viewColor()
        navBar.barTintColor = systemColour().navBarColor()
        
        // set nav bar propeeties based on prameters layout
        let barView = UIView(frame: CGRect(x:0, y:0, width:view.frame.width, height:UIApplication.shared.statusBarFrame.height))
        barView.backgroundColor = navBar.barTintColor
        view.addSubview(barView)
    }
    
    func noTeamsChecker(){
        
        let realm = try! Realm()
        
        // check is usr has selected a a deafult team yet
        if(((realm.objects(teamInfoTable.self).filter(NSPredicate(format: "activeState == %@", NSNumber(value: true))).value(forKeyPath: "teamID") as! [Int]).compactMap({String($0)})).count != 0){
            // check if deafult team has been selected on load
            if ((UserDefaults.standard.object(forKey: "defaultHomeTeamID")) == nil){
                print("no teams id")
                delay(0.3){
                    self.defaultTeamSelection()
                }
            }
        }else{
            // if no default team has been selected on load and no teams present
            // redirect to team add team page VC
            delay(0.5){
                print("No Teams Found on Start")
                self.shpwAddTeamVC()
            }
        }
        // run on going game funtion to dynamically chnage new game button text based on
        // game status
        delay(0.3){
            self.onGoingGame()
        }
        
        // check the number of games the user has createrd and ask for a review
        let numberOfGamePlayed = ((realm.objects(newGameTable.self).filter(NSPredicate(format: "activeState == %@", NSNumber(value: true))).value(forKeyPath: "gameID") as! [Int]).compactMap({String($0)})).count
        if( numberOfGamePlayed >= 2 && UserDefaults.standard.bool(forKey: "userReviewBool") != true) {
            
            UserDefaults.standard.set(true, forKey: "userReviewBool")
            SKStoreReviewController.requestReview()
            
        }
    }
    
    // cherck is game if currently running function
    func onGoingGame(){
        let realm = try! Realm()
        // based on activeStaus bool the New Game Button text chnages dynamically
        if((realm.objects(newGameTable.self).filter(NSPredicate(format: "gameID >= %i AND activeState == %@", 0, NSNumber(value: true))).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)}).first != nil){
            // get lastest new game active status
            activeStatus = (realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.activeGameStatus)!
            
            if (activeStatus == true){
                // set new game button a diuffrent color based on game status
                newGameBarButton.tintColor = UIColor.red
               
            }else{
                newGameBarButton.tintColor = UIColor.black
               
            }
        }else{
            print("No New Game Data Yet")
        }
    }
    
    func newGameRequirmentsChecker() {
        let realm = try! Realm()
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
                    self.newGameBarButton.tintColor = UIColor.black
                    self.activeStatus = false
                }))
                // show the alert
                self.present(misMatchedDefault, animated: true, completion: nil)
                
                print("user has changed default team and cannot procceed with current on going game!")
            }
        }
        self.onGoingGame()
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
    
    // popup default team selection view
    func defaultTeamSelection(){
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let popupVC = storyboard.instantiateViewController(withIdentifier: "Default_Team_Selection") as! Default_Team_Selection_View
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = .crossDissolve
        let pVC = popupVC.popoverPresentationController
        pVC?.permittedArrowDirections = .any
        pVC?.delegate = self
        
        present(popupVC, animated: true, completion: nil)
        print("Changing Teams Popup Presented")
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
        noTeamsChecker()
        onGoingGame()
       // newGameRequirmentsChecker()
    }
    
    @objc func myUIUpdateMethod(notification: NSNotification){
        delay(0.3){
            self.blurEffectView.removeFromSuperview()
            self.updatedUIContainerView.removeFromSuperview()
        }
    }
    
    @IBAction func newGameButton(_ sender: UIBarButtonItem) {
        
        newGameRequirmentsChecker()
    }
    
    
    @IBAction func statsButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "menuBtnPress"), object: nil, userInfo: ["btnNumber":0])
        
    }
    @IBAction func oldStatsButtton(_ sender: UIButton) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "menuBtnPress"), object: nil, userInfo: ["btnNumber":1])
    }
    
    @IBAction func addButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "menuBtnPress"), object: nil, userInfo: ["btnNumber":2])
    }
    @IBAction func changeTeamBtn(_ sender: UIButton) {
       defaultTeamSelection()
       
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
    
    
    
    // delay loop
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tutorialPageViewController = segue.destination as? Locker_Room_UIPageController {
            self.tutorialPageViewController = tutorialPageViewController

        }
        
    }
}
extension LockerRoom_View_Controller: LockerRoomPageViewControllerDelegate {
    func tutorialPageViewController(tutorialPageViewController: Locker_Room_UIPageController, didUpdatePageCount count: Int) {
        
        pageControl.numberOfPages = count
    }
    
    func tutorialPageViewController(tutorialPageViewController: Locker_Room_UIPageController, didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
        
        switch index {
        case 0:
            statsButton.alpha = 1.0
            oldStatsButton.alpha = 0.5
            addPlayerButton.alpha = 0.5
        case 1:
            statsButton.alpha = 0.5
            oldStatsButton.alpha = 1.0
            addPlayerButton.alpha = 0.5
        case 2:
            statsButton.alpha = 0.5
            oldStatsButton.alpha = 0.5
            addPlayerButton.alpha = 1.0
        default:
            statsButton.alpha = 1.0
            oldStatsButton.alpha = 0.5
            addPlayerButton.alpha = 0.5
        }
        
    }
    
}

