//
//  Settings Defaults Team Defaults.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-08-22.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import RealmSwift

class Settings_Defaults_Team_Defaults: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    var homeTeamPickerData: [String] = [String]()
    var homeTeamPickerDataID: [Int] = [Int]()
    var homeTeamValueSelected: Int!
    var selectedHomeTeam: String = ""
    var selectedHomeTeamKey:Int = 0;
    var newGameLoad: Bool!
    
    @IBOutlet weak var homeTeamPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.homeTeamPicker.delegate = self
        self.homeTeamPicker.dataSource = self

        // Do any additional setup after loading the view.
        onLoad()
       
    }
    
    func onLoad(){
        let realm = try! Realm()
        
        if ((UserDefaults.standard.object(forKey: "defaultHomeTeamID")) != nil){
            homeTeamPickerData = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "activeState == %@", NSNumber(value: true))).value(forKeyPath: "nameOfTeam") as! [String]).compactMap({String($0)})
            homeTeamPickerDataID = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "activeState == %@", NSNumber(value: true))).value(forKeyPath: "teamID") as! [Int]).compactMap({Int($0)})
            
            // default home team and away team selection
            selectedHomeTeam = homeTeamPickerData[0]
            selectedHomeTeamKey = homeTeamPickerDataID[0]
            // auto scroll picker view to default team
            homeTeamPicker.selectRow(homeTeamPickerDataID.firstIndex(of: UserDefaults.standard.integer(forKey: "defaultHomeTeamID"))!, inComponent: 0, animated: true)
        }else{
            
            // disable picker and addd button
            homeTeamPicker.alpha = 0.5
            homeTeamPicker.isUserInteractionEnabled = false
            
            homeTeamPickerData = ["No Teams"]
            
        }
        viewColour()
    }
    func viewColour(){
        
        self.view.backgroundColor = systemColour().viewColor()
        
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //-------------------------------------------------------------------------------
    // Picker View Functions for Home and Away Team Picking
    // Number of columns of data
    func numberOfComponents(in homeTeamPickerView: UIPickerView) -> Int  {
        return 1;
    }
    // height of picker views defined here
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50.0
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
    
        UserDefaults.standard.set(homeTeamPickerDataID[row], forKey: "defaultHomeTeamID")
        
        
    }
    
   
}
