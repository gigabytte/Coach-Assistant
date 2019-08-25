//
//  Settings Defaults Penalty Defaults.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-08-22.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

class Settings_Defaults_Penalty_Defaults: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var penaltyLengthData: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9]
    var selectedPenaltyTimeAmount: Int!
    
    @IBOutlet weak var penaltySegControl: UISegmentedControl!
    @IBOutlet weak var penaltyLengthPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.penaltyLengthPicker.delegate = self
        self.penaltyLengthPicker.dataSource = self
        
        selectedPenaltyTimeAmount = 1

        // Do any additional setup after loading the view.
        onLoad()
    }
    

    func onLoad(){
        if (penaltySegControl.selectedSegmentIndex == 0){
            // set picker position based on user default
            penaltyLengthPicker.selectRow(UserDefaults.standard.integer(forKey: "minorPenaltyLength") - 1, inComponent: 0, animated: true)
        }else{
            // set picker position based on user default
            penaltyLengthPicker.selectRow(UserDefaults.standard.integer(forKey: "majorPenaltyLength") - 1, inComponent: 0, animated: true)
        }
        viewColour()
    }
    func viewColour(){
        
        self.view.backgroundColor = systemColour().viewColor()
    }
    
    @IBAction func penaltySegControl(_ sender: UISegmentedControl) {
        if (penaltySegControl.selectedSegmentIndex == 0){
            // set picker position based on user default
            penaltyLengthPicker.selectRow(UserDefaults.standard.integer(forKey: "minorPenaltyLength") - 1, inComponent: 0, animated: true)
        }else{
            // set picker position based on user default
            penaltyLengthPicker.selectRow(UserDefaults.standard.integer(forKey: "majorPenaltyLength") - 1, inComponent: 0, animated: true)
        }
        
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    func numberOfComponents(in homeTeamPickerView: UIPickerView) -> Int  {
        return 1;
    }
    // height of picker views defined here
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50.0
    }
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return penaltyLengthData.count
        
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return String(penaltyLengthData[row])
        
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
    
        switch penaltySegControl.selectedSegmentIndex {
        case 0:
            UserDefaults.standard.set(penaltyLengthData[row], forKey: "minorPenaltyLength")
            print("Minor Penalty Amount Updated")
            
        case 1:
            UserDefaults.standard.set(penaltyLengthData[row], forKey: "majorPenaltyLength")
            print("Major Penalty Amount Updated")
        default:
            print("Something went wrong!")
        }
 
    }
    
}
