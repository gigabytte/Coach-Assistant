//
//  Settings_Defaults View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-19.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

final class Settings_Defaults_View_Controller: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    let realm = try! Realm()
    
    var homeTeamPickerData: [String] = [String]()
    var homeTeamPickerDataID: [Int] = [Int]()
    var penaltyLengthData: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9]
    var homeTeamValueSelected: Int!
    var selectedHomeTeam: String = ""
    var selectedHomeTeamKey:Int = 0;
    var selectedPenaltyTimeAmount: Int!
    var newGameLoad: Bool!
    
    @IBOutlet weak var homeTeamPicker: UIPickerView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var penaltyLengthPicker: UIPickerView!
    @IBOutlet weak var savePenaltyButton: UIButton!
    @IBOutlet weak var penaltySegControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // round corner of save button
        saveButton.layer.cornerRadius = 5
        savePenaltyButton.layer.cornerRadius = 5
        
        // Data Connections for picker views:
        self.homeTeamPicker.delegate = self
        self.homeTeamPicker.dataSource = self
        self.penaltyLengthPicker.delegate = self
        self.penaltyLengthPicker.dataSource = self
        
        selectedPenaltyTimeAmount = 1
        
        if ((UserDefaults.standard.object(forKey: "defaultHomeTeamID")) != nil){
            homeTeamPickerData = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "activeState == %@", NSNumber(value: true))).value(forKeyPath: "nameOfTeam") as! [String]).compactMap({String($0)})
            homeTeamPickerDataID = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "activeState == %@", NSNumber(value: true))).value(forKeyPath: "teamID") as! [Int]).compactMap({Int($0)})
        
            // default home team and away team selection
            selectedHomeTeam = homeTeamPickerData[0]
            selectedHomeTeamKey = homeTeamPickerDataID[0]
        }else{

            // disable picker and addd button
            homeTeamPicker.alpha = 0.5
            saveButton.alpha = 0.7
            homeTeamPicker.isUserInteractionEnabled = false
            
            homeTeamPickerData = ["No Teams"]
            
        }
        
        // set picker position based on user default
        penaltyLengthPicker.selectRow(UserDefaults.standard.integer(forKey: "minorPenaltyLength") - 1, inComponent: 0, animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("Defaults View Controller Called")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("Defaults View Controller Called")
    }
    @IBAction func penaltySegCon(_ sender: Any) {
        if (penaltySegControl.selectedSegmentIndex == 0){
            // set picker position based on user default
            penaltyLengthPicker.selectRow(UserDefaults.standard.integer(forKey: "minorPenaltyLength") - 1, inComponent: 0, animated: true)
        }else{
            // set picker position based on user default
            penaltyLengthPicker.selectRow(UserDefaults.standard.integer(forKey: "majorPenaltyLength") - 1, inComponent: 0, animated: true)
        }
    }
    
    @IBAction func continueButton(_ sender: UIButton) {
        if ((UserDefaults.standard.object(forKey: "defaultHomeTeamID")) != nil){
            if (newGameLoad == true){
                UserDefaults.standard.set(selectedHomeTeamKey, forKey: "defaultHomeTeamID")
                updateAlert(varTypeUpdated: "Default Team", varupdatedTo: selectedHomeTeam)
            }else{
                UserDefaults.standard.set(selectedHomeTeamKey, forKey: "defaultHomeTeamID")
                updateAlert(varTypeUpdated: "Default Team", varupdatedTo: selectedHomeTeam)
                
            }
        }else{
            //MARK present alrt to user no teams present in app
            print("No Teams Error Present")
            noTeamAlert()
            
        }
    }
    
    @IBAction func savePenaltyLengthButton(_ sender: UIButton) {
        switch penaltySegControl.selectedSegmentIndex {
        case 0:
            UserDefaults.standard.set(selectedPenaltyTimeAmount, forKey: "minorPenaltyLength")
            print("Minor Penalty Amount Updated")
            updateAlert(varTypeUpdated: "Minor Penalty", varupdatedTo: "\(selectedPenaltyTimeAmount!) minute long")
            
        case 1:
            UserDefaults.standard.set(selectedPenaltyTimeAmount, forKey: "majorPenaltyLength")
            print("Major Penalty Amount Updated")
            updateAlert(varTypeUpdated: "Major Penalty", varupdatedTo: "\(selectedPenaltyTimeAmount!) minute long")
        default:
            print("Something went wrong!")
        }
        
    }
    
    func noTeamAlert(){
        
        // create the alert
        let noTeamsAlert = UIAlertController(title: "Data Error", message: "Please add atleast one team before attempting to change your default team.", preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        noTeamsAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(noTeamsAlert, animated: true, completion: nil)
    }
    
    //-------------------------------------------------------------------------------
    // Picker View Functions for Home and Away Team Picking
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
        
        if (pickerView == homeTeamPicker){
            return homeTeamPickerData.count;
        }else{
            return penaltyLengthData.count
        }
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        
        if (pickerView == homeTeamPicker){
            return homeTeamPickerData[row];
        }else{
            return String(penaltyLengthData[row])
        }
        
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
         if (pickerView == homeTeamPicker){
            selectedHomeTeam = homeTeamPickerData[row];
            selectedHomeTeamKey = homeTeamPickerDataID[row];
         }else{
            selectedPenaltyTimeAmount = penaltyLengthData[row]
        }
        
        
    }
    
    func updateAlert(varTypeUpdated: String, varupdatedTo: String){
        
        // create the alert
        let updateAlert = UIAlertController(title: "\(varTypeUpdated) has been successfully updated to \(varupdatedTo)", message: "", preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        updateAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(updateAlert, animated: true, completion: nil)
    }
    
    // delay loop
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    // func used to pass varables on segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check is appropriate segue is being used
        if (segue.identifier == "addTeamSegueFromMain"){
            // set var vc as destination segue
            let vc = segue.destination as! Add_Team_Page
            vc.noTeamsBool = true
        }
    }

}
