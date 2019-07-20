//
//  In Game Settings ViewController.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-06-14.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit

class In_Game_Settings_ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var inGameLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var goalSwitch: UISwitch!
    @IBOutlet weak var shotSwitch: UISwitch!
    @IBOutlet weak var penaltySwitch: UISwitch!
    @IBOutlet weak var penaltyLengthPicker: UIPickerView!
    @IBOutlet weak var penaltyTypeSegCon: UISegmentedControl!
    
    var penaltyValueSelected: Int!
    var penaltyLengthData: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add blur effect to view along with popUpView
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.addSubview(popUpView)
        
        popUpView.layer.cornerRadius = 10
        roundedCorners().labelViewTopLeftRight(labelViewType: inGameLabel)
        roundedCorners().buttonBottomDouble(bottonViewType: saveButton)
        
        self.penaltyLengthPicker.dataSource = self
        self.penaltyLengthPicker.delegate = self
        
        // set default values
        penaltyValueSelected = UserDefaults.standard.integer(forKey: "temp_minorPenaltyLength")
        goalSwitch.isOn = UserDefaults.standard.bool(forKey: "displayGoalBool")
        shotSwitch.isOn = UserDefaults.standard.bool(forKey: "displayShotBool")
        penaltySwitch.isOn = UserDefaults.standard.bool(forKey: "displayPenaltyBool")
        
        // set seg con position based on user default
        penaltyLengthPicker.selectRow(penaltyValueSelected - 1, inComponent: 0, animated: true)
    }
    

    @IBAction func saveButton(_ sender: UIButton) {
        // set user defaults based on selection in view
        UserDefaults.standard.set(goalSwitch.isOn, forKey: "displayGoalBool")
        UserDefaults.standard.set(shotSwitch.isOn, forKey: "displayShotBool")
        UserDefaults.standard.set(penaltySwitch.isOn, forKey: "displayPenaltyBool")
        if (penaltyTypeSegCon.selectedSegmentIndex == 0){
            UserDefaults.standard.set(penaltyValueSelected, forKey: "temp_minorPenaltyLength")
        }else{
            UserDefaults.standard.set(penaltyValueSelected, forKey: "temp_majorPenaltyLength")
        }
        let dictionary = ["key":"value"]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "shotLocationRefresh"), object: nil, userInfo: dictionary)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func helpButon(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "Need Some Help?", message: "In Game Settings allows for the disabling / enabling of elements residing on the Ice Surface of your current game along with live game attributes such as penalty minutes and more. These attributes do not reflect your global settings.", preferredStyle: .actionSheet)
        
        // tapp anywhere outside of popup alert controller
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in
            print("didPress Cancel")
        })
        // Add the actions to your actionSheet
        actionSheet.addAction(cancelAction)
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.popUpView
            popoverController.sourceRect = CGRect(x: helpButton.frame.origin.x, y: helpButton.frame.origin.y, width: helpButton.frame.width / 2, height: helpButton.frame.height)
            
        }
        // Present the controller
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func penaltyTypeSegCon(_ sender: Any) {
        // change default penalty length based on previously set user default
        if (penaltyTypeSegCon.selectedSegmentIndex == 0){
            penaltyLengthPicker.selectRow(UserDefaults.standard.integer(forKey: "temp_minorPenaltyLength") - 1, inComponent: 0, animated: true)
        }else{
            penaltyLengthPicker.selectRow(UserDefaults.standard.integer(forKey: "temp_majorPenaltyLength") - 1, inComponent: 0, animated: true)
        }
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
        
        return penaltyLengthData.count
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        return String(penaltyLengthData[row])
        
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        penaltyValueSelected = penaltyLengthData[row]
    }
    
    
}
