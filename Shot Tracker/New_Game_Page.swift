
//
//  New_Game_Page.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-01-10.
//  Copyright © 2019 MAG Industries. All rights reserved.
//
import UIKit
import RealmSwift
import Realm
import GoogleMobileAds

class New_Game_Page: UIViewController, UIPopoverPresentationControllerDelegate {
    
    let realm = try! Realm()

    @IBOutlet weak var iceRinkImage: UIImageView!
    
    // declare image view vars
    let homeTeamGoalMakerImage = UIImage(named: "home_team_goal.png");
    let homeTeamShotMakerImage = UIImage(named: "home_team_shot.png");
    let awayTeamGoalMarkerImage = UIImage(named: "away_team_goal.png")
    let awayTeamShotMarkerImage = UIImage(named: "away_team_shot.png")
    let awayTeamPenaltyMarkerImage = UIImage(named: "away_penalty.png")
    let homeTeamPenaltyMarkerImage = UIImage(named: "home_penalty.png")
    
   
    @IBOutlet weak var adView: GADBannerView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var logoButton: UIButton!
    @IBOutlet weak var homeTeamNameLabel: UILabel!
    @IBOutlet weak var homeTeamNumGoals: UILabel!
    @IBOutlet weak var homeTeamNumShots: UILabel!
    @IBOutlet weak var awayTeamNumShots: UILabel!
    @IBOutlet weak var awayTeamNameLabel: UILabel!
    @IBOutlet weak var awayTeamNumGoals: UILabel!
    
    var yLocationCords: Int = 0
    var xLocationCords: Int = 0
    
    var shotMarkerimageView : UIImageView!
    var goalMarkerimageView : UIImageView!
    var penaltyMarkerimageView : UIImageView!
    
    var markerType: Bool!
    var newGameStarted: Bool = UserDefaults.standard.bool(forKey: "newGameStarted")
    var periodNumSelected: Int = UserDefaults.standard.integer(forKey: "periodNumber")
    var tempGoalieSelectedID: Int!
    var fixedGoalieID: Int = UserDefaults.standard.integer(forKey: "selectedGoalieID")
    var currentGameID: Int = UserDefaults.standard.integer(forKey: "gameID")
    
    var homeTeam: Int = UserDefaults.standard.integer(forKey: "homeTeam")
    var awayTeam: Int = UserDefaults.standard.integer(forKey: "awayTeam")
    
    // get location cords on user interaction with ice surface
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self.view)
        
        // link x and y cords data to vars for universal use
        yLocationCords = Int(location.y)
        xLocationCords = Int(location.x)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder() // To get shake gesture
         
        newGameDetection()
        teamNameInitialize()
        navBarProcessing()
        // enable ice rink image user interaction
        iceRinkImage.isUserInteractionEnabled = true
        
        // check Tap gestures for a single tap
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapped));
        // number of taps require 1
        singleTap.numberOfTapsRequired = 1
        // add geature to imageview
        iceRinkImage.addGestureRecognizer(singleTap)
        
        // check Tap gestures for a double tap
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(longTapped));
        //long tap must have a minimum of  0.5 seconds
        longTap.minimumPressDuration = 0.5
        // add geature to imageview
        iceRinkImage.addGestureRecognizer(longTap)
    
        // check Tap gestures for a two finger tap tap
        let twoFingerTap = UITapGestureRecognizer(target: self, action: #selector(twoFingerTapped));
        // number of taps require 2
        // number of finger required 1
        twoFingerTap.numberOfTouchesRequired = 2
        twoFingerTap.numberOfTapsRequired = 1
        // add geature to imageview
        iceRinkImage.addGestureRecognizer(twoFingerTap)
        
        // run delay loop ever so after realm refreshes so you get the most current x and y cord placements
        delay(0.5){
            // call functions for stats page dynamic function
            if (self.realm.objects(newGameTable.self).filter("gameID >= 0").last != nil) {
   
                self.shot_markerProcessing()
                self.goal_markerProcessing()
                self.penalty_markerProcessing()
                
                if (self.realm.objects(goalMarkersTable.self).filter("cordSetID >= 0").last == nil){
                // align text in text field as well assign text value to text field to team name
                self.homeTeamNumGoals.text = String(0)
                self.homeTeamNumGoals.textAlignment = .center
                self.awayTeamNumGoals.text = String(0)
                self.awayTeamNumGoals.textAlignment = .center
                print("Goal Count Defaulted to 0")
                }else{
                    self.scoreInitialize()
                    print("Goal Count Sucessfully Ran")
                }
                if (self.realm.objects(shotMarkerTable.self).filter("cordSetID >= 0").last == nil){
                // align text to center and assigned text field the value of homeScoreFilter query
                self.homeTeamNumShots.text = String(0)
                self.homeTeamNumShots.textAlignment = .center
                self.awayTeamNumShots.text = String(0)
                self.awayTeamNumShots.textAlignment = .center
                print("Shot Count Defaulted to 0")
                }else{
                     self.numShotInitialize()
                    print("Shot Count Sucessfully Ran")
                }
            }else{
                print("Score and Shot Count Ran Failed at newGameTable gameID")
            }
        }
       
        bannerViewInitialize()
        
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

    
    func bannerViewInitialize(){
        
        
        
        if (UserDefaults.standard.bool(forKey: "userPurchaseConf") == true){
            adView.heightAnchor.constraint(equalToConstant: 0.0).isActive = true
        }else{
            adView.adUnitID = universalValue().newGameAdUnitID
            adView.rootViewController = self
            adView.load(GADRequest())
            adView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
            adView.backgroundColor = UIColor.lightGray
        }
    }
    
    // dynamically changes nav bar text baded on period selection and teams selection
    func navBarProcessing(){
        if (periodNumSelected != nil && homeTeam != nil && awayTeam != nil){
            let home_teamNameFilter = realm.object(ofType: teamInfoTable.self, forPrimaryKey: homeTeam)?.nameOfTeam
            let away_teamNameFilter = realm.object(ofType: teamInfoTable.self, forPrimaryKey: awayTeam)?.nameOfTeam
            navBar.topItem!.title = home_teamNameFilter! + " vs " + away_teamNameFilter! + " Period " + String(periodNumSelected)
        }else{
            //nav bar textv defaults
            print("Error Unable to Gather Period Number Selection!")
        }
    }

    // if current game has been saved as Keep Active skip team selection segue
    func newGameDetection(){
        delay(0.3){
            if (self.newGameStarted != false){
                self.performSegue(withIdentifier: "logoButtonSegue", sender: nil);
            }
            
        }
    }
    // func used to process shot X and Y cord info from realm based on team selection on new game page load
    func shot_markerProcessing(){
        
        let newGameFilter = realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.gameID;
        // collect all the x and y cords for each marker placed that was a shot
        let home_xCordsArray = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", newGameFilter!, homeTeam)).value(forKeyPath: "xCordShot") as! [Int]).compactMap({String($0)})
        let home_yCordsArray = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", newGameFilter!, homeTeam)).value(forKeyPath: "yCordShot") as! [Int]).compactMap({String($0)})
        let away_xCordsArray = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", newGameFilter!, awayTeam)).value(forKeyPath: "xCordShot") as! [Int]).compactMap({String($0)})
        let away_yCordsArray = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", newGameFilter!, awayTeam)).value(forKeyPath: "yCordShot") as! [Int]).compactMap({String($0)})
        // check to see if either array cords arrays are not empty
        if (home_xCordsArray.isEmpty == false || away_xCordsArray.isEmpty == false){
            // loop through the corresponding shot arrays for both x and y and place a imageview marker in said spot
            for i in 0..<home_xCordsArray.count{
                    shotMarkerimageView = UIImageView(frame: CGRect(x: Int(home_xCordsArray[i])! - universalValue().markerCenterX, y: Int(home_yCordsArray[i])! - universalValue().markerCenterY, width: universalValue().markerWidth, height: universalValue().markerHeight));
                    shotMarkerimageView.contentMode = .scaleAspectFill;
                    shotMarkerimageView.image = homeTeamShotMakerImage;
                    view.addSubview(shotMarkerimageView);
            }
            for i in 0..<away_xCordsArray.count{
                    shotMarkerimageView = UIImageView(frame: CGRect(x: Int(away_xCordsArray[i])! - universalValue().markerCenterX, y: Int(away_yCordsArray[i])! - universalValue().markerCenterY, width: universalValue().markerWidth, height: universalValue().markerHeight));
                    shotMarkerimageView.contentMode = .scaleAspectFill;
                    shotMarkerimageView.image = awayTeamShotMarkerImage;
                    view.addSubview(shotMarkerimageView);
            }
        }else{
            // print error id not cord data present in arrays
            //should only error out if user hasnt submittte any marker data to realm
            print("No Shot Marker Cords Found on Load")
        }
    }
    
    // func used to process shot X and Y cord info from realm based on team selection on new game page load
    // func is exact copy of above but places goal markers instead
    func goal_markerProcessing() {
        
        let newGameFilter = realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.gameID;
        
        let home_xCordsArray = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", newGameFilter!, homeTeam)).value(forKeyPath: "xCordGoal") as! [Int]).compactMap({String($0)})
        let home_yCordsArray = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", newGameFilter!, homeTeam)).value(forKeyPath: "yCordGoal") as! [Int]).compactMap({String($0)})
        let away_xCordsArray = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", newGameFilter!, awayTeam)).value(forKeyPath: "xCordGoal") as! [Int]).compactMap({String($0)})
        let away_yCordsArray = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", newGameFilter!, awayTeam)).value(forKeyPath: "yCordGoal") as! [Int]).compactMap({String($0)})
        
        // log data grabbed from realm
        if (home_xCordsArray.isEmpty == false || away_xCordsArray.isEmpty == false){
            // check markerType image value
            for i in 0..<home_xCordsArray.count{
                goalMarkerimageView = UIImageView(frame: CGRect(x: Int(home_xCordsArray[i])! - universalValue().markerCenterX, y: Int(home_yCordsArray[i])! - universalValue().markerCenterY, width: universalValue().markerWidth, height: universalValue().markerHeight));
                goalMarkerimageView.contentMode = .scaleAspectFill;
                goalMarkerimageView.image = homeTeamGoalMakerImage;
                view.addSubview(goalMarkerimageView);
            }
            for i in 0..<away_xCordsArray.count{
                goalMarkerimageView = UIImageView(frame: CGRect(x: Int(away_xCordsArray[i])! - universalValue().markerCenterX, y: Int(away_yCordsArray[i])! - universalValue().markerCenterY, width: universalValue().markerWidth, height: universalValue().markerHeight));
                goalMarkerimageView.contentMode = .scaleAspectFill;
                goalMarkerimageView.image = awayTeamGoalMarkerImage;
                view.addSubview(goalMarkerimageView);
            }
        }else{
            // print error id not cord data present in arrays
            //should only error out if user hasnt submittte any marker data to realm
            print("No Goal Marker Cords Found on Load")
        }
    }
    
    // func used to process shot X and Y cord info from realm based on team selection on new game page load
    // func is exact copy of above but places penalty markers instead
    func penalty_markerProcessing() {
        
        let newGameFilter = realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.gameID;
        
        let home_xCordsArray = (realm.objects(penaltyTable.self).filter(NSPredicate(format: "gameID == %i AND teamID == %i", newGameFilter!, homeTeam)).value(forKeyPath: "xCord") as! [Int]).compactMap({String($0)})
        let home_yCordsArray = (realm.objects(penaltyTable.self).filter(NSPredicate(format: "gameID == %i AND teamID == %i", newGameFilter!, homeTeam)).value(forKeyPath: "yCord") as! [Int]).compactMap({String($0)})
        let away_xCordsArray = (realm.objects(penaltyTable.self).filter(NSPredicate(format: "gameID == %i AND teamID == %i", newGameFilter!, awayTeam)).value(forKeyPath: "xCord") as! [Int]).compactMap({String($0)})
        let away_yCordsArray = (realm.objects(penaltyTable.self).filter(NSPredicate(format: "gameID == %i AND teamID == %i", newGameFilter!, awayTeam)).value(forKeyPath: "yCord") as! [Int]).compactMap({String($0)})
        
        // log data grabbed from realm
        if (home_xCordsArray.isEmpty == false || away_xCordsArray.isEmpty == false){
            // check markerType image value
            for i in 0..<home_xCordsArray.count{
                penaltyMarkerimageView = UIImageView(frame: CGRect(x: Int(home_xCordsArray[i])! - universalValue().markerCenterX, y: Int(home_yCordsArray[i])! - universalValue().markerCenterY, width: universalValue().markerWidth, height: universalValue().markerHeight));
                penaltyMarkerimageView.contentMode = .scaleAspectFill;
                penaltyMarkerimageView.image = homeTeamPenaltyMarkerImage;
                view.addSubview(penaltyMarkerimageView);
            }
            for i in 0..<away_xCordsArray.count{
                penaltyMarkerimageView = UIImageView(frame: CGRect(x: Int(away_xCordsArray[i])! - universalValue().markerCenterX, y: Int(away_yCordsArray[i])! - universalValue().markerCenterY, width: universalValue().markerWidth, height: universalValue().markerHeight));
                penaltyMarkerimageView.contentMode = .scaleAspectFill;
                penaltyMarkerimageView.image = awayTeamPenaltyMarkerImage;
                view.addSubview(penaltyMarkerimageView);
            }
        }else{
            // print error id not cord data present in arrays
            //should only error out if user hasnt submittte any marker data to realm
            print("No Penalty Marker Cords Found on Load")
        }
    }
  
    func teamNameInitialize(){
        // query realm for team names of teams based on newest game
        let newHomeGameFilter = realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.homeTeamID;
        let newAwayGameFilter = realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.opposingTeamID;
        let homeTeamNameString = realm.object(ofType: teamInfoTable.self, forPrimaryKey: newHomeGameFilter);
        let awayTeamNameString = realm.object(ofType: teamInfoTable.self, forPrimaryKey: newAwayGameFilter);
        // align text in text field as well assign text value to text field to team name
        homeTeamNameLabel.text = homeTeamNameString?.nameOfTeam
        homeTeamNameLabel.textAlignment = .center
        awayTeamNameLabel.text = awayTeamNameString?.nameOfTeam
        awayTeamNameLabel.textAlignment = .center
    }
    // func responsible for updating quick score view at bottom of VC
    func scoreInitialize(){
        
        // query realm for goal count based on newest gam
        let gameID = realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)
        let homeScoreFilter = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", (gameID?.gameID)!, homeTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        
        let awayScoreFilter = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", (gameID?.gameID)!, awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        // align text to center and assigned text field the value of homeScoreFilter query
        homeTeamNumGoals.text = String(homeScoreFilter)
        homeTeamNumGoals.textAlignment = .center
        awayTeamNumGoals.text = String(awayScoreFilter)
        awayTeamNumGoals.textAlignment = .center
    }
    // func responsible for updating quick shot view at bottom of VC
    func numShotInitialize(){
        
       let queryGameID = realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)
        
        //get array of team ID's and concert to regular string array from optional
        let homeShotCounter = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", (queryGameID!.gameID), homeTeam)).value(forKeyPath: "TeamID") as! [Int]).compactMap({String($0)}).count
        
        let awayShotCounter = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", (queryGameID!.gameID), awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        // align text to center and assigned text field the value of homeScoreFilter query
        homeTeamNumShots.text = String(homeShotCounter)
        homeTeamNumShots.textAlignment = .center
        awayTeamNumShots.text = String(awayShotCounter)
        awayTeamNumShots.textAlignment = .center        
    }
    
    // single tap function applies black x to ice surface when gesture returns correct
    @objc func singleTapped() {
        print("Single Tap Detected")
        markerType = true;
        // display custom view controller alert alert
        // segue to maker info page goes here
        popUpSegue()
        
    }
    // long tap function applies red x to ice surface when gesture returns correct
    @objc func longTapped() {
        print("Long Tap Detected")
        markerType = false;
        // display custom view controller alert alert
        popUpSegue()
    }
    // long tap function applies red x to ice surface when gesture returns correct
    @objc func twoFingerTapped() {
        print("Double Finger Tap Detected")
        // display custom view controller alert alert
        print(xLocationCords)
        print(yLocationCords)
        popUpPenaltySegue()
        
    }
    // segue to period and goalie selction popup
    func popUpSegue(){
        
        self.performSegue(withIdentifier: "popUpSegueView", sender: nil);
        
    }
    
    func popUpPenaltySegue(){
        
         self.performSegue(withIdentifier: "popUpPenaltyView", sender: nil);
        
    }
    
    // action when clicking done button
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        // Create you actionsheet - preferredStyle: .actionSheet
        let actionSheet = UIAlertController(title: "Current Game Save State", message: "Please select save state this game should be saved to.", preferredStyle: .actionSheet)
        
        // Create your actions - take a look at different style attributes
        //saveButtonAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        let keepActiveAction = UIAlertAction(title: "Keep Active", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            // set activegame status to active or true based on user selection
            try! self.realm.write{
                self.realm.object(ofType: newGameTable.self, forPrimaryKey: self.realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.activeGameStatus = true
            }
            // delete all user defaults generated from newgame
            deleteNewGameUserDefaults.deleteUserDefaults()
             // segue back to home screen when done
            self.performSegue(withIdentifier: "newGameSegue", sender: nil)
        })
        // on save buttton press save newgame datas to realm
        let saveAction = UIAlertAction(title: "Save", style: .destructive, handler: { (alert: UIAlertAction!) -> Void in
           // write to realm the resulting winnewr and loser of the game currently played and save to cold storage as closed
            try! self.realm.write{
                self.realm.object(ofType: newGameTable.self, forPrimaryKey: self.realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.activeGameStatus = false
                let homeTeamIDCount = Int(self.homeTeamNumGoals.text!)
                let awayTeamIDCount = Int(self.awayTeamNumGoals.text!)
                // check if game is a tie if so update accordingly
                if (homeTeamIDCount == awayTeamIDCount){
                    self.realm.object(ofType: newGameTable.self, forPrimaryKey: self.realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.tieGameBool = true
                    print("It's a Tie")
                    // else update new game results based on winner
                }else if (homeTeamIDCount! > awayTeamIDCount!){
                        self.realm.object(ofType: newGameTable.self, forPrimaryKey: self.realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.winingTeamID = self.homeTeam
                        self.realm.object(ofType: newGameTable.self, forPrimaryKey: self.realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.losingTeamID = self.awayTeam
                        print("Home Team Won")
                }else{
                  self.realm.object(ofType: newGameTable.self, forPrimaryKey: self.realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.winingTeamID = self.awayTeam
                    self.realm.object(ofType: newGameTable.self, forPrimaryKey: self.realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.losingTeamID = self.homeTeam
                    print("Away Team Won")
                    
                    
                }

              
            }
            // delete all user defaults generated from newgame
            deleteNewGameUserDefaults.deleteUserDefaults()
            // segue back to home screen when done
            self.performSegue(withIdentifier: "newGameSegue", sender: nil)
        })
        // tapp anywhere outside of popup alert controller
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in
            print("didPress Cancel")
        })
        // Add the actions to your actionSheet
        actionSheet.addAction(keepActiveAction)
        actionSheet.addAction(saveAction)
        actionSheet.addAction(cancelAction)
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        // Present the controller
        self.present(actionSheet, animated: true, completion: nil)
    
    }
    


    // func used to pass varables on segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check is appropriate segue is being used
        if (segue.identifier == "popUpSegueView"){
            // set var vc as destination segue
            let vc = segue.destination as! Shot_Location_View
            vc.tempXCords = xLocationCords
            vc.tempYCords = yLocationCords
            vc.tempMarkerType = markerType
        } else if (segue.identifier == "popUpPenaltyView"){
            // set var vc as destination segue
            let vc = segue.destination as! Penalty_Popup_View_Controller
            vc.tempXCords = xLocationCords
            vc.tempYCords = yLocationCords
        }
    }
    // delay loop
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
}
