
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
    @IBAction func unWindToNewGame(segue: UIStoryboardSegue) {}
    @IBOutlet weak var pageControl: UIPageControl!
    
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
    @IBOutlet weak var iceSufaceImageView: UIImageView!
    @IBOutlet weak var tutorialConatiner: UIView!
    @IBOutlet weak var closeTutorialBtn: UIButton!
    
    
    var yLocationCords: Int = 0
    var xLocationCords: Int = 0
    
    var shotMarkerimageView : UIImageView!
    var goalMarkerimageView : UIImageView!
    var penaltyMarkerimageView : UIImageView!
    
    var markerType: Bool!
    var newGameStarted: Bool = UserDefaults.standard.bool(forKey: "newGameStarted")
    var periodNumSelected: Int!
    var tempGoalieSelectedID: Int!
    var fixedGoalieID: Int!
    var currentGameID: Int!
    var tagCounter: Int = 100
    
    var homeTeam: Int!
    var awayTeam: Int!
    var faceoffLocation: Int!
    var tutorialIndex: Int!
    var homePlayerIDs: [Int] = [Int]()
    var awayPlayerIDs: [Int] = [Int]()
    
    var topLeft: CGRect?
    var topLeftBlue: CGRect?
    var topRight: CGRect?
    var topRightBlue: CGRect?
    var bottomLeft: CGRect?
    var bottomLeftBlue: CGRect?
    var bottomRight: CGRect?
    var bottomRightBlue: CGRect?
    var middleCenter: CGRect?
    
    var tutorialView: UIView!
    var tutorialTopLabel: UILabel!
    var tutorialMiddleLabel: UILabel!
    
    
    var tutorialPageViewController: Main_New_Game_Tutorial_ViewController? {
        didSet {
            tutorialPageViewController?.tutorialDelegate = self
        }
    }
    
    
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
        UserDefaults.standard.set(false, forKey: "firstGameBool")
        
        pageControl.addTarget(self, action: Selector("didChangePageControlValue"), for: .valueChanged)
        
        // set listener for notification after goalie is selected
        NotificationCenter.default.addObserver(self, selector: #selector(myMethod(notification:)), name: NSNotification.Name(rawValue: "shotLocationRefresh"), object: nil)
        
        
        UserDefaults.standard.set((realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?), forKey: "gameID")
        currentGameID =  UserDefaults.standard.integer(forKey: "gameID")
        
        //turtorialLoad()
        newGameDetection()
        onLoad()
        
        homePlayerIDs = ((self.realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == true", String(self.homeTeam))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)}))
        awayPlayerIDs = ((self.realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == true", String(self.awayTeam))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)}))
        
        overallStatsTableDoubleCheck()
        
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

    
    @objc func myMethod(notification: NSNotification){
        // remove all previous markers from ice before adding new ones onLoad func
        for views in self.view.subviews{
            if views.tag >= 100{
                views.removeFromSuperview()
            }
        }
        onLoad()
        iceSurfaceImageViewBoundaries()
        
        
    }
    
    
    
    
    func onLoad(){
        print("UI UPDATED")
        
        periodNumSelected = UserDefaults.standard.integer(forKey: "periodNumber")
        fixedGoalieID = UserDefaults.standard.integer(forKey: "selectedGoalieID")
        homeTeam = UserDefaults.standard.integer(forKey: "homeTeam")
        awayTeam = UserDefaults.standard.integer(forKey: "awayTeam")
        
        teamNameInitialize()
        navBarProcessing()
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
        
        
        if (UserDefaults.standard.bool(forKey: "firstGameBool") == false && isKeyPresentInUserDefaults(key: "selectedGoalieID") == true){
           print("tuorial")
            tutorialConatiner.layer.cornerRadius = 10
            tutorialConatiner.isHidden = false
            closeTutorialBtn.isHidden = false
            pageControl.isHidden = false
           // add blur effect to view along with popUpView
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurEffectView.tag = 500
            
            view.addSubview(blurEffectView)
            view.addSubview(tutorialConatiner)
            view.addSubview(closeTutorialBtn)
            view.addSubview(pageControl)
        }else if (isKeyPresentInUserDefaults(key: "selectedGoalieID") == false){
            tutorialConatiner.isHidden = true
            pageControl.isHidden = true
            closeTutorialBtn.isHidden = true
            
        }else{
            print("Not first game")
            pageControl.removeFromSuperview()
            tutorialConatiner.removeFromSuperview()
        }
        
    }
    
    // func comapres old overatst table to new stats table to detect newly added players while game is open
    func overallStatsTableDoubleCheck(){
        
        for homePlayerID in homePlayerIDs{
            print("plyaer id \(homePlayerID)")
            let overallStatsPlayerConf = ((self.realm.objects(overallStatsTable.self).filter(NSPredicate(format: "gameID == %i AND playerID == %i AND activeState == true", currentGameID, homePlayerID)).value(forKeyPath: "overallStatsID") as! [Int]).compactMap({String($0)})).count
            print("overall \(overallStatsPlayerConf)")
            // if player is from home team is not found in overall stats table add to table
            if overallStatsPlayerConf == 0{
                try! realm.write() {
                    var primaryID: Int!
                    if (self.realm.objects(overallStatsTable.self).max(ofProperty: "overallStatsID") as Int? != nil){
                        primaryID = (self.realm.objects(overallStatsTable.self).max(ofProperty: "overallStatsID") as Int? ?? 0) + 1;
                    }else{
                        primaryID = (self.realm.objects(overallStatsTable.self).max(ofProperty: "overallStatsID") as Int? ?? 0);
                    }
                    
                    self.realm.create(overallStatsTable.self, value: ["overallStatsID": primaryID])
                    let primaryCurrentStatID = self.realm.object(ofType: overallStatsTable.self, forPrimaryKey: primaryID)
                    
                    primaryCurrentStatID?.gameID = currentGameID
                    primaryCurrentStatID?.playerID = homePlayerID
                    primaryCurrentStatID?.lineNum = ((self.realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", homePlayerID)).value(forKeyPath: "lineNum") as! [Int]).compactMap({Int($0)})).first!
                    primaryCurrentStatID?.activeState = true
                }
            }
        }
        for awayPlayerID in awayPlayerIDs{
            print("plyaer id \(awayPlayerID)")
            let overallStatsPlayerConf = ((self.realm.objects(overallStatsTable.self).filter(NSPredicate(format: "gameID == %i AND playerID == %i AND activeState == true", currentGameID, awayPlayerID)).value(forKeyPath: "overallStatsID") as! [Int]).compactMap({String($0)})).count
            // if player is from home team is not found in overall stats table add to table
            if overallStatsPlayerConf == 0{
                try! realm.write() {
                    var primaryID: Int!
                    if (self.realm.objects(overallStatsTable.self).max(ofProperty: "overallStatsID") as Int? != nil){
                        primaryID = (self.realm.objects(overallStatsTable.self).max(ofProperty: "overallStatsID") as Int? ?? 0) + 1;
                    }else{
                        primaryID = (self.realm.objects(overallStatsTable.self).max(ofProperty: "overallStatsID") as Int? ?? 0);
                    }
                    
                    self.realm.create(overallStatsTable.self, value: ["overallStatsID": primaryID])
                    let primaryCurrentStatID = self.realm.object(ofType: overallStatsTable.self, forPrimaryKey: primaryID)
                    
                    primaryCurrentStatID?.gameID = currentGameID
                    primaryCurrentStatID?.playerID = awayPlayerID
                    primaryCurrentStatID?.lineNum = ((self.realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", awayPlayerID)).value(forKeyPath: "lineNum") as! [Int]).compactMap({Int($0)})).first!
                    primaryCurrentStatID?.activeState = true
                }
            }
        }
    }
    
    
    func bannerViewInitialize(){
        
        
        
        if (UserDefaults.standard.bool(forKey: "userPurchaseConf") == true){
            adView.heightAnchor.constraint(equalToConstant: 0.0).isActive = true
        }else{
            print("Ad is displayed")
            adView.adUnitID = universalValue().newGameAdUnitID
            adView.rootViewController = self
            adView.load(GADRequest())
            adView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
            adView.backgroundColor = UIColor.lightGray
            adView.isHidden = false
        }
    }
    
    // dynamically changes nav bar text baded on period selection and teams selection
    func navBarProcessing(){
        if (periodNumSelected != nil && homeTeam != nil && awayTeam != nil){
            let home_teamNameFilter = realm.object(ofType: teamInfoTable.self, forPrimaryKey: homeTeam)?.nameOfTeam
            let away_teamNameFilter = realm.object(ofType: teamInfoTable.self, forPrimaryKey: awayTeam)?.nameOfTeam
            navBar?.topItem?.title = home_teamNameFilter! + " vs " + away_teamNameFilter! + " Period " + String(periodNumSelected)
        }else{
            //nav bar textv defaults
            print("Error Unable to Gather Period Number Selection!")
        }
    }

    // if current game has been saved as Keep Active skip team selection segue
    func newGameDetection(){
        delay(0.3){
            if (self.newGameStarted != false){
                self.performSegue(withIdentifier: "newGameBasicInfoSegue", sender: nil)
            }
    
        }
    }
    
    func iceSurfaceImageViewBoundaries(){
        
        iceSufaceImageView.isUserInteractionEnabled = true
        
        let screenWidth = iceSufaceImageView.frame.width
        let screenHeight = iceSufaceImageView.frame.height
        
        let screenWidthHalf = screenWidth / 2
        
        // Major circles CGRect definntions
        topLeft = CGRect(x: iceSufaceImageView.frame.minX, y: iceSufaceImageView.frame.minY,  width: (screenWidthHalf / 3) * 1.75,  height: screenHeight / 2)
        topRight = CGRect(x: (screenWidth / 3) * 2.15 , y: iceSufaceImageView.frame.minY,  width: (screenWidth / 3) * 2,  height: screenHeight / 2)
        bottomLeft = CGRect(x: iceSufaceImageView.frame.minX, y: iceSufaceImageView.frame.midY,  width: (screenWidthHalf / 3) * 1.75,  height: screenHeight / 2 )
        bottomRight = CGRect(x: (screenWidth / 3) * 2.15, y: iceSufaceImageView.frame.midY,  width: screenWidth / 3,  height: screenHeight / 2)
        middleCenter = CGRect(x: (screenWidth / 3)  * 1.25, y: iceSufaceImageView.frame.minY,  width: (screenWidthHalf / 3),  height: screenHeight)
        // blue line CGRect definition
        topLeftBlue = CGRect(x: topLeft!.maxX, y: topLeft!.minY,  width: (middleCenter!.minX - topLeft!.maxX),  height: screenHeight / 2)
        bottomLeftBlue = CGRect(x: bottomLeft!.maxX, y: bottomLeft!.minY,  width: (middleCenter!.minX - topLeft!.maxX),  height: screenHeight / 2)
        topRightBlue = CGRect(x: middleCenter!.maxX, y: middleCenter!.minY,  width: (topRight!.minX - middleCenter!.maxX),  height: screenHeight / 2)
        bottomRightBlue = CGRect(x: topRight!.minX - topRightBlue!.width, y: topRight!.maxY,  width: (topRight!.minX - middleCenter!.maxX),  height: screenHeight / 2)
        
        // check Tap gestuires for a single tap
        let faceOffTap = UILongPressGestureRecognizer(target: self, action: #selector(twoFingerIceSurfaceSelector));
        // number of taps require 1
        //faceOffTap.numberOfTapsRequired = 1
        faceOffTap.numberOfTouchesRequired = 2
        iceSufaceImageView.addGestureRecognizer(faceOffTap)
        
    }
    
    @objc func twoFingerIceSurfaceSelector(sender: UILongPressGestureRecognizer){
        if (sender.state == .began){
            print("called")
            let tapPosition = sender.location(in: self.iceSufaceImageView)
            print("tapposition \(tapPosition)")
            if topLeft!.contains(tapPosition) {
                print("Top Left Faceoff Detected")
                faceoffLocation = 1
                performSegue(withIdentifier: "faceoff_segue", sender: nil)
            }
            if topRight!.contains(tapPosition) {
                print("Top Right Faceoff Detected")
                faceoffLocation = 2
                performSegue(withIdentifier: "faceoff_segue", sender: nil)
            }
            if middleCenter!.contains(tapPosition) {
                print("Center Faceoff Detected")
                faceoffLocation = 3
                performSegue(withIdentifier: "faceoff_segue", sender: nil)
            }
            if bottomLeft!.contains(tapPosition) {
                print("Bottom Left Faceoff Detected")
                faceoffLocation = 4
                performSegue(withIdentifier: "faceoff_segue", sender: nil)
            }
            if bottomRight!.contains(tapPosition) {
                print("Bottom Right Faceoff Detected")
                faceoffLocation = 5
                performSegue(withIdentifier: "faceoff_segue", sender: nil)
            }
            if topLeftBlue!.contains(tapPosition) {
                print("Top Left Blue Line Faceoff Detected")
                faceoffLocation = 6
                performSegue(withIdentifier: "faceoff_segue", sender: nil)
            }
            if bottomLeftBlue!.contains(tapPosition) {
                print("Bottom Left Blue Line Faceoff Detected")
                faceoffLocation = 7
                performSegue(withIdentifier: "faceoff_segue", sender: nil)
            }
            if topRightBlue!.contains(tapPosition) {
                print("Top Right Blue Line Faceoff Detected")
                faceoffLocation = 8
                performSegue(withIdentifier: "faceoff_segue", sender: nil)
            }
            if bottomRightBlue!.contains(tapPosition) {
                print("Bottom Right Blue Line Faceoff Detected")
                faceoffLocation = 9
                performSegue(withIdentifier: "faceoff_segue", sender: nil)
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
        if (UserDefaults.standard.bool(forKey: "displayShotBool") == true){
            // check to see if either array cords arrays are not empty
            if (home_xCordsArray.isEmpty == false || away_xCordsArray.isEmpty == false ){
                // loop through the corresponding shot arrays for both x and y and place a imageview marker in said spot
                for i in 0..<home_xCordsArray.count{
                    let imageView = UIImageView(frame: CGRect(x: Int(home_xCordsArray[i])! - universalValue().markerCenterX, y: Int(home_yCordsArray[i])! - universalValue().markerCenterY, width: universalValue().markerWidth, height: universalValue().markerHeight));
                    imageView.contentMode = .scaleAspectFill;
                    imageView.image = homeTeamShotMakerImage;
                    view.addSubview(imageView);
                    imageView.tag = tagCounter
                    tagCounter += 1
                }
                for i in 0..<away_xCordsArray.count{
                    let imageView = UIImageView(frame: CGRect(x: Int(away_xCordsArray[i])! - universalValue().markerCenterX, y: Int(away_yCordsArray[i])! - universalValue().markerCenterY, width: universalValue().markerWidth, height: universalValue().markerHeight));
                    imageView.contentMode = .scaleAspectFill;
                    imageView.image = awayTeamShotMarkerImage;
                    view.addSubview(imageView);
                    imageView.tag = tagCounter
                    tagCounter += 1
                }
            }else{
                // print error id not cord data present in arrays
                //should only error out if user hasnt submittte any marker data to realm
                print("No Shot Marker Cords Found on Load")
            }
        }else{
            print("User has disabled shot markers")
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
        if (UserDefaults.standard.bool(forKey: "displayGoalBool") == true){
            // log data grabbed from realm
            if (home_xCordsArray.isEmpty == false || away_xCordsArray.isEmpty == false ){
                // check markerType image value
                for i in 0..<home_xCordsArray.count{
                    let imageView = UIImageView(frame: CGRect(x: Int(home_xCordsArray[i])! - universalValue().markerCenterX, y: Int(home_yCordsArray[i])! - universalValue().markerCenterY, width: universalValue().markerWidth, height: universalValue().markerHeight));
                    imageView.contentMode = .scaleAspectFill;
                    imageView.image = homeTeamGoalMakerImage;
                    view.addSubview(imageView);
                    imageView.tag = tagCounter
                    tagCounter += 1
                }
                for i in 0..<away_xCordsArray.count{
                    let imageView = UIImageView(frame: CGRect(x: Int(away_xCordsArray[i])! - universalValue().markerCenterX, y: Int(away_yCordsArray[i])! - universalValue().markerCenterY, width: universalValue().markerWidth, height: universalValue().markerHeight));
                    imageView.contentMode = .scaleAspectFill;
                    imageView.image = awayTeamGoalMarkerImage;
                    view.addSubview(imageView);
                    imageView.tag = tagCounter
                    tagCounter += 1
                }
            }else{
                // print error id not cord data present in arrays
                //should only error out if user hasnt submittte any marker data to realm
                print("No Goal Marker Cords Found on Load")
            }
        }else{
            print("User has disabled goal markers")
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
        if (UserDefaults.standard.bool(forKey: "displayPenaltyBool") == true){
            // log data grabbed from realm
            if (home_xCordsArray.isEmpty == false || away_xCordsArray.isEmpty == false ){
                // check markerType image value
                for i in 0..<home_xCordsArray.count{
                    let imageView = UIImageView(frame: CGRect(x: Int(home_xCordsArray[i])! - universalValue().markerCenterX, y: Int(home_yCordsArray[i])! - universalValue().markerCenterY, width: universalValue().markerWidth, height: universalValue().markerHeight));
                    imageView.contentMode = .scaleAspectFill;
                    imageView.image = homeTeamPenaltyMarkerImage;
                    view.addSubview(imageView);
                    imageView.tag = tagCounter
                    tagCounter += 1
                }
                for i in 0..<away_xCordsArray.count{
                    let imageView = UIImageView(frame: CGRect(x: Int(away_xCordsArray[i])! - universalValue().markerCenterX, y: Int(away_yCordsArray[i])! - universalValue().markerCenterY, width: universalValue().markerWidth, height: universalValue().markerHeight));
                    imageView.contentMode = .scaleAspectFill;
                    imageView.image = awayTeamPenaltyMarkerImage;
                    view.addSubview(imageView);
                    imageView.tag = tagCounter
                    tagCounter += 1
                }
            }else{
                // print error id not cord data present in arrays
                //should only error out if user hasnt submittte any marker data to realm
                print("No Penalty Marker Cords Found on Load")
            }
        }else{
            print("User has disabled penalty markers")
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
    
    @IBAction func logoButton(_ sender: UIButton) {
        
        let actionSheet = UIAlertController(title: localizedString().localized(value:"Game Options"), message: localizedString().localized(value:"Change the way your Ice Surface is dispalyed."), preferredStyle: .actionSheet)
        
        // Create your actions - take a look at different style attributes
        //saveButtonAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        let keepActiveAction = UIAlertAction(title: localizedString().localized(value:"Goalie / Period Change"), style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "newGameBasicInfoSegue", sender: nil)
        })
        // on save buttton press save newgame datas to realm
        let saveAction = UIAlertAction(title: localizedString().localized(value:"Game Options"), style: .default, handler: { (alert: UIAlertAction!) -> Void in
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let popupVC = storyboard.instantiateViewController(withIdentifier: "In Game Settings ViewController") as! In_Game_Settings_ViewController
            popupVC.modalPresentationStyle = .overCurrentContext
            popupVC.modalTransitionStyle = .crossDissolve
            let pVC = popupVC.popoverPresentationController
            pVC?.permittedArrowDirections = .any
            pVC?.delegate = self
            
            self.present(popupVC, animated: true, completion: nil)
            print("In Game Settings ViewController Presented!")
        })
        // tapp anywhere outside of popup alert controller
        let cancelAction = UIAlertAction(title: localizedString().localized(value:"Cancel"), style: .cancel, handler: { (alert: UIAlertAction!) -> Void in
            print("didPress Cancel")
        })
        // Add the actions to your actionSheet
        actionSheet.addAction(keepActiveAction)
        actionSheet.addAction(saveAction)
        actionSheet.addAction(cancelAction)
        if let popoverController = actionSheet.popoverPresentationController {
            
            popoverController.sourceRect = CGRect(x: 50, y: logoButton.frame.minY, width: 0, height: logoButton.frame.minY)
            popoverController.sourceView = logoButton
        }
        
        // Present the controller
        self.present(actionSheet, animated: true, completion: nil)
        
        
    }
    
    // segue to shot location popup
    func popUpSegue(){
        performSegue(withIdentifier: "popUpSegueView", sender: nil)
        
    }
    
    func popUpPenaltySegue(){
        
       performSegue(withIdentifier: "popUpPenaltyView", sender: nil)
        
    }
    
    @IBAction func gameStatsButton(_ sender: UIBarButtonItem) {
        if let mvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "gameStatsVC") as? Main_Game_Stats_View_Controller {
            self.present(mvc, animated: true, completion: nil)
        }
    }
    // action when clicking done button
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        // Create you actionsheet - preferredStyle: .actionSheet
        let actionSheet = UIAlertController(title: localizedString().localized(value:"Current Game Save State"), message: localizedString().localized(value:"Please select save state this game should be saved to.\n ie. Please note all in game settings will be forgotten regardless of selection, this will not delete your current game stats."), preferredStyle: .actionSheet)
        
        // Create your actions - take a look at different style attributes
        //saveButtonAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        let keepActiveAction = UIAlertAction(title: localizedString().localized(value:"Keep Active"), style: .default, handler: { (alert: UIAlertAction!) -> Void in
            // set activegame status to active or true based on user selection
            try! self.realm.write{
                self.realm.object(ofType: newGameTable.self, forPrimaryKey: self.realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.activeGameStatus = true
            
            }
            // delete all user defaults generated from newgame
            deleteNewGameUserDefaults.deleteUserDefaults()
            inGmaeUserDefaultGen().delete_userDefaults()
             // segue back to home screen when done
            let dictionary = ["key":"value"]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "homePageRefresh"), object: nil, userInfo: dictionary)
            self.performSegue(withIdentifier: "backToMainNewGame", sender: nil)
        })
        // on save buttton press save newgame datas to realm
        let saveAction = UIAlertAction(title: localizedString().localized(value:"Save"), style: .destructive, handler: { (alert: UIAlertAction!) -> Void in
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
            // update player stats when leaving game
            self.playerStatsUpdate()
            
            // delete all user defaults generated from newgame
            deleteNewGameUserDefaults.deleteUserDefaults()
            inGmaeUserDefaultGen().delete_userDefaults()
            // segue back to home screen when done
            let dictionary = ["key":"value"]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "homePageRefresh"), object: nil, userInfo: dictionary)
            self.performSegue(withIdentifier: "backToMainNewGame", sender: nil)
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
    
    func playerStatsUpdate(){
         try! self.realm.write{
            
        
            for home_playerID in homePlayerIDs{
                
                self.realm.object(ofType: playerInfoTable.self, forPrimaryKey: home_playerID)?.goalCount += ((self.realm.objects(overallStatsTable.self).filter(NSPredicate(format: "gameID == %i AND playerID == %i AND activeState == true", self.currentGameID ,home_playerID)).value(forKeyPath: "goalCount") as! [Int]).compactMap({Int($0)})).first!
                self.realm.object(ofType: playerInfoTable.self, forPrimaryKey: home_playerID)?.assitsCount += ((self.realm.objects(overallStatsTable.self).filter(NSPredicate(format: "gameID == %i AND playerID == %i AND activeState == true", currentGameID ,home_playerID)).value(forKeyPath: "assistCount") as! [Int]).compactMap({Int($0)})).first!
                self.realm.object(ofType: playerInfoTable.self, forPrimaryKey: home_playerID)?.plusMinus += ((self.realm.objects(overallStatsTable.self).filter(NSPredicate(format: "gameID == %i AND playerID == %i AND activeState == true", self.currentGameID ,home_playerID)).value(forKeyPath: "plusMinus") as! [Int]).compactMap({Int($0)})).first!
                
            }
        
            let awayPlayerIDs = ((self.realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND activeState == true", String(self.awayTeam))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)}))
        
            for away_playerID in awayPlayerIDs{
                
                self.realm.object(ofType: playerInfoTable.self, forPrimaryKey: away_playerID)?.goalCount += ((self.realm.objects(overallStatsTable.self).filter(NSPredicate(format: "gameID == %i AND playerID == %i AND activeState == true", self.currentGameID ,away_playerID)).value(forKeyPath: "goalCount") as! [Int]).compactMap({Int($0)})).first!
                self.realm.object(ofType: playerInfoTable.self, forPrimaryKey: away_playerID)?.assitsCount += ((self.realm.objects(overallStatsTable.self).filter(NSPredicate(format: "gameID == %i AND playerID == %i AND activeState == true", self.currentGameID ,away_playerID)).value(forKeyPath: "assistCount") as! [Int]).compactMap({Int($0)})).first!
                self.realm.object(ofType: playerInfoTable.self, forPrimaryKey: away_playerID)?.plusMinus += ((self.realm.objects(overallStatsTable.self).filter(NSPredicate(format: "gameID == %i AND playerID == %i AND activeState == true", self.currentGameID ,away_playerID)).value(forKeyPath: "plusMinus") as! [Int]).compactMap({Int($0)})).first!
                
            }
        }
    }
    // x iconto close tutorial button
    @IBAction func closeTutorialBtn(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.tutorialConatiner.alpha = 0.0
            self.closeTutorialBtn.alpha = 0.0
        }, completion: nil)
        // dimiss conatiner view
        tutorialConatiner.removeFromSuperview()
        closeTutorialBtn.removeFromSuperview()
        //remove blur from view
        view.viewWithTag(500)?.removeFromSuperview()
        UserDefaults.standard.set(true, forKey: "firstGameBool")
    }
    
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
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
        } else if (segue.identifier == "faceoff_segue"){
            // set var vc as destination segue
            let vc = segue.destination as! Faceoff_View_Controller
            vc.tempXCords = xLocationCords
            vc.tempYCords = yLocationCords
            vc.faceoffLocation = faceoffLocation
        }
        if let tutorialPageViewController = segue.destination as? Main_New_Game_Tutorial_ViewController {
            self.tutorialPageViewController = tutorialPageViewController
        }
    }
    // delay loop
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    func didChangePageControlValue() {
        tutorialPageViewController?.scrollToViewController(index: pageControl.currentPage)
    }
}

extension New_Game_Page: TutorialPageViewControllerDelegate {
    func tutorialPageViewController(tutorialPageViewController: Main_New_Game_Tutorial_ViewController, didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    func tutorialPageViewController(tutorialPageViewController: Main_New_Game_Tutorial_ViewController, didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
    
}
