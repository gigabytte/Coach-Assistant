//
//  Player About Popup View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-08-23.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import RealmSwift
import Charts

class Player_About_Popup_View_Controller: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var playerActiveSwitch: UISwitch!
    @IBOutlet weak var playerIsActiveLabel: UILabel!
    @IBOutlet weak var playerProfileImageView: UIImageView!
    @IBOutlet weak var editFieldsButton: UIButton!
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var playerNumberLabel: UILabel!
    @IBOutlet weak var playerPositionLabel: UILabel!
    @IBOutlet weak var playerLineNumberLabel: UILabel!
    @IBOutlet weak var playerEditNameTextField: UITextField!
    @IBOutlet weak var playerEditNumberTextField: UITextField!
    @IBOutlet weak var lineNumberPicker: UIPickerView!
    @IBOutlet weak var positionTypePicker: UIPickerView!
    @IBOutlet weak var playerInfoTableView: UITableView!
    
    @IBOutlet weak var playerInfoPieChartView: PieChartView!
    @IBOutlet weak var popUpView: UIView!
    
    var passedPlayerID: Int!
    var selectPosition: String!
    var selectLine: Int!
    
    var imagePickerController : UIImagePickerController!
    
    var pickerData:[String] = [String]()
    var forwardPositionData:[String] = [String]()
    var defensePositionData:[String] = [String]()
    var goaliePositionData:[String] = [String]()
    var positionCodeData:[String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(playerProfileImageTapped(tapGestureRecognizer:)))
        playerProfileImageView.isUserInteractionEnabled = true
        playerProfileImageView.addGestureRecognizer(tapGestureRecognizer)
        
        // add blur effect to view along with popUpView
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.addSubview(popUpView)
        
        self.lineNumberPicker.delegate = self
        self.lineNumberPicker.dataSource = self
        
        self.positionTypePicker.delegate = self
        self.positionTypePicker.dataSource = self
        
        onLoad()
    }
    
    func onLoad(){
        
        let realm = try! Realm()
        let playerObjc = realm.object(ofType: playerInfoTable.self, forPrimaryKey: passedPlayerID)
        
        // player info labels on load
        if let playerName = playerObjc?.playerName{
            if playerName != ""{
                playerNameLabel.text = playerName
            }else{
                playerNameLabel.text = "Unknow Team Name"
            }
        }
        
        if let playerNumber = playerObjc?.jerseyNum{
            if playerNumber != 0{
                playerNumberLabel.text? = "#\(playerNumber)"
            }else{
                playerNumberLabel.text? = "#00"
            }
        }
        
        if let lineNumber = playerObjc?.lineNum{
            if lineNumber != 0{
                playerLineNumberLabel.text = playerLinePositionConverter().realmInpuToString(rawInput: lineNumber)
            }else{
                playerLineNumberLabel.text = "Unknown"
            }
        }
        
        if let positionType = playerObjc?.positionType{
            if positionType != "" {
                playerPositionLabel.text = playerPositionConverter().realmInpuToString(rawInput: positionType)
            }else{
                playerPositionLabel.text = "Unknown"
            }
        }
        
        
        if let URL = playerObjc?.playerLogoURL{
            if URL != ""{
                let readerResult = imageReader(fileName: playerObjc!.playerLogoURL) as? UIImage
                if readerResult != nil {
                    playerProfileImageView.image = readerResult
                }else{
                    // default image goes here
                    
                }
            }
        }
        
        pickerData = ["Forward 1", "Forward 2","Forward 3","Defense 1","Defense 2","Defense 3","Goalie"]
        forwardPositionData = ["Left Wing", "Center", "Right Wing"]
        defensePositionData = ["Left Defence", "Right Defence"]
        goaliePositionData = ["Goalie"]
        positionCodeData = ["LW", "C", "RW", "LD", "RD", "G"]
        
        selectPosition = positionCodeData[0]
        selectLine = 1
        
        
        playerActiveSwitch.isOn = playerObjc!.activeState
        switchState()
        // set view colour attributes
        viewColour()
    }
    
    func viewColour(){
        
        popUpView.layer.cornerRadius = 10
        
        playerProfileImageView.heightAnchor.constraint(equalToConstant: playerProfileImageView.frame.height).isActive = true
        playerProfileImageView.setRounded()
        
    }
    
    func switchState(){
        let realm = try! Realm()
        let playerObjc = realm.object(ofType: playerInfoTable.self, forPrimaryKey: passedPlayerID)
        
        
        switch playerActiveSwitch.isOn {
        case true:
            playerIsActiveLabel.text = "\((playerObjc?.playerName)!) is Enabled"
            break
        case false:
            playerIsActiveLabel.text = "\((playerObjc?.playerName)!) is Disabled"
            break
        default:
            playerIsActiveLabel.text = "\((playerObjc?.playerName)!) is Enabled"
            break
        }
        
    }
    
    func isEditingFields(boolType: Bool){
        
        switch boolType {
        case true:
            
            playerNameLabel.isHidden = false
            playerPositionLabel.isHidden = false
            playerLineNumberLabel.isHidden = false
            playerNumberLabel.isHidden = false
            playerInfoTableView.isHidden = false
            playerInfoPieChartView.isHidden = false
            
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                self.playerNameLabel.alpha = 1.0
                self.playerPositionLabel.alpha = 1.0
                self.playerLineNumberLabel.alpha = 1.0
                self.playerNumberLabel.alpha = 1.0
                self.playerInfoTableView.alpha = 1.0
                self.playerInfoPieChartView.alpha = 1.0
                
                self.playerEditNameTextField.alpha = 0.0
                self.playerEditNumberTextField.alpha = 0.0
                self.lineNumberPicker.alpha = 0.0
                self.positionTypePicker.alpha = 0.0
                self.playerIsActiveLabel.alpha = 0.0
                self.playerActiveSwitch.alpha = 0.0
                
                self.view.layoutIfNeeded()
            
            }, completion: { _ in
                self.playerEditNameTextField.isHidden = true
                self.playerEditNumberTextField.isHidden = true
                self.lineNumberPicker.isHidden = true
                self.positionTypePicker.isHidden = true
                self.playerIsActiveLabel.isHidden = true
                self.playerActiveSwitch.isHidden = true
            })
            
            break
        case false:
            
            playerEditNameTextField.isHidden = false
            playerEditNumberTextField.isHidden = false
            lineNumberPicker.isHidden = false
            positionTypePicker.isHidden = false
            self.playerIsActiveLabel.isHidden = false
            self.playerActiveSwitch.isHidden = false
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                
                self.playerEditNameTextField.alpha = 1.0
                self.playerEditNumberTextField.alpha = 1.0
                self.lineNumberPicker.alpha = 1.0
                self.positionTypePicker.alpha = 1.0
                self.playerIsActiveLabel.alpha = 1.0
                self.playerActiveSwitch.alpha = 1.0
                
                self.playerNameLabel.alpha = 0.0
                self.playerPositionLabel.alpha = 0.0
                self.playerLineNumberLabel.alpha = 0.0
                self.playerNumberLabel.alpha = 0.0
                self.playerInfoTableView.alpha = 0.0
                self.playerInfoPieChartView.alpha = 0.0
                
                self.view.layoutIfNeeded()
            }, completion: { _ in
                
                self.playerNameLabel.isHidden = true
                self.playerPositionLabel.isHidden = true
                self.playerLineNumberLabel.isHidden = true
                self.playerNumberLabel.isHidden = true
                self.playerInfoTableView.isHidden = true
                self.playerInfoPieChartView.isHidden = true
            })
            break
        default:
            
            playerEditNameTextField.isHidden = false
            playerEditNumberTextField.isHidden = false
            lineNumberPicker.isHidden = false
            positionTypePicker.isHidden = false
            playerIsActiveLabel.isHidden = false
            playerActiveSwitch.isHidden = false
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                
                self.playerEditNameTextField.alpha = 1.0
                self.playerEditNumberTextField.alpha = 1.0
                self.lineNumberPicker.alpha = 1.0
                self.positionTypePicker.alpha = 1.0
                self.playerIsActiveLabel.alpha = 1.0
                self.playerActiveSwitch.alpha = 1.0
                
                self.playerNameLabel.alpha = 0.0
                self.playerPositionLabel.alpha = 0.0
                self.playerLineNumberLabel.alpha = 0.0
                self.playerNumberLabel.alpha = 0.0
                self.playerInfoTableView.alpha = 0.0
                self.playerInfoPieChartView.alpha = 0.0
                
                self.view.layoutIfNeeded()
            }, completion: { _ in
                
                self.playerNameLabel.isHidden = true
                self.playerPositionLabel.isHidden = true
                self.playerLineNumberLabel.isHidden = true
                self.playerNumberLabel.isHidden = true
                self.playerInfoTableView.isHidden = true
                self.playerInfoPieChartView.isHidden = true
            })
            break
        }
    }
    
    func mediaTypeSlectionAlert(){
        
        // create the alert
        let mediaAlert = UIAlertController(title: localizedString().localized(value:"Logo Update"), message: localizedString().localized(value:"Select the location that your player porfile image should come from. Selecting Camera ill allow for you to take a brand new image. Libary will allow you to select an image from your photo libary on your device"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        mediaAlert.addAction(UIAlertAction(title: "Camera", style: UIAlertAction.Style.default, handler: { action in
            print("Accesing Camera")
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
                self.imagePickerController = UIImagePickerController()
                self.imagePickerController.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
                self.imagePickerController.sourceType = .camera
                self.imagePickerController.allowsEditing = true
                self.present(self.imagePickerController, animated: true, completion: nil)
            }
            
        }))
        // add an action (button)
        mediaAlert.addAction(UIAlertAction(title: "Libary", style: UIAlertAction.Style.default, handler: { action in
            print("Accesing Libary")
            
            self.imagePickerController = UIImagePickerController()
            self.imagePickerController.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            self.imagePickerController.sourceType = .photoLibrary
            self.imagePickerController.allowsEditing = true
            self.present(self.imagePickerController, animated: true, completion: nil)
            
            
        }))
        // add an action (button)
        mediaAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        // show the alert
        self.present(mediaAlert, animated: true, completion: nil)
    }
    
    func realmLogoRefrence(fileURL: String){
        let realm = try! Realm()
        
        let playerObjc = realm.object(ofType: playerInfoTable.self, forPrimaryKey: passedPlayerID);
        
        try! realm.write {
            
            playerObjc!.playerLogoURL = fileURL
            
        }
        
    }
    
    func fatalErrorAlert(_ msg: String){
        
        let errorAlert = UIAlertController(title: localizedString().localized(value:"Whoops!"), message: localizedString().localized(value:"\(msg)"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(errorAlert, animated: true, completion: nil)
        
    }
    
    func succesfulPlayerAdd(playerName: String){
        
        let successfulQuery = UIAlertController(title: String(format: localizedString().localized(value:"Player %@ has been updated."), playerName), message: "", preferredStyle: UIAlertController.Style.alert)
        successfulQuery.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            
            self.playerEditNameTextField.text = ""
            self.playerEditNumberTextField.text = ""
    
        }))
        
        self.present(successfulQuery, animated: true, completion: nil)
    }
    
    func savePlayerInfo(){
        
        let realm = try! Realm()
        
        let playerLine = selectLine
        let playerPosition = selectPosition
        let playerName = playerEditNameTextField.text!
        let playerNumber = Int(playerEditNumberTextField.text!)
        let editedPlayer = realm.object(ofType: playerInfoTable.self, forPrimaryKey: passedPlayerID);
       
    // check to see if fields are filled out properly
        if(playerName != "" && playerEditNumberTextField.text! != ""){
            
            try! realm.write {
                editedPlayer!.jerseyNum = playerNumber!
                editedPlayer!.playerName = playerName
                editedPlayer!.lineNum = playerLine!
                editedPlayer!.positionType = playerPosition!
                editedPlayer!.activeState = playerActiveSwitch.isOn
            }
            editFieldsButton.tag = 20
        }else if(playerName != "" && playerEditNumberTextField.text! == ""){
            
            try! realm.write {
                editedPlayer!.playerName = playerName
                editedPlayer!.lineNum = playerLine!
                editedPlayer!.positionType = playerPosition!
                editedPlayer!.activeState = playerActiveSwitch.isOn
            }
            editFieldsButton.tag = 20
        }else if(playerName == "" && playerEditNumberTextField.text! != ""){
            
            try! realm.write {
                editedPlayer!.jerseyNum = playerNumber!
                editedPlayer!.lineNum = playerLine!
                editedPlayer!.positionType = playerPosition!
                editedPlayer!.activeState = playerActiveSwitch.isOn
            }
            editFieldsButton.tag = 20
        }else if(playerName == "" && playerEditNumberTextField.text! == ""){
            print("player postion",playerPosition)
            try! realm.write {
                editedPlayer!.lineNum = playerLine!
                editedPlayer!.positionType = playerPosition!
                editedPlayer!.activeState = playerActiveSwitch.isOn
            }
            editFieldsButton.tag = 20
        }else{
              editFieldsButton.tag = 10
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case lineNumberPicker:
            return pickerData.count
        default:
            switch selectLine{
            case  1,2,3:
                return forwardPositionData.count
            case 4,5,6:
                return defensePositionData.count
            default :
                return 1
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView == positionTypePicker){
            switch selectLine{
            case  1,2,3:
                return forwardPositionData[row]
            case 4,5,6:
                return defensePositionData[row]
            default :
                return goaliePositionData[row]
            }
        }else {
            return pickerData[row]
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView == lineNumberPicker){
            if(pickerData[row] == "Forward 1"){
                selectLine = 1
                positionTypePicker.reloadAllComponents()
                selectPosition = "LW"
                
            }else if(pickerData[row] == "Forward 2"){
                selectLine = 2
                positionTypePicker.reloadAllComponents()
                selectPosition = "LW"
            }else if(pickerData[row] == "Forward 3"){
                selectLine = 3
                positionTypePicker.reloadAllComponents()
                selectPosition = "LW"
            }else if(pickerData[row] == "Defense 1"){
                selectLine = 4
                positionTypePicker.reloadAllComponents()
                selectPosition = "LD"
            }else if(pickerData[row] == "Defense 2"){
                selectLine = 5
                positionTypePicker.reloadAllComponents()
                selectPosition = "LD"
            }else if(pickerData[row] == "Defense 3"){
                selectLine = 6
                positionTypePicker.reloadAllComponents()
                selectPosition = "LD"
            }else{
                selectLine = 0
                positionTypePicker.reloadAllComponents()
                selectPosition = "G"
            }
        }else {
            switch selectLine{
            case  1,2,3:
                selectPosition = positionCodeData[row]
            case 4,5,6:
                selectPosition = positionCodeData[row + 3]
            default :
                selectPosition = positionCodeData[positionCodeData.count - 1]
            }
        }
        
        print("Select Position \(selectPosition)")
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "homePageRefresh"), object: nil, userInfo: ["key":"value"])
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editFieldsButton(_ sender: UIButton) {
        let realm = try! Realm()
        let editedPlayer = realm.object(ofType: playerInfoTable.self, forPrimaryKey: passedPlayerID);
        // is player label is already hidden reverse the process
        if playerNameLabel.isHidden == true{
            // write new player inffo to realm
            // update UI
            savePlayerInfo()
            succesfulPlayerAdd(playerName: editedPlayer!.playerName)
            isEditingFields(boolType: true)
            onLoad()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "homePageRefresh"), object: nil, userInfo: ["key":"value"])
        }else{
           
            isEditingFields(boolType: false)
        }
        
    }
    
    @objc func playerProfileImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        print("Opening Photo Selection Method")
        mediaTypeSlectionAlert()
        
    }
    
    @IBAction func playerToggleSwitch(_ sender: UISwitch) {
        switchState()
    }
    

}

extension Player_About_Popup_View_Controller:  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let realm = try! Realm()
        let playerObjc = realm.object(ofType: playerInfoTable.self, forPrimaryKey: passedPlayerID)
        
        guard let selectedImage = info[.editedImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        imageWriter(fileName: "\((playerObjc?.playerName)!)_ID_\((playerObjc?.playerID)!)_player_logo", imageName: selectedImage)
        onLoad()
        
        
        //Dismiss the UIImagePicker after selection
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        self.dismiss(animated: true, completion: nil)
    }
    
    func imageWriter(fileName: String, imageName: UIImage){
        
        let imageData = imageName.pngData()!
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let tempUrl = dir.appendingPathComponent("PlayerImages")
            let fileURL = tempUrl.appendingPathComponent(fileName)
            
            print(fileURL)
            
            do {
                try imageData.write(to: fileURL, options: .atomicWrite)
                // send realm the location of the logo in DD
                realmLogoRefrence(fileURL: "\(fileName)")
                
            } catch {
                print("Player logo write error")
                fatalErrorAlert("An error has occured while attempting to save your player profile image. Please contact support!")
            }
        }
    }
    
    func imageReader(fileName: String) -> UIImage{
        
        var retreivedImage: UIImage!
        
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let URLs = dir.appendingPathComponent("PlayerImages")
            let newURL = URLs.appendingPathComponent(fileName)
            
            do {
                let readData = try Data(contentsOf: newURL)
                retreivedImage = UIImage(data: readData)
                
            } catch {
                print("Player logo read error")
                fatalErrorAlert("An error has occured while attempting to retrieve your player profile image. Please contact support!")
                
            }
        }
        if retreivedImage != nil{
            return(retreivedImage)
        }else{
            return(UIImage(named: "temp_profile_pic_icon")!)
        }
        
    }
}

