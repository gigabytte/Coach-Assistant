//
//  Initial_Setup_Player_Add_View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-23.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class Initial_Setup_Player_Add_View_Controller: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    
    @IBOutlet weak var playerProfileImageView: UIImageView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var proceedArrow: UIImageView!
    @IBOutlet weak var playerNameTextField: UITextField!
    @IBOutlet weak var playerNumberTextField: UITextField!
    @IBOutlet weak var playerPositionPicker: UIPickerView!
    @IBOutlet weak var playerLinePicker: UIPickerView!
    @IBOutlet weak var viewControllerTitle: UILabel!
    
    var pickerData:[String] = [String]()
    var forwardPositionData:[String] = [String]()
    var defensePositionData:[String] = [String]()
    var goaliePositionData:[String] = [String]()
    var positionCodeData:[String] = [String]()
    
    var queryTeamID: Int!
    var primaryPlayerID: Int!
    var selectPlayerLine: Int!
    var selectPosition: String!
    var doneHomePlayers: Bool = false
    var userSelectedProfileImage: UIImage!
    
    var imagePickerController : UIImagePickerController!
    
    var blurEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.playerLinePicker.delegate = self
        self.playerLinePicker.dataSource = self
        
        self.playerPositionPicker.delegate = self
        self.playerPositionPicker.dataSource = self
        
        playerNumberTextField.delegate = self
        playerNameTextField.delegate = self
        
        // add blur effect to view along with popUpView
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.addSubview(warningLabel)
        view.addSubview(proceedArrow)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(playerLogoTapped(tapGestureRecognizer:)))
        playerProfileImageView.isUserInteractionEnabled = true
        playerProfileImageView.addGestureRecognizer(tapGestureRecognizer)
        
        // MARK intialize ui elements on load so user cannot leave blank
        // ie. user must complete elements in order to save player successfully
        let alphaStartValue = 0.25
        playerNumberTextField.isUserInteractionEnabled = false
        playerNumberTextField.alpha = CGFloat(alphaStartValue)
        playerPositionPicker.isUserInteractionEnabled = false
        playerPositionPicker.alpha = CGFloat(alphaStartValue)
        playerLinePicker.isUserInteractionEnabled = false
        playerLinePicker.alpha = CGFloat(alphaStartValue)
        
        onLoad()
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if queryTeamID != nil{
            awayTeamAddedChecker()
        }
        
    }
    
    func onLoad(){
        
         let realm = try! Realm()
        
        // Do any additional setup after loading the view.
        pickerData = ["Forward 1", "Forward 2","Forward 3","Defense 1","Defense 2","Defense 3","Goalie"]
        forwardPositionData = ["Left Wing", "Center", "Right Wing"]
        defensePositionData = ["Left Defence", "Right Defence"]
        goaliePositionData = ["Goalie"]
        positionCodeData = ["LW", "C", "RW", "LD", "RD", "G"]
        
        selectPosition = positionCodeData[0]
        selectPlayerLine = 1
        
        queryTeamID = ((realm.objects(teamInfoTable.self).value(forKeyPath: "teamID") as! [Int]).compactMap({Int($0)})).first
        
        // set View COntroller title based on users previous team add
        if queryTeamID != nil {
            let queryTeamName = realm.object(ofType: teamInfoTable.self, forPrimaryKey: queryTeamID)?.nameOfTeam
            viewControllerTitle.text = "Add Players to \((queryTeamName!).capitalized)"
        }
        
        proceedArrow.isHidden = true
        
    }
    
    func profileImageSetter(){
        if userSelectedProfileImage != nil{
            playerProfileImageView.image = userSelectedProfileImage
            playerProfileImageView.setRounded()
        }else{
            playerProfileImageView.image = UIImage(named: "temp_profile_pic_icon")
            playerProfileImageView.setRounded()
        }
        
    }
    
    func teamNameSetter(){
        
        let realm = try! Realm()
        
        queryTeamID = ((realm.objects(teamInfoTable.self).value(forKeyPath: "teamID") as! [Int]).compactMap({Int($0)})).last
        
        // set View COntroller title based on users previous team add
        let queryTeamName = realm.object(ofType: teamInfoTable.self, forPrimaryKey: queryTeamID)?.nameOfTeam
        viewControllerTitle.text = "Add Players to \((queryTeamName!).capitalized)"
       
        
    }
    
    func awayTeamAddedChecker(){
        
        let realm = try! Realm()
        
        if (((realm.objects(teamInfoTable.self).value(forKeyPath: "teamID") as! [Int]).compactMap({Int($0)})).count <= 2){
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                self.blurEffectView.alpha = 0.0
                self.warningLabel.alpha = 0.0
                self.proceedArrow.alpha = 0.0
                
                self.view.layoutIfNeeded()
                
            }, completion: { _ in
                
                self.blurEffectView.isHidden = true
                self.warningLabel.isHidden = true
                self.proceedArrow.isHidden = true
                
                
            })
            
           
        }else{
            self.blurEffectView.isHidden = false
            self.warningLabel.isHidden = false
            self.proceedArrow.isHidden = false
            
            // show warning label / proceed arrow and blur VC if user has not added a team
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                self.blurEffectView.alpha = 1.0
                self.warningLabel.alpha = 1.0
                self.proceedArrow.alpha = 1.0
                
                self.view.layoutIfNeeded()
                
            }, completion: { _ in
                
                // animate arrow spining to the back position
                let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
                rotationAnimation.fromValue = 0.0
                rotationAnimation.toValue = Double.pi
                rotationAnimation.duration = 1.0
                self.proceedArrow.layer.add(rotationAnimation, forKey: nil)
                // stick uiikmage in 108 position
                let angle = CGFloat(Double.pi)
                let tr = CGAffineTransform.identity.rotated(by: angle)
                self.proceedArrow.transform = tr
                
            })
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case playerLinePicker:
            return pickerData.count
        case playerPositionPicker:
            switch selectPlayerLine{
            case  1,2,3:
                return forwardPositionData.count
            case 4,5,6:
                return defensePositionData.count
            default :
                return 1
            }
        default:
            return pickerData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView == playerPositionPicker){
            switch selectPlayerLine{
            case  1,2,3:
                return forwardPositionData[row]
            case 4,5,6:
                return defensePositionData[row]
            default :
                return goaliePositionData[row]
            }
        }else{
            return pickerData[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView == playerLinePicker){
            if(pickerData[row] == "Forward 1"){
                selectPlayerLine = 1
                selectPosition = positionCodeData[1]
                playerPositionPicker.reloadAllComponents()
                playerPositionPicker.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    self.playerPositionPicker.alpha = 1.0
                }, completion: nil)
                
            }else if(pickerData[row] == "Forward 2"){
                selectPlayerLine = 2
                selectPosition = positionCodeData[1]
                playerPositionPicker.reloadAllComponents()
                playerPositionPicker.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    self.playerPositionPicker.alpha = 1.0
                }, completion: nil)
            }else if(pickerData[row] == "Forward 3"){
                selectPlayerLine = 3
                selectPosition = positionCodeData[1]
                playerPositionPicker.reloadAllComponents()
                playerPositionPicker.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    self.playerPositionPicker.alpha = 1.0
                }, completion: nil)
            }else if(pickerData[row] == "Defense 1"){
                selectPlayerLine = 4
                selectPosition = positionCodeData[3]
                playerPositionPicker.reloadAllComponents()
                playerPositionPicker.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    self.playerPositionPicker.alpha = 1.0
                }, completion: nil)
            }else if(pickerData[row] == "Defense 2"){
                selectPlayerLine = 5
                selectPosition = positionCodeData[3]
                playerPositionPicker.reloadAllComponents()
                playerPositionPicker.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    self.playerPositionPicker.alpha = 1.0
                }, completion: nil)
            }else if(pickerData[row] == "Defense 3"){
                selectPlayerLine = 6
                selectPosition = positionCodeData[3]
                playerPositionPicker.reloadAllComponents()
                playerPositionPicker.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    self.playerPositionPicker.alpha = 1.0
                }, completion: nil)
            }else{
                selectPlayerLine = 0
                selectPosition = positionCodeData[5]
                playerPositionPicker.reloadAllComponents()
                playerPositionPicker.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    self.playerPositionPicker.alpha = 1.0
                }, completion: nil)
            }
        }else{
            switch selectPlayerLine{
            case  1,2,3:
                selectPosition = positionCodeData[row]
                
            case 4,5,6:
                selectPosition = positionCodeData[row + 3]
                
            default :
                selectPosition = positionCodeData[positionCodeData.count - 1]
                
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == playerNumberTextField){
            guard NSCharacterSet(charactersIn: "0123456789").isSuperset(of: NSCharacterSet(charactersIn: string) as CharacterSet) else {
                return false
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    
        if (textField == playerNameTextField || playerNameTextField.text?.isEmpty != true){
            playerNumberTextField.isUserInteractionEnabled = true
            UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                self.playerNumberTextField.alpha = 1.0
            }, completion: nil)
        
            if (textField == playerNumberTextField || playerNumberTextField.text?.isEmpty != true){
                playerLinePicker.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                    self.playerLinePicker.alpha = 1.0
                }, completion: nil)
                
            }
        }
    }
    
    // on add player button click
    @IBAction func savePlayer(_ sender: UIButton) {
        
        let realm = try! Realm()
        var fileLogoName: String = ""
        
        if (fieldErrorChecker() == true){
        
        if (realm.objects(playerInfoTable.self).max(ofProperty: "playerID") as Int? != nil){
            
            primaryPlayerID = (realm.objects(playerInfoTable.self).max(ofProperty: "playerID")as Int? ?? 0) + 1
            doneHomePlayers = true
        }else{
            primaryPlayerID = (realm.objects(playerInfoTable.self).max(ofProperty: "playerID")as Int? ?? 0)
            
        }
        let newPlayer = playerInfoTable()
            
        if userSelectedProfileImage != nil{
            // set file name for profile picture
            fileLogoName = "\((primaryPlayerID)!)_ID_\((playerNameTextField.text)!)_player_logo"
            imageWriter(fileName: fileLogoName, imageName: userSelectedProfileImage)
        }
    
        try! realm.write{
            newPlayer.playerID = primaryPlayerID
            newPlayer.TeamID = String(queryTeamID)
            newPlayer.playerName = playerNameTextField.text!
            newPlayer.jerseyNum = Int(playerNumberTextField.text!)!
            newPlayer.lineNum = selectPlayerLine
            newPlayer.positionType = selectPosition
            newPlayer.activeState = true
            newPlayer.playerLogoURL = fileLogoName
            realm.add(newPlayer, update:true)
        }
        proceedArrow.isHidden = false
        // reset textfields
        playerNameTextField.text = ""
        playerNumberTextField.text = ""
        userSelectedProfileImage = nil
        succesfulPlayerAdd(playerName: playerNameTextField.text!)
        }else{
            print("User is missing a field, player cannot be saved properly")
        }
     
    }
    
    @objc func playerLogoTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        print("Opening Photo Selection Method")
        mediaTypeSelectionAlert()
        
    }
    
    func mediaTypeSelectionAlert(){
        
        // create the alert
        let mediaAlert = UIAlertController(title: localizedString().localized(value:"Logo Update"), message: localizedString().localized(value:"Select the location that your team logo should come from. Selecting Camera will allow for you to take a brand new image. Libary will allow you to select an image from your photo libary on your device"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        mediaAlert.addAction(UIAlertAction(title: "Camera", style: UIAlertAction.Style.default, handler: { action in
            print("Accesing Camera")
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
                self.imagePickerController = UIImagePickerController()
                self.imagePickerController.delegate = self
                self.imagePickerController.sourceType = .camera
                self.imagePickerController.allowsEditing = true
                self.present(self.imagePickerController, animated: true, completion: nil)
            }
            
        }))
        // add an action (button)
        mediaAlert.addAction(UIAlertAction(title: "Photo Library", style: UIAlertAction.Style.default, handler: { action in
            print("Accesing Libary")
            
            self.imagePickerController = UIImagePickerController()
            self.imagePickerController.delegate = self
            self.imagePickerController.sourceType = .photoLibrary
            self.imagePickerController.allowsEditing = true
            self.present(self.imagePickerController, animated: true, completion: nil)
            
            
        }))
        // add an action (button)
        mediaAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        // show the alert
        self.present(mediaAlert, animated: true, completion: nil)
    }
    
    func fieldErrorChecker() -> Bool{
        
        if (playerNameTextField.text?.isEmpty == true && playerNumberTextField.text?.isEmpty == true){
            
            missingFieldAlert(missingFieldType: "Player Name and Player Number")
            return false
        }else if (playerNameTextField.text?.isEmpty == true){
            
            missingFieldAlert(missingFieldType: "Player Name")
            return false
        }else if (playerNumberTextField.text?.isEmpty == true){
            missingFieldAlert(missingFieldType: "Player Number ")
            return false
        }else{
            return true
        }
    }
        
    // if player name or player number is missing create alert notifying user
    func missingFieldAlert(missingFieldType: String){
        
        // create the alert
        let missingField = UIAlertController(title: "Missing Field Error", message: "Please have the \(missingFieldType) field filled first before saving a player.", preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        missingField.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(missingField, animated: true, completion: nil)
        
    }
    // if player was addded succesfully notify user
    func succesfulPlayerAdd(playerName: String){
        
        // create the alert
        let successfulQuery = UIAlertController(title: "\(playerName) Added Successfully", message: "", preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        successfulQuery.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
           
            let realm = try! Realm()
            
            if ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "teamID == %i AND activeState == true", 1)).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})).count == 2 && self.doneHomePlayers == true{
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "initialSetupPageMover"), object: nil, userInfo: ["sideNumber":4])
                
            }
            if self.primaryPlayerID >= 1 {
                self.teamNameSetter()
            }
            
        }))
        // show the alert
        self.present(successfulQuery, animated: true, completion: nil)
    }
    
    func fatalErrorAlert(_ msg: String){
        
        let errorAlert = UIAlertController(title: localizedString().localized(value:"Whoops!"), message: localizedString().localized(value:"\(msg)"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(errorAlert, animated: true, completion: nil)
        
    }
    
   
}
extension Initial_Setup_Player_Add_View_Controller:  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        guard let selectedImage = info[.editedImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        // set
        userSelectedProfileImage = selectedImage
        profileImageSetter()
        
        
        //Dismiss the UIImagePicker after selection
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        self.dismiss(animated: true, completion: nil)
    }
    
    func imageWriter(fileName: String, imageName: UIImage){
        
        
        let imageData = imageName.jpegData(compressionQuality: 0.25)
        
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let tempUrl = dir.appendingPathComponent("TeamLogo")
            let fileURL = tempUrl.appendingPathComponent(fileName)
            
            print(fileURL)
            
            do {
                try imageData!.write(to: fileURL, options: .atomicWrite)
                print("Away Team logo SUCCESSFUL image write")
                
            } catch {
                
                print("Team logo write error")
                fatalErrorAlert("An error has occured while attempting to save your team logo. Please contact support!")
                
            }
        }
    }
    
}


