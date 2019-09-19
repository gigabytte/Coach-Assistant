//
//  Add_Team_Page.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-02-14.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import RealmSwift
import MobileCoreServices
import Zip

class Add_Team_Page: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    //Creates variables for coneceting to the realm database and for the team's ID Number
    var noTeamsBool: Bool = false
    
    var imagePickerController : UIImagePickerController!
    
    //Connections to the page
    @IBOutlet weak var seasonNumberPickerView: UIPickerView!
    @IBOutlet weak var importBackupButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var teamName: UITextField!
    @IBOutlet weak var inActiveTeamToggle: UISwitch!
    @IBOutlet weak var visitWebsiteButton: UIButton!
    @IBOutlet weak var teamLogoImageView: UIImageView!
    
    @IBAction func unwindToAddTeam(segue: UIStoryboardSegue) {}
    
    var seasonYearValueArray: [Int] = [Int]()
    var selectedSeasonNumber: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder() // To get shake gesture
        
        self.seasonNumberPickerView.delegate = self
        self.seasonNumberPickerView.dataSource = self
        
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
        
        seasonYearValueArray = Array(2019...2030)
        selectedSeasonNumber = seasonYearValueArray.first
        
        if((UserDefaults.standard.object(forKey: "defaultHomeTeamID")) == nil){
            delay(0.5){
                
                // create the alert
                let noTeams = UIAlertController(title: localizedString().localized(value:"Let's Start you Off"), message: localizedString().localized(value:"Import your game data from backup or start fresh with a new team. If you need more options please open 'Settings'."), preferredStyle: UIAlertController.Style.alert)
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
        if noTeamsBool == true{
            closeButton.isHidden = false
            visitWebsiteButton.isHidden = true
            importBackupButton.isHidden = false
            view.backgroundColor = systemColour().viewColor()
            
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

    @IBAction func importBackupButton(_ sender: UIButton) {
        
        showUIDocumentController()
    }
    
    @IBAction func visitWebsiteButton(_ sender: UIButton) {
        
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
    @IBAction func closeButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "homePageRefresh"), object: nil, userInfo: ["key":"value"])
        self.dismiss(animated: true, completion: nil)
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
            newTeam.seasonYear = selectedSeasonNumber
            newTeam.nameOfTeam = userInputTeam
            if teamLogoImageView.tag == 20{
                let fileURL = "\((primaryTeamID))_ID_\((teamName.text)!)_team_logo"
                imageWriter(fileName: fileURL, imageName: teamLogoImageView.image!)
                newTeam.teamLogoURL = fileURL
            }
            //writes new team information to database, resets the textbox view and outputs
            //a notification of success
            try! realm.write{
                realm.add(newTeam, update: .modified)
                teamName.text = ""
                teamLogoImageView.image = UIImage(named: "temp_profile_pic_icon")
                if noTeamsBool == true{
                    UserDefaults.standard.set(primaryTeamID, forKey: "defaultHomeTeamID")
                }
                succesfulTeamAdd(teamName: userInputTeam)
            }
        //Checks to see if the text box object is not blank and if the toggle switch is
        //on then adds the primary team ID and the team name to the new team entry.
        }else if(userInputTeam != "" && inActiveTeamToggle.isOn == true){
                newTeam.teamID = primaryTeamID
                newTeam.nameOfTeam = userInputTeam
                newTeam.seasonYear = selectedSeasonNumber
                newTeam.activeState = false
            
            if teamLogoImageView.tag == 20{
                let fileURL = "\((primaryTeamID))_ID_\((teamName.text)!)_team_logo"
                imageWriter(fileName: fileURL, imageName: teamLogoImageView.image!)
                newTeam.teamLogoURL = fileURL
            }
            //writes new team information to database, resets the textbox view and outputs
            //a notification of success
            try! realm.write{
                realm.add(newTeam, update: .modified)
                teamName.text = ""
                teamLogoImageView.image = UIImage(named: "temp_profile_pic_icon")
                if noTeamsBool == true{
                    UserDefaults.standard.set(primaryTeamID, forKey: "defaultHomeTeamID")
                }
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
                self.view.frame.origin.y -= (keyboardSize.height / 1.5)
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
    
    func showUIDocumentController(){
        
        let importMenu = UIDocumentPickerViewController(documentTypes: [String(kUTTypeCommaSeparatedText), String(kUTTypeZipArchive)], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
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
        let message: String!
        
        if noTeamsBool != true{
            message = String(format: localizedString().localized(value:"Team %@ was Added Successfully. To view your newly created team swap the default team in the upper right corner."), teamName)
            
        }else{
            message = String(format: localizedString().localized(value:"Team %@ was Added Successfully."), teamName)
        }
        
        // creating a variable to hold alert controller with attached message and also the style of the alert controller
        let successfulQuery = UIAlertController(title: message, message: "", preferredStyle: UIAlertController.Style.alert)
        //adds action button to alert
        successfulQuery.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            if self.noTeamsBool == true{
                self.noTeamsBool = false
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "homePageRefresh"), object: nil, userInfo: ["key":"value"])
                self.dismiss(animated: true, completion: nil)
            }
        }))
        
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
    
    func importAlert(message: String){
        
        // create the alert
        let importAlert = UIAlertController(title: localizedString().localized(value: message), message: "", preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        importAlert.addAction(UIAlertAction(title: localizedString().localized(value: "OK"), style: UIAlertAction.Style.default, handler: { action in
            
            self.closeButton.isUserInteractionEnabled = false
            self.closeButton.alpha = 0.3
      
        }))
        
        // show the alert
        self.present(importAlert, animated: true, completion: nil)
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
        teamLogoImageView.contentMode = .scaleAspectFill
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
        
        let reSizedImage = imageResizeClass().resizeImage(image: imageName, targetSize: CGSize(width: 300, height: 300))
        
        let imageData = reSizedImage.jpegData(compressionQuality: 0.50)
        
        
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
extension Add_Team_Page: UIDocumentPickerDelegate{
    
    
    func documentPicker(_ documentPicker: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        
        if  urls.count > 1 {
            fatalError("Please import your 'coachAssistantBackup.zip file. THe file selected does not meet this criteria.'")
        }else {
            unZipBackup(documentURL: urls.first!)
            
            return
        }
    }
    
    func documentMenu(_ documentMenu: UIDocumentPickerViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("document Picker Was Cancelled")
        controller.dismiss(animated: true, completion: nil)
    }
    
    func moveFileToLocal(){
        
        var isDir:ObjCBool = false
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let path = dir.appendingPathComponent("Backups")//.appendingPathComponent("default.realm")
            let realmDefaultPath = path.appendingPathComponent("default.realm")
            
            if FileManager.default.fileExists(atPath: realmDefaultPath.path, isDirectory: &isDir) {
                
                
                do {
                    // replace realm.default with backup
                    print(realmDefaultPath)
                    try FileManager.default.replaceItemAt(dir.appendingPathComponent("default.realm"), withItemAt: realmDefaultPath)
                    
                    do{
                        let playerImagesBckupDIR = dir.appendingPathComponent("Backups").appendingPathComponent("PlayerImages")
                        try FileManager.default.replaceItemAt(dir.appendingPathComponent("PlayerImages"), withItemAt: playerImagesBckupDIR)
                        
                        
                        do{
                            let teamImagesBckupDIR = dir.appendingPathComponent("Backups").appendingPathComponent("TeamLogo")
                            try FileManager.default.replaceItemAt(dir.appendingPathComponent("TeamLogo"), withItemAt: teamImagesBckupDIR)
                            
                            self.importAlert(message: "Successfully Import Backup of Backup. Restart app in inorder for changes to take full effect")
                        }catch{
                            print(error)
                            fatalError("Error attempting to replace team logo's file from backup to home directory, please contact support")
                            //cannot copy player images backup to home dir
                        }
                        
                    }catch{
                        fatalError("Error attempting to replace player profile images file from backup to home directory, please contact support")
                    }
                }catch{
                    // no playrimages dir in home dir to remove
                    print(error)
                    fatalError("Error attempting to replace database file to home directory, please contact support")
                }
                
            }else{
                fatalError("Error finding backup databse file, please try again before contacting support")
            }
        }
    }
    
    func unZipBackup(documentURL: URL){
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let destinationURL = dir.appendingPathComponent("Backups")
            if FileManager.default.fileExists(atPath: destinationURL.path){
                try! Zip.unzipFile(documentURL, destination: destinationURL, overwrite: true, password: nil, progress: { (progress) in
                    print(progress)
                    if progress == 1.0{
                        self.moveFileToLocal()
                    }
                })
            }
        }else{
            print("cannot find backups dir")
        }
    }
    
    func deleteAllTempFiles(){
        let tempFileURLSDIR =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!).appendingPathComponent("Backups")
        
        do {
            
            let tempFileURLs = try FileManager.default.contentsOfDirectory(at: tempFileURLSDIR,
                                                                           includingPropertiesForKeys: nil,
                                                                           options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            
            for fileURL in tempFileURLs {
                
                try FileManager.default.removeItem(at: fileURL)
                
            }
            
        } catch  {
            print(error)
            
        }
    }
    
   
    
}
