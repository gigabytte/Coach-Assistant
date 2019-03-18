//
//  New Game Basic Info Page.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-02-21.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class New_Game_Basic_Info_Page: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var hockeyNetImageView: UIImageView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var goalieNumberLabel: UILabel!
    @IBOutlet weak var newGameLabel: UILabel!
    @IBOutlet weak var periodSelectionErrorLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var leftScrollArrowImage: UIImageView!
    @IBOutlet weak var rightScrollArrowImage: UIImageView!
    
    let basicHockeyNet = UIImage(named: "hockey_net_period_basic.PNG")
    let hockeyNetPeriodOne = UIImage(named: "hockey_net_period_one.PNG")
    let hockeyNetPeriodTwo = UIImage(named: "hockey_net_period_two.PNG")
    let hockeyNetPeriodThree = UIImage(named: "hockey_net_period_three.PNG")
    let leftArrowImage = UIImage(named: "left_scroll_arrow")
    let rightArrowImage = UIImage(named: "right_scroll_arrow")
    
    let realm = try! Realm()
    
    var goalieNumberArray: [String] = [String]()
    
    var shotLocationValueSelected: String = "";
    
    var tempXCords: Int = 0
    var tempYCords: Int = 0
    var homeTeamID: Int!
    var awayTeamID: Int!
    var currentArrayIndex: Int = 0
    var newGameStarted: Bool!
    var setPeriodVar: Int!
    
    var goalieJerseyNumArray: [String] = [String]()
    var arrayCounter: Int = 0
    
    var tempMarkerType: Bool!
    var tempPeriodNumSelected: Int!
    
    var tempgoalieSelectedID: Int!
    
    var periodOne: CGRect?
    var periodTwo: CGRect?
    var periodThree: CGRect?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // add blur effect to view along with popUpView
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.addSubview(popUpView)
        view.addSubview(goalieNumberLabel)
        
        periodSelectionErrorLabel.isHidden = true
        popUpView.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
        
        // MUST SET ON EACH VIEW DEPENDENT ON ORIENTATION NEEDS
        // get rotation allowances of device
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // set auto rotation to false
        appDelegate.shouldRotate = false
        
        newGameStartedViewRender()
        goalieSelectionGesture()
        netImageViewBoundaries()
    }
    func newGameStartedViewRender(){
        
        if(newGameStarted != false){
            // dynamically change button layour based on users first new game attempt
            newGameLabel.isHidden = false
            cancelButton.isHidden = true
            cancelButton.isEnabled = false
            continueButton.leadingAnchor.constraint(equalTo: popUpView.leadingAnchor)
            continueButton.widthAnchor.constraint(equalToConstant: 484).isActive = true
            continueButton.titleLabel?.textAlignment = .center
            hockeyNetImageView.bottomAnchor.constraint(equalTo: continueButton.topAnchor)

        }else{
            newGameLabel.isHidden = true
            cancelButton.isEnabled = true
            continueButton.leadingAnchor.constraint(equalTo: cancelButton.leadingAnchor)
            continueButton.widthAnchor.constraint(equalToConstant: 230).isActive = true
            continueButton.titleLabel?.textAlignment = .center
            hockeyNetImageView.bottomAnchor.constraint(equalTo: continueButton.topAnchor)
        }
    }
    
    func missingSelectionError(){
        //produce shake animation on error of double home team
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.06
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = CGPoint(x: popUpView.center.x - 10, y: popUpView.center.y)
        animation.toValue = CGPoint(x: popUpView.center.x + 10, y: popUpView.center.y)
        popUpView.layer.add(animation, forKey: "position")
        // enable team election error text from hidden to appear
        periodSelectionErrorLabel.isHidden = false
    }
    

    
    func netImageViewBoundaries(){
        
        hockeyNetImageView.isUserInteractionEnabled = true
        
        let screenWidth = hockeyNetImageView.frame.width
        print(screenWidth)
        let screenHeight = hockeyNetImageView.frame.height
        print(screenHeight)
        
        periodOne = CGRect(x: screenWidth / 6, y: 230,  width: 80,  height: 80)
        periodTwo = CGRect(x: (screenWidth / 2) - 40 , y: 230,  width: 80,  height: 80)
        periodThree = CGRect(x: (screenWidth / 2) + 80, y: 230,  width: 80,  height:80)
        // check Tap gestuires for a single tap
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(netLocationSelectionTap));
        // number of taps require 1
        singleTap.numberOfTapsRequired = 1
        hockeyNetImageView.addGestureRecognizer(singleTap)
        
    }
    
    
    func goalieSelectionGesture() {
        
        // get array of Goalie Jersey Nunbers of Page Load
        goalieNumberArray = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType == %@", String(homeTeamID!), "G")).value(forKeyPath: "jerseyNum") as! [Int]).compactMap({String($0)})
        
        // set deafult jersey number
        goalieNumberLabel.text = goalieNumberArray[0]
        let selectedGoalieID = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "jerseyNum == %i", Int(goalieNumberArray[0])!)).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
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
    @objc func netLocationSelectionTap(sender: UITapGestureRecognizer){
        print(currentArrayIndex)
            self.hockeyNetImageView.reloadInputViews()
            let tapPosition = sender.location(in: self.hockeyNetImageView)
            self.periodSelectionErrorLabel.isHidden = true
        print("Tap Cords for Period Selection: ", tapPosition)
                if self.periodOne!.contains(tapPosition) {
                    DispatchQueue.main.async {
                        self.setPeriodVar = 1
                        self.hockeyNetImageView.image = self.hockeyNetPeriodOne
                        self.hockeyNetImageView.setNeedsDisplay()
                        print("Period 1")
                    }
                }
                else if(self.periodTwo!.contains(tapPosition)) {
                    DispatchQueue.main.async {
                        self.setPeriodVar = 2
                        self.hockeyNetImageView.image = self.hockeyNetPeriodTwo
                        self.hockeyNetImageView.setNeedsDisplay()
                        print("Period 2")
                    }
                    
                }else if(self.periodThree!.contains(tapPosition)){
                    DispatchQueue.main.async {
                        self.setPeriodVar = 3
                        self.hockeyNetImageView.image = self.hockeyNetPeriodThree
                        self.hockeyNetImageView.setNeedsDisplay()
                        print("Period 3")
                    }
                }else{
                    DispatchQueue.main.async {
                    self.setPeriodVar = nil
                    self.hockeyNetImageView.image = self.basicHockeyNet
                    self.hockeyNetImageView.setNeedsDisplay()
                    print("Error! No Tape Detected")
                    }
                }
        }
    
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
                print("Goalie Nu,ber Array: ", goalieNumberArray)
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
                
                let selectedGoalieID = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "jerseyNum == %i", Int(goalieNumberArray[currentArrayIndex])!)).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
                tempgoalieSelectedID = selectedGoalieID[0]
                print("goalie id: ", tempgoalieSelectedID)
                }else{
                    let selectedGoalieID = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "jerseyNum == %i", Int(goalieNumberArray[0])!)).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
                    tempgoalieSelectedID = selectedGoalieID[0]
                    print("goalie id: ", tempgoalieSelectedID)
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
                    let selectedGoalieID = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "jerseyNum == %i", Int(goalieNumberArray[currentArrayIndex])!)).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
                    tempgoalieSelectedID = selectedGoalieID[0]
                    print("goalie id: ", tempgoalieSelectedID)
                }else{
                    let selectedGoalieID = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "jerseyNum == %i", Int(goalieNumberArray[0])!)).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
                    tempgoalieSelectedID = selectedGoalieID[0]
                    print("goalie id: ", tempgoalieSelectedID)
                }
            default:
                break
            }
        }
    }
    
    func goalieNameProcessing(){
        
        goalieJerseyNumArray = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType == %@", String(homeTeamID!), "G")).value(forKeyPath: "jerseyNum") as! [Int]).compactMap({String($0)})
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        animateOut()
        self.performSegue(withIdentifier: "cancelBasicInfoSegue", sender: nil);
    }
    
    @IBAction func continueButton(_ sender: Any) {
        if(setPeriodVar != nil){
            tempPeriodNumSelected = setPeriodVar
            animateOut()
            self.performSegue(withIdentifier: "continueBasicInfoSegue", sender: nil);
        }else{
            missingSelectionError()
            
        }
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
    
    // func used to pass varables on segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check is appropriate segue is being used
        if (segue.identifier == "cancelBasicInfoSegue" || segue.identifier == "continueBasicInfoSegue"){
            // set var vc as destination segue
            let vc = segue.destination as! New_Game_Page
            print(tempgoalieSelectedID)
            vc.newGameStarted = false
            vc.periodNumSelected = tempPeriodNumSelected
            vc.goalieSelectedID = tempgoalieSelectedID
        }
    }
}

