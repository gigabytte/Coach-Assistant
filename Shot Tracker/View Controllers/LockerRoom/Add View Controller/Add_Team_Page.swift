//
//  Add_Team_Page.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-02-14.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class Add_Team_Page: UIViewController {

    //Creates variables for coneceting to the realm database and for the team's ID Number
    var noTeamsBool: Bool!
    
    var imagePickerController : UIImagePickerController!
    
    //Connections to the page
    @IBOutlet weak var teamName: UITextField!
    @IBOutlet weak var inActiveTeamToggle: UISwitch!
    @IBOutlet weak var visitWebsiteButton: UIButton!
    @IBOutlet weak var teamLogoImageView: UIImageView!
    
    @IBAction func unwindToAddTeam(segue: UIStoryboardSegue) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder() // To get shake gesture
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(teamLogoTapped(tapGestureRecognizer:)))
        teamLogoImageView.isUserInteractionEnabled = true
        teamLogoImageView.addGestureRecognizer(tapGestureRecognizer)
       
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(myMethod(notification:)), name: NSNotification.Name(rawValue: "homePageRefresh"), object: nil)
        
        onLoad()

    }
    
    // We are willing to become first responder to get shake motion
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    func onLoad(){
        if((UserDefaults.standard.object(forKey: "defaultHomeTeamID")) == nil){
            delay(0.5){
                
                // create the alert
                let noTeams = UIAlertController(title: localizedString().localized(value:"New to the App?"), message: localizedString().localized(value:"Please add at least one team before adding a default team or import a team from settings."), preferredStyle: UIAlertController.Style.alert)
                // add an action (button)
                noTeams.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                // add an action (button)
                noTeams.addAction(UIAlertAction(title: localizedString().localized(value:"Settings"), style: UIAlertAction.Style.destructive,  handler: {action in
                    self.performSegue(withIdentifier: "noTeamSettingsSegue", sender: nil);
                }))
                // show the alert
                self.present(noTeams, animated: true, completion: nil)
            }
        }
        
        viewColour()
    }
    
    func viewColour(){
        teamLogoImageView.heightAnchor.constraint(equalToConstant: teamLogoImageView.frame.height).isActive = true
        teamLogoImageView.setRounded()
       
        teamName.backgroundColor = systemColour().uiTextField()
        
    }
    
    func realmTeamIDGen() -> Int{
        
        let realm = try! Realm()
        let primaryTeamID: Int!
        if (realm.objects(teamInfoTable.self).max(ofProperty: "teamID") as Int? != nil){
            primaryTeamID = ((realm.objects(teamInfoTable.self).max(ofProperty: "teamID")as Int? ?? 0) + 1)
        }else{
            primaryTeamID = ((realm.objects(teamInfoTable.self).max(ofProperty: "teamID")as Int? ?? 0))
        }
        
        return primaryTeamID
    }
    
    func realmLogoRefrence(fileURL: String, teamID: Int){
        let realm = try! Realm()
        
        let teamObjc = realm.object(ofType: teamInfoTable.self, forPrimaryKey: teamID);
        
        try! realm.write {
            
            teamObjc!.teamLogoURL = fileURL
            
        }
        
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
    //Func for when the add button is clicked
    @IBAction func saveteamName(_ sender: UIButton){
        
         let realm = try! Realm()
        //Takes user's input and stores it in the userinput variable
        let userInputTeam: String = teamName.text!
        let primaryTeamID = realmTeamIDGen()
        let newTeam = teamInfoTable()
        
        //Checks to see if the text box object is not blank and if the toggle switch is
        //not on then adds the primary team ID and the team name to the new team entry.
        if (userInputTeam != "" && inActiveTeamToggle.isOn != true){
            newTeam.teamID = primaryTeamID
            newTeam.nameOfTeam = userInputTeam
            if teamLogoImageView.tag == 20{
                let fileURL = "\((primaryTeamID))_ID_\((teamName.text)!)_team_logo"
                imageWriter(fileName: fileURL, imageName: teamLogoImageView.image!)
                newTeam.teamLogoURL = fileURL
            }
            //writes new team information to database, resets the textbox view and outputs
            //a notification of success
            try! realm.write{
                realm.add(newTeam, update:true)
                teamName.text = ""
                teamLogoImageView.image = UIImage(named: "temp_profile_pic_icon")
                succesfulTeamAdd(teamName: userInputTeam)
            }
        //Checks to see if the text box object is not blank and if the toggle switch is
        //on then adds the primary team ID and the team name to the new team entry.
        }else if(userInputTeam != "" && inActiveTeamToggle.isOn == true){
                newTeam.teamID = primaryTeamID
                newTeam.nameOfTeam = userInputTeam
                newTeam.activeState = false
            
            if teamLogoImageView.tag == 20{
                let fileURL = "\((primaryTeamID))_ID_\((teamName.text)!)_team_logo"
                imageWriter(fileName: fileURL, imageName: teamLogoImageView.image!)
                newTeam.teamLogoURL = fileURL
            }
            //writes new team information to database, resets the textbox view and outputs
            //a notification of success
            try! realm.write{
                realm.add(newTeam, update:true)
                teamName.text = ""
                teamLogoImageView.image = UIImage(named: "temp_profile_pic_icon")
                succesfulTeamAdd(teamName: userInputTeam)
            }
        }else{
            //If team name text box is empty it calls an alert
            missingFieldAlert()
        }
    }
    
    @objc func teamLogoTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        print("Opening Photo Selection Method")
        mediaTypeSlectionAlert()
        
    }
    
    // if keyboard is out push whole view up half the height of the keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height / 2)
            }
        }
    }
    // when keybaord down return view back to y orgin of 0
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc func myMethod(notification: NSNotification){
        onLoad()
    }
   
    func mediaTypeSlectionAlert(){
        
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
    
    //func for succesful team add alert
    func succesfulTeamAdd(teamName: String){
        
        // creating a variable to hold alert controller with attached message and also the style of the alert controller
        let successfulQuery = UIAlertController(title: String(format: localizedString().localized(value:"Team %@ was Added Successfully. To view your newly created team swap the default team in the upper right corner."), teamName), message: "", preferredStyle: UIAlertController.Style.alert)
        //adds action button to alert
        successfulQuery.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        //show the alert
        self.present(successfulQuery, animated: true, completion: nil)
    }
    //function for missing field alert
    func missingFieldAlert(){
            
        // create the alert
        let missingField = UIAlertController(title: localizedString().localized(value:"Missing Field Error"), message: localizedString().localized(value:"Please have 'Team Name' filled out before attempting to change the team name."), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        missingField.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(missingField, animated: true, completion: nil)
    }
    //function for missing field alert
    func noTeamAlert(){
        
        // create the alert
        let noTeamAlert = UIAlertController(title: "Whoops!", message: localizedString().localized(value:"Please add a team before attempting to add players."), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        noTeamAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(noTeamAlert, animated: true, completion: nil)
    }

    // delay loop
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
}
extension Add_Team_Page:  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        guard let selectedImage = info[.editedImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
            teamLogoImageView.tag = 10
        }
        teamLogoImageView.image = selectedImage
        teamLogoImageView.heightAnchor.constraint(equalToConstant: teamLogoImageView.frame.height).isActive = true
        teamLogoImageView.setRounded()
        teamLogoImageView.tag = 20
        //Dismiss the UIImagePicker after selection
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        self.dismiss(animated: true, completion: nil)
        teamLogoImageView.tag = 10
    }
    
    func imageWriter(fileName: String, imageName: UIImage){
        
        let imageData = imageName.jpegData(compressionQuality: 0.25)
        
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let tempUrl = dir.appendingPathComponent("TeamLogo")
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
