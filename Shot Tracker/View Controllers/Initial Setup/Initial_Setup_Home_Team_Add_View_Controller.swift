//
//  Initial_Setup_Team_Add_View_Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-22.
//  Copyright © 2019 Greg Brooks. All rights reserved.
// View controller will be presented urrin inital setup
// View controller is responsible for adding teams and players to the app

import UIKit
import RealmSwift
import Realm

class Initial_Setup_Home_Team_Add_View_Controller: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var seasonPickerView: UIPickerView!
    @IBOutlet weak var seasonYearTitleLabel: UILabel!
    @IBOutlet weak var proceedArrowImageView: UIImageView!
    @IBOutlet weak var teamNameTextField: UITextField!
    @IBOutlet weak var teamProfileImageView: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var teamNameTitleLabel: UILabel!
    
    var seasonYearValueArray: [Int] = [Int]()
    var selectedSeasonNumber: Int!
    var teamID: Int!
    var userSelectedProfileImage: UIImage!
    
    var imagePickerController : UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.seasonPickerView.delegate = self
        self.seasonPickerView.dataSource = self
        
        teamNameTextField.delegate = self
        teamNameTextField.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(teamLogoTapped(tapGestureRecognizer:)))
        teamProfileImageView.isUserInteractionEnabled = true
        teamProfileImageView.addGestureRecognizer(tapGestureRecognizer)
        
        onLoad()
        
    }
    
   
    
    func onLoad(){
        
        seasonYearValueArray = Array(2019...2030)
        selectedSeasonNumber = seasonYearValueArray.first
        
        // disable picker and save button unless name is added
        teamProfileImageView.isUserInteractionEnabled = false
        
        profileImageSetter()
        
    }
    
    func profileImageSetter(){
        if userSelectedProfileImage != nil{
            teamProfileImageView.image = userSelectedProfileImage
            teamProfileImageView.setRounded()
        }else{
            teamProfileImageView.image = UIImage(named: "temp_profile_pic_icon")
            teamProfileImageView.setRounded()
        }
        
    }
    
    func proceedArrow(showArrowBool: Bool){
        switch showArrowBool {
        case true:
            proceedArrowImageView.isHidden = false
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                self.proceedArrowImageView.alpha = 1.0
                
                self.view.layoutIfNeeded()
                
            }, completion: { _ in
                
                
            })
            break
        case false:
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                self.proceedArrowImageView.alpha = 0.0
                
                self.view.layoutIfNeeded()
                
            }, completion: { _ in
                self.proceedArrowImageView.isHidden = true
                
            })
            break
        }
        
    }
    
    func isFadeOut(fadeBool: Bool){
        switch fadeBool {
        case true:
            teamProfileImageView.isHidden = false
            restartButton.isHidden = false
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                self.seasonYearTitleLabel.alpha = 0.0
                self.seasonPickerView.alpha = 0.0
                self.teamNameTextField.alpha = 0.0
                
                self.teamProfileImageView.alpha = 1.0
                self.restartButton.alpha = 1.0
                
                self.view.layoutIfNeeded()
                
            }, completion: { _ in
                self.seasonYearTitleLabel.isHidden = true
                self.seasonPickerView.isHidden = true
                self.teamNameTextField.isHidden = true
                
                
            })
            break
        case false:
            
            self.seasonYearTitleLabel.isHidden = false
            self.seasonPickerView.isHidden = false
            self.teamNameTextField.isHidden = false
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                self.seasonYearTitleLabel.alpha = 1.0
                self.seasonPickerView.alpha = 1.0
                self.teamNameTextField.alpha = 1.0
                
                self.teamProfileImageView.alpha = 0.0
                self.restartButton.alpha = 0.0
                
                self.view.layoutIfNeeded()
                
            }, completion: { _ in
                self.teamProfileImageView.isHidden = true
                self.restartButton.isHidden = true
                
            })
            break
        }
    }
    @IBAction func restartButton(_ sender: UIButton) {
        
        isFadeOut(fadeBool: false)
        proceedArrow(showArrowBool: false)
        actionButton.tag = 10
        actionButton.setTitle("Next Step ....", for: .normal)
        
    }
    
    @IBAction func actionButton(_ sender: UIButton) {
        if actionButton.tag == 20{
            print("writing to realm")
            isFadeOut(fadeBool: false)
            writeToRealm()
            
        }else{
   
            if teamNameTextField.text != ""{
                isFadeOut(fadeBool: true)
                actionButton.tag = 20
                actionButton.setTitle("Save Team Info", for: .normal)
                teamProfileImageView.isUserInteractionEnabled = true
                teamNameTitleLabel.text = "Add Team Logo"
            }else{
                fatalErrorAlert("Please add a team name before proceeding")
            }
        }
        
    }
    
    @IBAction func importGameSavesButton(_ sender: UIButton) {
        print("Importing Game Saves")
    }
    
    @objc func teamLogoTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        print("Opening Photo Selection Method")
        mediaTypeSelectionAlert()
        
    }
    
    func writeToRealm(){
        
        let realm = try! Realm()
        var fileLogoName: String = ""
        
        if (((realm.objects(teamInfoTable.self).filter(NSPredicate(format: "teamID == %i AND activeState == %@", 0, NSNumber(value: true))).value(forKeyPath: "teamID") as! [Int]).compactMap({Int($0)})).last == nil){
            if teamNameTextField.text != "" {
                
                // generate new team id in function run
                realmTeamIDGen()
                // get new team object
                let newHomeTeam = teamInfoTable()
                // check for profile image being nil aka not set by user, this is an optional field
                if userSelectedProfileImage != nil{
                    // set file name for profile picture
                    fileLogoName = "\((teamID)!)_ID_\((teamNameTextField.text)!)_team_logo"
                    imageWriter(fileName: fileLogoName, imageName: userSelectedProfileImage)
                }
                // write to realm with values given by user
                newHomeTeam.teamID = teamID!
                
                try! realm.write {
                    realm.add(newHomeTeam, update: true)
                    newHomeTeam.nameOfTeam = teamNameTextField.text!
                    newHomeTeam.seasonYear = selectedSeasonNumber
                    newHomeTeam.teamLogoURL = fileLogoName
                    newHomeTeam.activeState = true
                    
                }
                // show success alert
                succesfulTeamAdd(teamName: teamNameTextField.text!)
            }else{
                fatalErrorAlert("Please add a Team Name Before Proceeding")
            }
        }else{
            teamAlreadyPresent()
        }
        
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
    
    func realmTeamIDGen() {
        
        let realm = try! Realm()
        
        if (realm.objects(teamInfoTable.self).max(ofProperty: "teamID") as Int? != nil){
            teamID = ((realm.objects(teamInfoTable.self).max(ofProperty: "teamID")as Int? ?? 0) + 1)
        }else{
            teamID = ((realm.objects(teamInfoTable.self).max(ofProperty: "teamID")as Int? ?? 0))
        }
    }
    
    func fatalErrorAlert(_ msg: String){
        
        let errorAlert = UIAlertController(title: localizedString().localized(value:"Whoops!"), message: localizedString().localized(value:"\(msg)"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(errorAlert, animated: true, completion: nil)
        
    }
    
    //func for succesful team add alert
    func succesfulTeamAdd(teamName: String){
        
        // creating a variable to hold alert controller with attached message and also the style of the alert controller
        let successfulQuery = UIAlertController(title: "Success!", message: "Team \(teamName) was Added Successfully", preferredStyle: UIAlertController.Style.alert)
        //adds action button to alert
        successfulQuery.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "initialSetupPageMover"), object: nil, userInfo: ["sideNumber":2])
        }))
        
        //show the alert
        self.present(successfulQuery, animated: true, completion: nil)
    }
    
    //function for missing field alert
    func teamAlreadyPresent(){
        
        // create the alert
        let doubleTeamAlert = UIAlertController(title: "Whoops!", message: "Looks like we already have a home team in the app, please proceed to the next page.", preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        doubleTeamAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(doubleTeamAlert, animated: true, completion: nil)
    }
    
    // ----------------------------- pickerview delegate methods -------------------------------
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return seasonYearValueArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(seasonYearValueArray[row]) - \(seasonYearValueArray[row] + 1)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedSeasonNumber = seasonYearValueArray[row]
    }
    // -----------------------------------------------------------------------------------------------
}
extension Initial_Setup_Home_Team_Add_View_Controller:  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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

