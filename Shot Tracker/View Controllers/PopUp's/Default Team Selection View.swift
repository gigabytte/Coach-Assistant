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

class Default_Team_Selection_View: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIPopoverPresentationControllerDelegate {
   
    
    
    var homeTeamPickerData: [String] = [String]()
    var homeTeamPickerDataID: [Int] = [Int]()
    var homeTeamValueSelected: Int!
    var selectedHomeTeamKey:Int = 0;
    var newGameLoad: Bool!
    
    @IBOutlet weak var addNewTeamButon: UIButton!
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
        
       
        onLoad()
        
    }
    
    func onLoad(){
        let realm = try! Realm()
        
        homeTeamPickerData = (realm.objects(teamInfoTable.self).value(forKeyPath: "nameOfTeam") as! [String]).compactMap({String($0)})
        homeTeamPickerDataID = (realm.objects(teamInfoTable.self).value(forKeyPath: "teamID") as! [Int]).compactMap({Int($0)})
        
        // default home team selection
        selectedHomeTeamKey = homeTeamPickerDataID[0]
        
        if checkUserDefaults().isKeyPresentInUserDefaults(key: "defaultHomeTeamID") == true{
            if (String(UserDefaults.standard.integer(forKey: "defaultHomeTeamID")) != ""){
                let index = homeTeamPickerDataID.firstIndex(of: UserDefaults.standard.integer(forKey: "defaultHomeTeamID"))!
                homeTeamPicker.selectRow(index, inComponent: 0, animated: true)
            }
        }
        
        viewColour()
        
    }
    
    func viewColour(){
        
        self.popUpView.backgroundColor = systemColour().viewColor()
        continueButton.backgroundColor = systemColour().uiButton()
        
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
        
        if selectedHomeTeamKey != UserDefaults.standard.integer(forKey: "defaultHomeTeamID"){
            UserDefaults.standard.set(selectedHomeTeamKey, forKey: "defaultHomeTeamID")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "homePageRefresh"), object: nil, userInfo: ["key":"value"])
        }
        self.dismiss(animated: true, completion: nil)
      
    }
    
    @IBAction func addNewTeamName(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "menuBtnPress"), object: nil, userInfo: ["btnNumber":2])
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addVC_menuBtnPress"), object: nil, userInfo: ["btnNumber":1])
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
