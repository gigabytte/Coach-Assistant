//
//  Add_Team_Info_Page.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-01-29.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class Add_Player_Page: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var addingToTeamNameLabel: UILabel!
    @IBOutlet weak var makeInActiveLabel: UILabel!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var plauyerDetailsView: UIView!
    @IBOutlet weak var playerProfileImageViewLabel: UILabel!
    @IBOutlet weak var playerProfileImageView: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var linePicker: UIPickerView!
    @IBOutlet weak var positionPicker: UIPickerView!
    @IBOutlet weak var playerNumber: UITextField!
    @IBOutlet weak var playerName: UITextField!
    @IBOutlet weak var inActivePlayerToggle: UISwitch!
    @IBOutlet weak var visitWebsiteButton: UIButton!
    
    var pickerData:[String] = [String]()
    var positionData:[String] = [String]()
    var positionCodeData:[String] = [String]()
    var selectLine:Int!
    var selectedTeamID: Int!
    var selectPosition:String!
    var primaryPlayerID: Int!
    var forwardPositionData: [String] = [String]()
    var defensePositionData: [String] = [String]()
    var goaliePositionData: [String] = [String]()
    
    var teamPickerData: [String] = [String]()
    var teamIDPickerData:[String] = [String]()
    var selectTeam: String = ""
    
    var imagePickerController : UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder() // To get shake gesture
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(myMethod(notification:)), name: NSNotification.Name(rawValue: "homePageRefresh"), object: nil)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(playerLogoTapped(tapGestureRecognizer:)))
        playerProfileImageView.isUserInteractionEnabled = true
        playerProfileImageView.addGestureRecognizer(tapGestureRecognizer)
        
        self.linePicker.delegate = self
        self.linePicker.dataSource = self
        
        self.positionPicker.delegate = self
        self.positionPicker.dataSource = self
        
        playerNumber.delegate = self
       
        onLoad()
    
       
    }
    
    func onLoad(){
        
        let realm = try! Realm()
        
        selectedTeamID = UserDefaults.standard.integer(forKey: "defaultHomeTeamID")
        
        let teamNameObjc = realm.object(ofType: teamInfoTable.self, forPrimaryKey: selectedTeamID)?.nameOfTeam
        if teamNameObjc != ""{
            addingToTeamNameLabel.text = "Note you are adding a player to \(teamNameObjc!.capitalized)"
        }else{
            addingToTeamNameLabel.text = "Note you are adding a player to the default team selected"
        }
        
        // Do any additional setup after loading the view.
        pickerData = ["Forward 1", "Forward 2","Forward 3","Defense 1","Defense 2","Defense 3","Goalie"]
        forwardPositionData = ["Left Wing", "Center", "Right Wing"]
        defensePositionData = ["Left Defence", "Right Defence"]
        goaliePositionData = ["Goalie"]
        positionCodeData = ["LW", "C", "RW", "LD", "RD", "G"]
      
        selectLine = 1
        selectPosition = positionCodeData.first
        
        viewColour()
        
    }
    
    func viewColour(){
        playerNumber.backgroundColor = systemColour().uiTextField()
        playerName.backgroundColor = systemColour().uiTextField()
    }
    
    func savePlayerMethod(){
        
        let realm = try! Realm()
        let nameOfPlayer: String = playerName.text!
        let number = Int(playerNumber.text!)
        let line = selectLine
        let position = selectPosition
        
        print("line \(line) postion \(position)")
        
        let newPlayer = playerInfoTable()
        
        if (realm.objects(playerInfoTable.self).max(ofProperty: "playerID") as Int? != nil){
            
            primaryPlayerID = (realm.objects(playerInfoTable.self).max(ofProperty: "playerID")as Int? ?? 0) + 1
        }else{
            primaryPlayerID = (realm.objects(playerInfoTable.self).max(ofProperty: "playerID")as Int? ?? 0)
            
        }
    
        // check to see if fields are filled out properly
        // write info to realm and reset all fields
        if (number != nil && nameOfPlayer != ""){
            if (doubleJerseyNumCheck(selectedTeamID: selectedTeamID) == false){
                newPlayer.playerID = primaryPlayerID
                newPlayer.playerName = nameOfPlayer
                newPlayer.jerseyNum = number!
                newPlayer.lineNum = line!
                newPlayer.positionType = position!
                newPlayer.TeamID = String(selectedTeamID)
                if playerProfileImageView.tag == 20{
                    let fileURL = "\((primaryPlayerID!))_ID_\((nameOfPlayer))_team_logo"
                    imageWriter(fileName: fileURL, imageName: playerProfileImageView.image!)
                    newPlayer.playerLogoURL = fileURL
                }
                
                try! realm.write{
                    realm.add(newPlayer, update: true)
                    
                    playerName.text = ""
                    playerNumber.text = ""
                    self.linePicker.reloadAllComponents()
                    playerProfileImageView.image = UIImage(named: "temp_profile_pic_icon")
                    succesfulPlayerAdd(playerName: nameOfPlayer)
                }
            }else{
                // double jersey number alrt
                let doubleJersey = UIAlertController(title: localizedString().localized(value:"Double Up!"), message: localizedString().localized(value:"Please make sure each memeber of your team as a unique jersey number"), preferredStyle: UIAlertController.Style.alert)
                // add an action (button)
                doubleJersey.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                // show the alert
                self.present(doubleJersey, animated: true, completion: nil)
                
            }
            
        }else{
            missingFieldAlert()
        }
       
    }
    
    func isFadeOut(showProfileImageView: Bool){
        switch showProfileImageView {
        case true:
            playerProfileImageView.isHidden = false
            playerProfileImageViewLabel.isHidden = false
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                self.playerName.alpha = 0.0
                self.playerNumber.alpha = 0.0
                self.plauyerDetailsView.alpha = 0.0
                self.makeInActiveLabel.alpha = 0.0
                self.inActivePlayerToggle.alpha = 0.0
                self.addingToTeamNameLabel.alpha = 0.0
                
                self.playerProfileImageView.alpha = 1.0
                self.playerProfileImageViewLabel.alpha = 1.0
                self.restartButton.alpha = 1.0
                
                self.view.layoutIfNeeded()
                
            }, completion: { _ in
                self.playerName.isHidden = true
                self.playerNumber.isHidden = true
                self.plauyerDetailsView.isHidden = true
                self.makeInActiveLabel.isHidden = true
                self.inActivePlayerToggle.isHidden = true
                self.addingToTeamNameLabel.isHidden = true
                
            })
            break
        case false:
            
            self.playerName.isHidden = false
            self.playerNumber.isHidden = false
            self.plauyerDetailsView.isHidden = false
            self.makeInActiveLabel.isHidden = false
            self.inActivePlayerToggle.isHidden = false
            self.addingToTeamNameLabel.isHidden = false
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                self.playerName.alpha = 1.0
                self.playerNumber.alpha = 1.0
                self.plauyerDetailsView.alpha = 1.0
                self.makeInActiveLabel.alpha = 1.0
                self.inActivePlayerToggle.alpha = 1.0
                self.addingToTeamNameLabel.alpha = 1.0
                
                self.playerProfileImageView.alpha = 0.0
                self.playerProfileImageViewLabel.alpha = 0.0
                self.restartButton.alpha = 0.3
                
                self.view.layoutIfNeeded()
                
            }, completion: { _ in
                self.playerProfileImageView.isHidden = true
                self.playerProfileImageViewLabel.isHidden = true
                
            })
            break
        }
    }
    
    // We are willing to become first responder to get shake motion
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    
    @objc func myMethod(notification: NSNotification){
        onLoad()
    }
    
    @IBAction func visitWebsiteButton(_ sender: Any) {
        
        let actionSheet = UIAlertController(title: localizedString().localized(value:"Did you Know?"), message: localizedString().localized(value:"Tired of adding your players one by one? Coach Assistant allows you to add multiple users with our handy import / backup funciton. We have an easy to follow and quick tutorial online so you can get started!"), preferredStyle: .actionSheet)
        
        
        let openAction = UIAlertAction(title: localizedString().localized(value:"open"), style: .default, handler: { (alert: UIAlertAction!) -> Void in
            guard let url = URL(string: universalValue().websiteURLHelp) else { return }
            UIApplication.shared.open(url)
        })
        // tapp anywhere outside of popup alert controller
        let cancelAction = UIAlertAction(title: localizedString().localized(value:"Cancel"), style: .cancel, handler: { (alert: UIAlertAction!) -> Void in
            print("didPress Cancel")
        })
        // Add the actions to your actionSheet
        actionSheet.addAction(openAction)
        actionSheet.addAction(cancelAction)
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: visitWebsiteButton.frame.origin.x, y: visitWebsiteButton.frame.origin.y, width: visitWebsiteButton.frame.width / 2, height: visitWebsiteButton.frame.height)
            
        }
        // Present the controller
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    // if keyboard is out push whole view up half the height of the keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        if playerName.isEditing == true {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= (keyboardSize.height / 4)
                }
            }
        }
    }
    // when keybaord down return view back to y orgin of 0
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc func playerLogoTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        print("Opening Photo Selection Method")
        mediaTypeSlectionAlert()
        
    }
    
    // restrict player number field to decimal degots only
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == playerNumber){
            guard NSCharacterSet(charactersIn: "0123456789").isSuperset(of: NSCharacterSet(charactersIn: string) as CharacterSet) else {
                return false
            }
        }
        return true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case linePicker:
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
       if(pickerView == positionPicker){
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
 
        if(pickerView == linePicker){
            if(pickerData[row] == "Forward 1"){
                selectLine = 1
                positionPicker.reloadAllComponents()
                selectPosition = "LW"
                
            }else if(pickerData[row] == "Forward 2"){
                selectLine = 2
                positionPicker.reloadAllComponents()
                selectPosition = "LW"
            }else if(pickerData[row] == "Forward 3"){
                selectLine = 3
                positionPicker.reloadAllComponents()
                selectPosition = "LW"
            }else if(pickerData[row] == "Defense 1"){
                selectLine = 4
                positionPicker.reloadAllComponents()
                selectPosition = "LD"
            }else if(pickerData[row] == "Defense 2"){
                selectLine = 5
                positionPicker.reloadAllComponents()
                selectPosition = "LD"
            }else if(pickerData[row] == "Defense 3"){
                selectLine = 6
                positionPicker.reloadAllComponents()
                selectPosition = "LD"
            }else{
                selectLine = 0
                positionPicker.reloadAllComponents()
                selectPosition = "G"
            }
        }else{
            switch selectLine{
            case  1,2,3:
                selectPosition = positionCodeData[row]
                
            case 4,5,6:
                selectPosition = positionCodeData[row + 3]
            default :
                selectPosition = positionCodeData[positionCodeData.count - 1]
            }
        }
    }
    @IBAction func restartButton(_ sender: UIButton) {
        if restartButton.alpha == 1.0{
            isFadeOut(showProfileImageView: false)
            actionButton.tag = 10
            actionButton.setTitle("Next Step ...", for: .normal)
        }
    }
    
    // on add player button click
    @IBAction func savePlayer(_ sender: UIButton) {
        
        if actionButton.tag == 10{
            // display profile image picker
            isFadeOut(showProfileImageView: true)
            actionButton.setTitle("Save Player", for: .normal)
            actionButton.tag = 20
        }else{
            // save player
            savePlayerMethod()
            
        }
    }
    @IBAction func addTeamButton(_ sender: Any) {
        performSegue(withIdentifier: "closeAddPlayerSegue", sender: nil)
    }
    @IBAction func backButton(_ sender: Any) {
        
        performSegue(withIdentifier: "backtoHomeSegueAddPlayer", sender: nil)
    }
    // if player name or player number is missing create alert notifying user
    func missingFieldAlert(){
        
        // create the alert
        let missingField = UIAlertController(title: localizedString().localized(value:"Missing Field Error"), message: localizedString().localized(value:"Please have Player Name and Number filled before attemtping to add a new player."), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        missingField.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            self.isFadeOut(showProfileImageView: false)
        }))
        // show the alert
        self.present(missingField, animated: true, completion: nil)
        
    }
    // if player was addded succesfully notify user
    func succesfulPlayerAdd(playerName: String){
        
        // create the alert
        let successfulQuery = UIAlertController(title: String(format: localizedString().localized(value:"%@ Added Successfully"), playerName), message: "", preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        successfulQuery.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            self.actionButton.tag = 10
            self.actionButton.setTitle("Next Step ...", for: .normal)
            self.isFadeOut(showProfileImageView: false)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "homePageRefresh"), object: nil, userInfo: ["key":"value"])
        }))
        // show the alert
        self.present(successfulQuery, animated: true, completion: nil)
    }
    
    func doubleJerseyNumCheck(selectedTeamID: Int) -> Bool {
        
        let realm = try! Realm()
        
        if ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND jerseyNum == %i AND activeState == true", String(selectedTeamID), Int(playerNumber.text!)!)).value(forKeyPath: "playerID") as! [Int]).compactMap({String($0)}).isEmpty == false){
            print("Jersey Double up Failed Test")
            return true
        }else{
            print("Jersey Double up Passed Test")
            return false
        }
        
    }
    
    func mediaTypeSlectionAlert(){
        
        // create the alert
        let mediaAlert = UIAlertController(title: localizedString().localized(value:"Logo Update"), message: localizedString().localized(value:"Select the location that your player profile image should come from. Selecting Camera will allow for you to take a brand new image. Libary will allow you to select an image from your photo libary on your device"), preferredStyle: UIAlertController.Style.alert)
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
        mediaAlert.addAction(UIAlertAction(title: "Libary", style: UIAlertAction.Style.default, handler: { action in
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
}
extension Add_Player_Page:  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        guard let selectedImage = info[.editedImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
            playerProfileImageView.tag = 10
        }
        playerProfileImageView.image = selectedImage
        playerProfileImageView.heightAnchor.constraint(equalToConstant: playerProfileImageView.frame.height).isActive = true
        playerProfileImageView.setRounded()
        playerProfileImageView.tag = 20
        //Dismiss the UIImagePicker after selection
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        self.dismiss(animated: true, completion: nil)
        playerProfileImageView.tag = 10
    }
    
    func imageWriter(fileName: String, imageName: UIImage){
        
        let imageData = imageName.jpegData(compressionQuality: 0.10)
        
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let tempUrl = dir.appendingPathComponent("PlayerImages")
            let fileURL = tempUrl.appendingPathComponent(fileName)
            
            print(fileURL)
            
            do {
                try imageData!.write(to: fileURL, options: .atomicWrite)
                // send realm the location of the logo in DD
                //realmLogoRefrence(fileURL: fileName, teamID: primaryTeamID)
                
            } catch {
                
                //fatalErrorAlert("An error has occured while attempting to save your team logo. Please contact support!")
            }
        }
    }
    
}
