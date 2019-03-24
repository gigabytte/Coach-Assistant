//
//  Default Team Selection View.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-03-23.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class Default_Team_Selection_View: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
   
    let realm = try! Realm()
    
    var homeTeamPickerData: [String] = [String]()
    var homeTeamPickerDataID: [Int] = [Int]()
    var homeTeamValueSelected: Int!
    var selectedHomeTeam: String = ""
    var selectedHomeTeamKey:Int = 0;
    var newGameLoad: Bool!
    
    @IBOutlet weak var homeTeamPicker: UIPickerView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var popUpView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bottomRoundedCorners(buttonName: continueButton)
        // add blur effect to view along with popUpView
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.addSubview(popUpView)
        
        // Data Connections for picker views:
        self.homeTeamPicker.delegate = self
        self.homeTeamPicker.dataSource = self
        
        homeTeamPickerData = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "activeState == %@", NSNumber(value: true))).value(forKeyPath: "nameOfTeam") as! [String]).compactMap({String($0)})
        homeTeamPickerDataID = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "activeState == %@", NSNumber(value: true))).value(forKeyPath: "teamID") as! [Int]).compactMap({Int($0)})
        
        // default home team and away team selection
        selectedHomeTeam = homeTeamPickerData[0]
        selectedHomeTeamKey = homeTeamPickerDataID[0]
        //round corners with a radius of 10 for popup view so my eyes dont bleed!
        popUpView.layer.cornerRadius = 10
    }
    func bottomRoundedCorners(buttonName: UIButton){
    
        let path = UIBezierPath(roundedRect:buttonName.bounds, byRoundingCorners:[.bottomRight, .bottomLeft], cornerRadii: CGSize(width: 10, height: 10))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        buttonName.layer.mask = maskLayer
        
    }

    @IBAction func continueButton(_ sender: UIButton) {
        if (newGameLoad == true){
            UserDefaults.standard.set(selectedHomeTeamKey, forKey: "defaultHomeTeamID")
            self.performSegue(withIdentifier: "backToHomeDefaultTeam", sender: nil);
        }else{
            UserDefaults.standard.set(selectedHomeTeamKey, forKey: "defaultHomeTeamID")
            self.performSegue(withIdentifier: "backToSettingsDefaultTeam", sender: nil);
            
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
