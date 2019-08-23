//
//  Team About Popup View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-08-23.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import RealmSwift
import Charts

class Team_About_Popup_View_Controller: UIViewController {

    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var teamLogoImageView: UIImageView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var seasonNumberLabel: UILabel!
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var teamBarChartView: BarChartView!
    
    var imagePickerController : UIImagePickerController!
    
    var selectedTeamID: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedTeamID =  UserDefaults.standard.integer(forKey: "defaultHomeTeamID")
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(teamLogoTapped(tapGestureRecognizer:)))
        teamLogoImageView.isUserInteractionEnabled = true
        teamLogoImageView.addGestureRecognizer(tapGestureRecognizer)
        
        // add blur effect to view along with popUpView
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.addSubview(popUpView)
        
        
        onLoad()
        // Do any additional setup after loading the view.
    }
    
    func onLoad(){
        
        let realm = try! Realm()
        let teamObjc = realm.object(ofType: teamInfoTable.self, forPrimaryKey: selectedTeamID)
        
        
        if let teamName = teamObjc?.nameOfTeam{
            if teamName != ""{
                teamNameLabel.text = teamName
            }else{
                teamNameLabel.text = "Unknow Team Name"
            }
        }
        
        if let teamSeason = teamObjc?.seasonYear{
            if teamSeason != 0{
                seasonNumberLabel.text = String(teamSeason)
            }else{
                seasonNumberLabel.text = "2020"
            }
        }
        
        
        if let URL = teamObjc?.teamLogoURL{
            if URL != ""{
                let readerResult = imageReader(fileName: teamObjc!.teamLogoURL)
                if readerResult != nil{
                    teamLogoImageView.image = readerResult as? UIImage
                }else{
                    //teamLogoImageView.image = reader.
                }
            }
        }
        
        teamLogoImageView.layer.masksToBounds = true
        teamLogoImageView.layer.borderWidth = 3
        teamLogoImageView.layer.borderColor = UIColor.black.cgColor
        teamLogoImageView.layer.cornerRadius = teamLogoImageView.bounds.width / 2
        
        
        DispatchQueue.main.async {
            self.teamLogoImageView.reloadInputViews()
        }
    
        recordLabelProcessing()
    }
    
    func recordLabelProcessing(){
        
        let realm = try! Realm()
        
        let homeTeamWinCount = (realm.objects(newGameTable.self).filter(NSPredicate(format: "tieGameBool == false AND winingTeamID == %i AND activeState == true AND activeGameStatus == false", selectedTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)}).count
        let homeTeamTieCount =  (realm.objects(newGameTable.self).filter(NSPredicate(format: "tieGameBool == true AND homeTeamID == %i AND activeState == true AND activeGameStatus == false", selectedTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)}).count
        let homeTeamLooseCount =  (realm.objects(newGameTable.self).filter(NSPredicate(format: "tieGameBool == false AND losingTeamID == %i AND activeState == true AND activeGameStatus == false", selectedTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)}).count
        
        recordLabel.text = "W:\(String(homeTeamWinCount))-L:\(String(homeTeamLooseCount))-T:\(String(homeTeamTieCount))"
    }
    
    func realmLogoRefrence(fileURL: String){
        let realm = try! Realm()
        
        let teamObjc = realm.object(ofType: teamInfoTable.self, forPrimaryKey: selectedTeamID);
        
        try! realm.write {
            
            teamObjc!.teamLogoURL = fileURL
            
        }
        
    }
    
    func fatalErrorAlert(_ msg: String){
        
        let errorAlert = UIAlertController(title: localizedString().localized(value:"Whoops!"), message: localizedString().localized(value:"\(msg)"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(errorAlert, animated: true, completion: nil)
        
    }
    
    func mediaTypeSlectionAlert(){
        
        // create the alert
        let mediaAlert = UIAlertController(title: localizedString().localized(value:"Logo Update"), message: localizedString().localized(value:"Select the location that your team logo should come from. Selecting Camera ill allow for you to take a brand new image. Libary will allow you to select an image from your photo libary on your device"), preferredStyle: UIAlertController.Style.alert)
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
    
    
    @IBAction func closeButton(_ sender: Any) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "homePageRefresh"), object: nil, userInfo: ["key":"value"])
        self.dismiss(animated: true, completion: nil)
       
    }
    
    @objc func teamLogoTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        print("Opening Photo Selection Method")
        mediaTypeSlectionAlert()
        
    }
    
    
  

}

extension Team_About_Popup_View_Controller:  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
  
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let realm = try! Realm()
        let teamObjc = realm.object(ofType: teamInfoTable.self, forPrimaryKey: selectedTeamID)
        
        guard let selectedImage = info[.editedImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        imageWriter(fileName: "\((teamObjc?.nameOfTeam)!)_team_logo", imageName: selectedImage)
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
            
            let tempUrl = dir.appendingPathComponent("TeamLogo")
            let fileURL = tempUrl.appendingPathComponent(fileName)
            
            print(fileURL)
            
            do {
                try imageData.write(to: fileURL, options: .atomicWrite)
                // send realm the location of the logo in DD
                realmLogoRefrence(fileURL: "\(fileName)")
                
            } catch {
                print("Team logo write error")
                fatalErrorAlert("An error has occured while attempting to save your team logo. Please contact support!")
            }
        }
    }
    
    func imageReader(fileName: String) -> Any{
        
        var retreivedImage: UIImage!
    
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
           
            let URLs = dir.appendingPathComponent("TeamLogo")
            let newURL = URLs.appendingPathComponent(fileName)
            
            do {
                let readData = try Data(contentsOf: newURL)
                retreivedImage = UIImage(data: readData)
                
            } catch {
                print("Team logo read error")
                fatalErrorAlert("An error has occured while attempting to retrieve your team logo. Please contact support!")
                return(retreivedImage)
               
            }
        }
        return(retreivedImage)
    }
}
