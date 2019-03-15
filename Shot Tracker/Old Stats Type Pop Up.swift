//
//  Old Stats Type Pop Up.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-03-15.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class Old_Stats_Type_Pop_Up: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var playerStatsButton: UIButton!
    @IBOutlet weak var oldStatsButton: UIButton!
    @IBOutlet weak var teamPickerView: UIPickerView!
    
    var playerButtonCon: NSLayoutConstraint?
    var oldStatsButtonCon: NSLayoutConstraint?
    
    var homeTeamPickerData:Results<teamInfoTable>!
    var homeTeamValueSelected:[teamInfoTable] = []
    var selectedTeamID: Int!
    var selectedHomeTeam: String = ""
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.teamPickerView.delegate = self
        self.teamPickerView.dataSource = self
        
        // data translation from realm to local view controller array
        self.homeTeamPickerData =  realm.objects(teamInfoTable.self)
        self.homeTeamValueSelected = Array(self.homeTeamPickerData)
        
        teamPickerView.isHidden = true
        // round corners of popup view
        popUpView.layer.cornerRadius = 10
        bottomRoundedCorners()
        buttonBorder(updateBool: false)
        
    }
    
    func animationOnButtonCLick(reverseAnimateBool: Bool){
        
        if(reverseAnimateBool != true){
            UIView.animate(withDuration: 1) {
                self.playerButtonCon = self.playerStatsButton.widthAnchor.constraint(equalToConstant: 400.0)
                self.playerButtonCon!.isActive = true
                self.oldStatsButtonCon = self.oldStatsButton.widthAnchor.constraint(equalToConstant: 87.0)
                self.oldStatsButtonCon!.isActive = true
                self.view.layoutIfNeeded()
                self.buttonBorder(updateBool: true)
            }
        }else{
            
            UIView.animate(withDuration: 1) {
                self.playerButtonCon!.isActive = false
                self.oldStatsButtonCon!.isActive = false
                self.playerStatsButton.widthAnchor.constraint(equalToConstant: 242.0).isActive = true
                self.oldStatsButton.widthAnchor.constraint(equalToConstant: 242.0).isActive = true
                self.view.layoutIfNeeded()
                self.buttonBorder(updateBool: false)
            
            }
        }
    }
    
    func bottomRoundedCorners(){
        
        // round bottom corners of button
        let path = UIBezierPath(roundedRect:cancelButton.bounds, byRoundingCorners:[.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 10, height: 10))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        cancelButton.layer.mask = maskLayer
    }
    
    func buttonBorder(updateBool: Bool){
        if(updateBool != true){
            let topBorder = CALayer()
            if (self.playerStatsButton.layer.sublayers?.isEmpty == false){
                self.playerStatsButton.layer.sublayers?[0].removeFromSuperlayer()
                self.playerStatsButton.setNeedsDisplay()
                
            }
            
            topBorder.borderColor = UIColor.lightGray.cgColor;
            topBorder.borderWidth = 2;
            topBorder.frame = CGRect(x: playerStatsButton.frame.width, y: 0, width: 1, height: playerStatsButton.frame.height)
            playerStatsButton.layer.addSublayer(topBorder)
            self.playerStatsButton.layer.insertSublayer(topBorder, at: 0)
            self.playerStatsButton.setNeedsDisplay()
            print(self.playerStatsButton.layer.sublayers)
        }else{
            delay(0.5){
                let topBorder = CALayer()
                if (self.playerStatsButton.layer.sublayers?.isEmpty == false){
                    self.playerStatsButton.layer.sublayers?[0].removeFromSuperlayer()
                    self.playerStatsButton.setNeedsDisplay()
                }
                topBorder.borderColor = UIColor.lightGray.cgColor;
                topBorder.borderWidth = 2;
                topBorder.frame = CGRect(x: self.playerStatsButton.frame.width, y: 0, width: 1, height: self.playerStatsButton.frame.height)
                self.playerStatsButton.layer.addSublayer(topBorder)
                self.playerStatsButton.layer.insertSublayer(topBorder, at: 0)
                self.playerStatsButton.setNeedsDisplay()
                print(self.playerStatsButton.layer.sublayers)
            
            }
        }
       
    }
    func numberOfComponents(in homeTeamPickerView: UIPickerView) -> Int  {
        return 1;
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //return homeTeamValueSelected.count;
        
        return homeTeamValueSelected.count;
        
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return homeTeamValueSelected[row].nameOfTeam;
       
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        selectedHomeTeam = homeTeamValueSelected[row].nameOfTeam;
        selectedTeamID = homeTeamValueSelected[row].teamID;
        
    }
    
    @IBAction func playerStatsButtonPress(_ sender: UIButton) {
        animationOnButtonCLick(reverseAnimateBool: false)
        playerStatsButton.setTitle("Please Select Team", for: UIControl.State.normal)
        cancelButton.setTitle("Continue", for: UIControl.State.normal)
        oldStatsButton.setTitle("Back", for: UIControl.State.normal)
        teamPickerView.isHidden = false
    }
    
    @IBAction func oldStatsButton(_ sender: UIButton) {
        let buttonTitle = sender.title(for: .normal)
        if  buttonTitle == "Back"{
            animationOnButtonCLick(reverseAnimateBool: true)
            oldStatsButton.setTitle("Old Stats", for: UIControl.State.normal)
             cancelButton.setTitle("Cancel", for: UIControl.State.normal)
            teamPickerView.isHidden = true
            
        }
    }
        
    
    @IBAction func cancelButton(_ sender: UIButton) {
        
        let buttonTitle = sender.title(for: .normal)
        if  buttonTitle == "Continue"{
            self.performSegue(withIdentifier: "overallPlayerStatsSegue", sender: nil);
        }else{
            
            self.performSegue(withIdentifier: "backToMainVC", sender: nil);
        }
        
    }
    // func used to pass varables on segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check is appropriate segue is being used
        if (segue.identifier == "overallPlayerStatsSegue"){
            // set var vc as destination segue
            let vc = segue.destination as! Overall_Player_Stats_View
            vc.homeTeamID = selectedTeamID
            
        }
    }
    
    // delay loop
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
}
