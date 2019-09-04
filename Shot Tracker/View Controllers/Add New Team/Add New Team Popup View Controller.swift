//
//  Add New Team Popup View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-08-29.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import RealmSwift

class Add_New_Team_Popup_View_Controller: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,  UITextFieldDelegate  {

    @IBOutlet weak var teamSaveButton: UIButton!
    @IBOutlet weak var seasonYearLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var addTeamTitleLabel: UILabel!
    @IBOutlet weak var seasonYearPickerView: UIPickerView!
    @IBOutlet weak var teamNameTextField: UITextField!
    
    var seasonYearValueArray: [Int] = [Int]()
    var selectedSeasonNumber: Int!
    var teamID: Int!
    
    var imagePickerController : UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.seasonYearPickerView.delegate = self
        self.seasonYearPickerView.dataSource = self
        
        teamNameTextField.delegate = self
        teamNameTextField.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(teamLogoTapped(tapGestureRecognizer:)))
            profileImageView.isUserInteractionEnabled = true
            profileImageView.addGestureRecognizer(tapGestureRecognizer)
        
        onLoad()
    }
    
    func viewColour(){
        //self.view.backgroundColor = systemColour().viewColor()
        
    }
    
    func onLoad(){
        
        viewColour()
        
        seasonYearValueArray = Array(2019...2030)
        selectedSeasonNumber = seasonYearValueArray.first
        
        let angle = CGFloat(Double.pi)
        let tr = CGAffineTransform.identity.rotated(by: angle)
        backButton.transform = tr
        backButton.isHidden = true
        
        // disable picker and save button unless name is added
        teamSaveButton.isUserInteractionEnabled = false
        seasonYearPickerView.isUserInteractionEnabled = false
    }
    
    func realmLogoRefrence(fileURL: String, teamID: Int){
        let realm = try! Realm()
        
        let teamObjc = realm.object(ofType: teamInfoTable.self, forPrimaryKey: teamID);
        
        try! realm.write {
            
            teamObjc!.teamLogoURL = fileURL
            
        }
        
    }
    
    func realmTeamIDGen() {
        
        let realm = try! Realm()
        
        if (realm.objects(teamInfoTable.self).max(ofProperty: "teamID") as Int? != nil){
            teamID = ((realm.objects(teamInfoTable.self).max(ofProperty: "teamID")as Int? ?? 0) + 1)
        }else{
            teamID = ((realm.objects(teamInfoTable.self).max(ofProperty: "teamID")as Int? ?? 0))
        }
    }
    
    func phadeIn(fadeInBool: Bool){
        switch fadeInBool {
        case true:
            profileImageView.isHidden = false
            backButton.isHidden = false
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                self.seasonYearPickerView.alpha = 0.0
                self.seasonYearLabel.alpha = 0.0
                self.teamNameTextField.alpha = 0.0
                
                self.profileImageView.alpha = 1.0
                self.backButton.alpha = 1.0
                
                self.view.layoutIfNeeded()
                
            }, completion: { _ in
                self.seasonYearPickerView.isHidden = true
                self.teamNameTextField.isHidden = true
                self.seasonYearLabel.isHidden = true
                
            })
            break
        case false:
            self.seasonYearPickerView.isHidden = false
            self.teamNameTextField.isHidden = false
            self.seasonYearLabel.isHidden = false
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                self.seasonYearPickerView.alpha = 1.0
                self.seasonYearLabel.alpha = 1.0
                self.teamNameTextField.alpha = 1.0
                
                self.profileImageView.alpha = 0.0
                self.backButton.alpha = 0.0
                
                self.view.layoutIfNeeded()
                
            }, completion: { _ in
                self.profileImageView.isHidden = true
                self.backButton.isHidden = true
                
            })
            break
        default:
            profileImageView.isHidden = false
            backButton.isHidden = false
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                self.seasonYearPickerView.alpha = 0.0
                self.seasonYearLabel.alpha = 0.0
                self.teamNameTextField.alpha = 0.0
                
                self.profileImageView.alpha = 1.0
                self.backButton.alpha = 1.0
                
                self.view.layoutIfNeeded()
                
            }, completion: { _ in
                self.seasonYearPickerView.isHidden = true
                self.teamNameTextField.isHidden = true
                self.seasonYearLabel.isHidden = true
                
            })
             break
        }
        
        
    }
    
    func mediaTypeSlectionAlert(){
        
        // create the alert
        let mediaAlert = UIAlertController(title: localizedString().localized(value:"Logo Update"), message: localizedString().localized(value:"Select the location that your team logo should come from. Selecting Camera will allow for you to take a brand new image. Libary will allow you to select an image from your photo libary on your device"), preferredStyle: UIAlertController.Style.alert)
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
    
    @objc func teamLogoTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        print("Opening Photo Selection Method")
        mediaTypeSlectionAlert()
        
    }

    @IBAction func saveTeamInfoButton(_ sender: UIButton) {
        
        let realm = try! Realm()
        let newTeam = teamInfoTable()
        
        if sender.tag == 10{
            phadeIn(fadeInBool: true)
            teamSaveButton.setTitle("Save Team Info", for: .normal)
            addTeamTitleLabel.text = "Add Team Logo"
            
            sender.tag = 20
        }else {
            
            // write to relam
            try! realm.write{
                newTeam.teamID = teamID
                newTeam.nameOfTeam = teamNameTextField.text!
                if profileImageView.tag != 10 {
                    newTeam.teamLogoURL = "\((teamID)!)_ID_\((teamNameTextField.text)!)_team_logo"
                }
                realm.add(newTeam, update:true)
            }
            
        }
        
    }
    
     @IBAction func closeButton(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
     }
    
    @IBAction func backButton(_ sender: UIButton) {
        addTeamTitleLabel.text = "Add Team Name"
        teamSaveButton.setTitle("Next Step ...", for: .normal)
        teamSaveButton.tag = 10
        phadeIn(fadeInBool: false)
    }
    
   
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == teamNameTextField{
            print("hi")
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                
                self.teamSaveButton.alpha = 1.0
                self.seasonYearLabel.alpha = 1.0
                self.seasonYearPickerView.alpha = 1.0
            }, completion: { _ in
                self.seasonYearPickerView.isUserInteractionEnabled = true
                self.teamSaveButton.isUserInteractionEnabled = true
            })
        }
    }
    
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
}
extension Add_New_Team_Popup_View_Controller:  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        guard let selectedImage = info[.editedImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
         realmTeamIDGen()
        
        imageWriter(fileName: "\((teamID)!)_ID_\((teamNameTextField.text)!)_team_logo", imageName: selectedImage)
        onLoad()
        
        
        //Dismiss the UIImagePicker after selection
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        self.dismiss(animated: true, completion: nil)
    }
    
    func imageWriter(fileName: String, imageName: UIImage){
        
        let realm = try! Realm()
        
        
        let imageData = imageName.jpegData(compressionQuality: 0.25)
        
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let tempUrl = dir.appendingPathComponent("TeamLogo")
            let fileURL = tempUrl.appendingPathComponent(fileName)
            
            print(fileURL)
            
            do {
                try imageData!.write(to: fileURL, options: .atomicWrite)
                // send realm the location of the logo in DD
                realmLogoRefrence(fileURL: fileName, teamID: teamID)
                
            } catch {
                profileImageView.tag = 10
                print("Team logo write error")
                //fatalErrorAlert("An error has occured while attempting to save your team logo. Please contact support!")
            }
        }
    }
    
    func imageReader(fileName: String) -> UIImage{
        
        var retreivedImage: UIImage!
        
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let URLs = dir.appendingPathComponent("TeamLogo")
            let newURL = URLs.appendingPathComponent(fileName)
            
            do {
                let readData = try Data(contentsOf: newURL)
                retreivedImage = UIImage(data: readData)
                
            } catch {
                profileImageView.tag = 10
                print("Team logo read error")
                //fatalErrorAlert("An error has occured while attempting to retrieve your team logo. Please contact support!")
                
            }
        }
        if retreivedImage != nil{
            return(retreivedImage)
        }else{
            return(UIImage(named: "temp_profile_pic_icon")!)
        }
    }
}
