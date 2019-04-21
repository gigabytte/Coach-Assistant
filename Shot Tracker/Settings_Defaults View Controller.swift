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
    var homeTeamValueSelected: Int!
    var selectedHomeTeam: String = ""
    var selectedHomeTeamKey:Int = 0;
    var newGameLoad: Bool!
    
    @IBOutlet weak var homeTeamPicker: UIPickerView!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // round corner of save button
        saveButton.layer.cornerRadius = 5
        
        // Data Connections for picker views:
        self.homeTeamPicker.delegate = self
        self.homeTeamPicker.dataSource = self
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
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("Defaults View Controller Called")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("Defaults View Controller Called")
    }
    
    @IBAction func continueButton(_ sender: UIButton) {
        if ((UserDefaults.standard.object(forKey: "defaultHomeTeamID")) != nil){
            if (newGameLoad == true){
                UserDefaults.standard.set(selectedHomeTeamKey, forKey: "defaultHomeTeamID")
                //self.performSegue(withIdentifier: "backToHomeDefaultTeam", sender: nil);
            }else{
                UserDefaults.standard.set(selectedHomeTeamKey, forKey: "defaultHomeTeamID")
                //self.performSegue(withIdentifier: "backToSettingsDefaultTeam", sender: nil);
                
            }
        }else{
            //MARK present alrt to user no teams present in app
            print("No Teams Error Present")
            noTeamAlert()
            
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
        
        
        return homeTeamPickerData.count;
        
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return homeTeamPickerData[row];
        
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        
        selectedHomeTeam = homeTeamPickerData[row];
        selectedHomeTeamKey = homeTeamPickerDataID[row];
        
        
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
