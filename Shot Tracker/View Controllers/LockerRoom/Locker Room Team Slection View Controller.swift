//
//  Locker Room Team Slection View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-08-19.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import RealmSwift

class Locker_Room_Team_Slection_View_Controller: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var teamPickerView: UIPickerView!
    @IBOutlet weak var continueButton: UIButton!
    
    var homeTeamPickerData:Results<teamInfoTable>!
    var homeTeamValueSelected:[teamInfoTable] = []
    var selectedTeamID: Int!
    var selectedHomeTeam: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("hi")
        
        let realm = try! Realm()
        
        // data translation from realm to local view controller array
        self.homeTeamPickerData =  realm.objects(teamInfoTable.self)
        self.homeTeamValueSelected = Array(self.homeTeamPickerData)

        self.teamPickerView.delegate = self
        self.teamPickerView.dataSource = self
        
        // round corners of continue button
        roundedCorners().buttonBottomDouble(bottonViewType: continueButton)
        // round corner of popup view
        self.view.layer.cornerRadius = 10
        
        onLoad()
    }
    
    func onLoad(){
        // default team selection
        selectedTeamID = homeTeamValueSelected[0].teamID;
        
         if homeTeamValueSelected.count == 0{
            continueButton.isUserInteractionEnabled = false
            continueButton.alpha = 0.5
        }
       
    }
   
    

    @IBAction func continueButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "openLockerRoomSegue", sender: nil)
        
    }
    
    
    func numberOfComponents(in homeTeamPickerView: UIPickerView) -> Int  {
        return 1;
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if homeTeamValueSelected.count == 0{
            return 1
        }else{
            return homeTeamValueSelected.count
        };
        
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if homeTeamValueSelected.count == 0{
            return "Whoops no Teams, Add One!"
        }else{
             return homeTeamValueSelected[row].nameOfTeam;
        }
        
        
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        if homeTeamValueSelected.count != 0{
            
            selectedHomeTeam = homeTeamValueSelected[row].nameOfTeam;
            selectedTeamID = homeTeamValueSelected[row].teamID;
        }
        
        
    }
    
    // func used to pass varables on segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check is appropriate segue is being used
        if (segue.identifier == "openLockerRoomSegue"){
            // set var vc as destination segue
            let vc = segue.destination as! LockerRoom_View_Controller
            vc.passedTeamID = selectedTeamID
            
        }
    }
    
}
