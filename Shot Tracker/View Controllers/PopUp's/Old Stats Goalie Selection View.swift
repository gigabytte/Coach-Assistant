//
//  Old Stats Goalie Selection View.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-03-21.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class Old_Stats_Goalie_Selection_View: UIViewController {

    @IBOutlet weak var hockeyNetImageView: UIImageView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var goalieNumberLabel: UILabel!
    @IBOutlet weak var newGameLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var leftScrollArrowImage: UIImageView!
    @IBOutlet weak var rightScrollArrowImage: UIImageView!
    

    let leftArrowImage = UIImage(named: "left_scroll_arrow")
    let rightArrowImage = UIImage(named: "right_scroll_arrow")
    
    let realm = try! Realm()
    
    var goalieNumberArray: [String] = [String]()
    
    var shotLocationValueSelected: String = "";
    
    var homeTeamID: Int = UserDefaults.standard.integer(forKey: "homeTeam")
    var awayTeamID: Int = UserDefaults.standard.integer(forKey: "awayTeam")
    var currentArrayIndex: Int = 0
    var SeletedGame: Int = UserDefaults.standard.integer(forKey: "gameID")
    var oldStatsGoalieSelection: Bool!
    
    var goalieJerseyNumArray: [String] = [String]()
    var arrayCounter: Int = 0
    
    var tempgoalieSelectedID: Int!
    var goalieSelectedID: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeTeamID = (realm.object(ofType: teamInfoTable.self, forPrimaryKey: realm.object(ofType: newGameTable.self, forPrimaryKey: SeletedGame)?.homeTeamID)?.teamID)!
        
        // add blur effect to view along with popUpView
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.addSubview(popUpView)
        
        popUpView.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
        goalieSelectionGesture()
        
    }
    
    
    func goalieSelectionGesture() {
        
        // get array of Goalie Jersey Nunbers of Page Load
        goalieNumberArray = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType == %@", String(homeTeamID), "G")).value(forKeyPath: "jerseyNum") as! [Int]).compactMap({String($0)})
        
        // set deafult jersey number
        goalieNumberLabel.text = goalieNumberArray[0]
        let selectedGoalieID = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND jerseyNum == %i AND positionType == %@", String(homeTeamID) ,Int(goalieNumberArray.first!)!, "G")).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        tempgoalieSelectedID = selectedGoalieID[0]
        
        hockeyNetImageView.isUserInteractionEnabled = true
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        hockeyNetImageView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        hockeyNetImageView.addGestureRecognizer(swipeLeft)
        
        // default scroll arrow setup
        if (goalieNumberArray.count > 1){
            self.leftScrollArrowImage.image = leftArrowImage
            self.leftScrollArrowImage.alpha = 0.5
            self.leftScrollArrowImage.setNeedsDisplay()
        }else{
            self.leftScrollArrowImage.alpha = 0.5
            self.rightScrollArrowImage.alpha = 0.5
            self.leftScrollArrowImage.setNeedsDisplay()
            self.rightScrollArrowImage.setNeedsDisplay()
        }
    }
    
    //Function for determining when tap gesture is in/outside of touchable area
    
    func goalieNumberArrow(){
        if (self.goalieNumberArray[self.currentArrayIndex] == self.goalieNumberArray.last){
            self.rightScrollArrowImage.image = rightArrowImage
            self.rightScrollArrowImage.alpha = 0.5
            self.leftScrollArrowImage.image = leftArrowImage
            self.leftScrollArrowImage.alpha = 1
            self.leftScrollArrowImage.setNeedsDisplay()
            self.rightScrollArrowImage.setNeedsDisplay()
        }else if (self.goalieNumberArray[self.currentArrayIndex] == self.goalieNumberArray.first){
            self.rightScrollArrowImage.image = rightArrowImage
            self.rightScrollArrowImage.alpha = 1
            self.leftScrollArrowImage.image = leftArrowImage
            self.leftScrollArrowImage.alpha = 0.5
            self.leftScrollArrowImage.setNeedsDisplay()
            self.rightScrollArrowImage.setNeedsDisplay()
        }
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        let realm = try! Realm()
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.left:
                print("Left Swipe Detected")
                print("Goalie Number Array: ", goalieNumberArray)
                if (goalieNumberArray.count > 1){
                    if goalieNumberArray[currentArrayIndex] == goalieNumberArray.first{
                        currentArrayIndex += 1
                        
                    }else if goalieNumberArray[currentArrayIndex] == goalieNumberArray.last{
                        currentArrayIndex = goalieNumberArray.count - 1
                        
                    }else{
                        currentArrayIndex += 1
                    }
                    DispatchQueue.main.async {
                        self.goalieNumberArrow()
                        self.goalieNumberLabel.text = self.goalieNumberArray[self.currentArrayIndex]
                        self.goalieNumberLabel.setNeedsDisplay()
                    }
                    
                    // get selected goalie id based on user selection
                    let selectedGoalieID = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND jerseyNum == %i AND positionType == %@", String(homeTeamID),Int(goalieNumberArray[currentArrayIndex])!, "G")).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
                    tempgoalieSelectedID = selectedGoalieID[0]
                
                }else{
                    // get selected goalie id based on user selection
                    let selectedGoalieID = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND jerseyNum == %i AND positionType == %@", String(homeTeamID),Int(goalieNumberArray[currentArrayIndex])!, "G")).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
                    tempgoalieSelectedID = selectedGoalieID[0]
                
                }
            case UISwipeGestureRecognizer.Direction.right:
                print("Right Swipe Detected")
                if (goalieNumberArray.count > 1){
                    if goalieNumberArray[currentArrayIndex] == goalieNumberArray.last{
                        currentArrayIndex -= 1
                        
                    }else if goalieNumberArray[currentArrayIndex] == goalieNumberArray.first{
                        currentArrayIndex = 0
                        
                    }else{
                        currentArrayIndex -= 1
                    }
                    DispatchQueue.main.async {
                        self.goalieNumberArrow()
                        self.goalieNumberLabel.text = self.goalieNumberArray[self.currentArrayIndex]
                        self.goalieNumberLabel.setNeedsDisplay()
                    }
                    // get selected goalie id based on user selection
                    let selectedGoalieID = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND jerseyNum == %i AND positionType == %@", String(homeTeamID),Int(goalieNumberArray[currentArrayIndex])!, "G")).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
                    tempgoalieSelectedID = selectedGoalieID[0]
                 
                }else{
                    // get selected goalie id based on user selection
                    let selectedGoalieID = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND jerseyNum == %i AND positionType == %@", String(homeTeamID),Int(goalieNumberArray[currentArrayIndex])!, "G")).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
                    tempgoalieSelectedID = selectedGoalieID[0]
                 
                }
            default:
                break
            }
        }
    }
    
    func goalieNameProcessing(){
        
        goalieJerseyNumArray = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType == %@", String(homeTeamID), "G")).value(forKeyPath: "jerseyNum") as! [Int]).compactMap({String($0)})
    }
    
    @IBAction func continueButton(_ sender: Any) {
        UserDefaults.standard.set(tempgoalieSelectedID, forKey: "selectedGoalieID")
       
        let dictionary = ["key":"value"]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "passDataInView"), object: nil, userInfo: dictionary)

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "oldStatsGoalieSelection"), object: nil, userInfo: ["key":"value"])
        dismiss(animated: true, completion: nil)
        //self.performSegue(withIdentifier: "Back_To_Old_Stats_Ice", sender: self)
        
    }
    // on animateIn display popUpview over top of New Game View
    func animateIn(){
        
        print("popUpView has been animated in")
        self.view.addSubview(popUpView)
        popUpView.center = self.view.center
        
        popUpView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        popUpView.alpha = 0
        
        // set animation results
        UIView.animate(withDuration: 0.4){
            self.popUpView.alpha = 1
            self.popUpView.transform = CGAffineTransform.identity
        }
    }
    // on animateOut tear down popUpview over top of New Game View
    func animateOut(){
        
        UIView.animate(withDuration: 0.3, animations: {
            self.popUpView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            self.popUpView.alpha = 0
            // omn sucess of popup tear down remove popUpView from super view
        })  { (success: Bool) in
            self.popUpView.removeFromSuperview()
        }
        print("popUpView has been Teared Down")
    }

}

