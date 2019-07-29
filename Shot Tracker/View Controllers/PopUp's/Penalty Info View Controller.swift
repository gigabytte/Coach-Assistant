//
//  Penalty Info View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-07-26.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import RealmSwift

class Penalty_Info_View_Controller: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var penaltyPicker: UIPickerView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var currentGameID: Int = UserDefaults.standard.integer(forKey: "gameID")
    var againstTeamID: Int!
    var selectedPenaltyID: Int!
    
    var penaltyIDArray: [Int] = [Int]()
    var playerIDArray: [Int] = [Int]()
    var playerNameArray: [String] = [String]()
    var timeOfInfractionArray: [String] = [String]()
    var penaltyInfoCollectionArray: [String] = [String]()
    
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // round corners of elemnts in popup 
        popUpView.layer.cornerRadius = 10
        roundedCorners().buttonBottomLeft(bottonViewType: cancelButton)
        roundedCorners().buttonBottomRight(bottonViewType: continueButton)
        roundedCorners().labelViewTopLeftRight(labelViewType: titleLabel)
        
        // give background blur effect
        // add blur effect to view along with popUpView
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.addSubview(popUpView)
        
        gatherPenaltyInfo()
        
        if penaltyIDArray.isEmpty != true{
            selectedPenaltyID = penaltyIDArray.first
        }else{
            penaltyInfoCollectionArray.append("No Data Found!")
            penaltyPicker.isUserInteractionEnabled = false
            continueButton.isUserInteractionEnabled = false
            continueButton.alpha = 0.5
            selectedPenaltyID = 0
        }
        
        // Data Connections for picker views:
        self.penaltyPicker.delegate = self
        self.penaltyPicker.dataSource = self
        
        print("selected penalty \(selectedPenaltyID)")
    }
    

    @IBAction func continueButon(_ sender: Any){
       
        if let vc = presentingViewController as? Marker_Info_Page{
            vc.selectedPenaltyID = selectedPenaltyID
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        // dismiss popup back back to parent view aka goal marker info VC
        //self.performSegue(withIdentifier: "DismissBacktoGoalMarker", sender: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "noPenaltyToggle"), object: nil, userInfo: ["key":"value"])
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func gatherPenaltyInfo(){
        
        penaltyIDArray = (realm.objects(penaltyTable.self).filter(NSPredicate(format: "gameID == %i AND teamID == %i AND activeState == %@",currentGameID, againstTeamID, NSNumber(value: true))).value(forKeyPath: "penaltyID") as! [Int]).compactMap({Int($0)})
        
        
        
        for x in 0..<penaltyIDArray.count{
            
            let playerIDArray = (realm.objects(penaltyTable.self).filter(NSPredicate(format: "penaltyID == %i AND activeState == %@",penaltyIDArray[x], NSNumber(value: true))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)}).first
            
            let playerName = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == %@",playerIDArray!, NSNumber(value: true))).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)}).first
            
            playerNameArray.append(playerName!)
            
            let infractionTime = (realm.objects(penaltyTable.self).filter(NSPredicate(format: "penaltyID == %i AND activeState == %@",penaltyIDArray[x], NSNumber(value: true))).value(forKeyPath: "timeOfOffense") as! [Date]).first
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            // append new string type array element to newGameData array
            timeOfInfractionArray.append(dateFormatter.string(from: infractionTime!))
            
            let penaltyType = (realm.objects(penaltyTable.self).filter(NSPredicate(format: "penaltyID == %i AND activeState == %@",penaltyIDArray[x], NSNumber(value: true))).value(forKeyPath: "penaltyType") as! [String]).compactMap({String($0)}).first
            
            let playerNumber = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == %@",playerIDArray!, NSNumber(value: true))).value(forKeyPath: "jerseyNum") as! [Int]).compactMap({String($0)}).first
           
            // glue to elements togther
            penaltyInfoCollectionArray.append("\(penaltyType!) commited by \(playerNameArray[x]) #\(playerNumber!) at \(timeOfInfractionArray[x])")
            
        }
        
        
    }
    
    
    //-------------------------------------------------------------------------------
    // Picker View Functions for Penalty Event Picking
    // Number of columns of data
    func numberOfComponents(in homeTeamPickerView: UIPickerView) -> Int  {
        return 1;
    }
    // height of picker views defined here
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        
        return penaltyInfoCollectionArray.count;
        
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return penaltyInfoCollectionArray[row];
        
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        
        selectedPenaltyID = penaltyIDArray[row];
    
    }
    //----------------------------------------------------------------------------
    
}
