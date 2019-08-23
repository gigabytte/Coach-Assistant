//
//  Player Stats View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-08-19.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import RealmSwift

class Locker_Room_Player_Stats_View_Controller: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var teamLogoImageView: UIImageView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var seasonNumberLabel: UILabel!
    @IBOutlet weak var teamSeasonRecordLabel: UILabel!
    @IBOutlet weak var teamInfoAreaView: UIView!
    
    var selectedTeamID: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(myMethod(notification:)), name: NSNotification.Name(rawValue: "homePageRefresh"), object: nil)
        
       onLoad()
        // Do any additional setup after loading the view.
    }
    
    func onLoad(){
        
        let realm = try! Realm()
        
        selectedTeamID =  UserDefaults.standard.integer(forKey: "defaultHomeTeamID")
        
        let teamObjc = realm.object(ofType: teamInfoTable.self, forPrimaryKey: selectedTeamID)
        
        // add tap gesture to team logo
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(teamLogoTapped(tapGestureRecognizer:)))
        teamInfoAreaView.isUserInteractionEnabled = true
        teamInfoAreaView.addGestureRecognizer(tapGestureRecognizer)
        
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
                let readerResult = imageReader(fileName: (teamObjc?.teamLogoURL)!)
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
        
        teamSeasonRecordLabel.text = "W:\(String(homeTeamWinCount))-L:\(String(homeTeamLooseCount))-T:\(String(homeTeamTieCount))"
    }
    
    func openTeamAbout(){
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let popupVC = storyboard.instantiateViewController(withIdentifier: "Team_About_Popup_View_Controller") as! Team_About_Popup_View_Controller
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = .crossDissolve
        let pVC = popupVC.popoverPresentationController
        pVC?.permittedArrowDirections = .any
        pVC?.delegate = self
        
        present(popupVC, animated: true, completion: nil)
        print("Team About Presented!")
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
                //return(retreivedImage!)
                
            }
        }
        return(retreivedImage)
    }
    
    func fatalErrorAlert(_ msg: String){
        
        let errorAlert = UIAlertController(title: localizedString().localized(value:"Whoops!"), message: localizedString().localized(value:"\(msg)"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(errorAlert, animated: true, completion: nil)
        
    }
    
    @objc func myMethod(notification: NSNotification){
        onLoad()
        
    }
    
    
    @objc func teamLogoTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        print("Opening Home Team About")
        openTeamAbout()
        
    }
    
    

}
