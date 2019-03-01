//
//  ViewController.swift  Main Dashboard
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-01-10.
//  Copyright © 2019 MAG Industries. All rights reserved.
//
import UIKit
import RealmSwift
import Realm

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // get rotation allowances of device
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // set auto rotation to true for current view
        appDelegate.shouldRotate = true
        
        
        /*----------------------------------------------------------------
         uncomment code block if chnages to DB tables are made,
         build app then comment code again and build app like normal*/
        //let defaultPath = Realm.Configuration.defaultConfiguration.fileURL?.path
        //try! FileManager.default.removeItem(atPath: defaultPath!)
        /*________________________________________________________________*/
        let realm = try! Realm()
        // get Realm Databse file location
        print(Realm.Configuration.defaultConfiguration.fileURL)

    }
    
    @IBAction func newGameButton(_ sender: UIButton) {
        
        let realm = try! Realm()
        // get first an last team entered in DB
        let teamOne = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "teamID >= %i AND activeState == %@", 0, NSNumber(value: true))).value(forKeyPath: "teamID") as! [Int]).compactMap({Int($0)})
        let teamTwo = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "teamID >= %i AND activeState == %@", 0, NSNumber(value: true))).value(forKeyPath: "teamID") as! [Int]).compactMap({Int($0)})
        let playerOne = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID >= %i AND activeState == %@", 0, NSNumber(value: true))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        let playerTwo = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID >= %i AND activeState == %@", 0, NSNumber(value: true))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        print(teamOne)
        print(teamTwo)
        print(playerOne)
        print(playerTwo)
        // check if team one returns nil and that team one isnt team two
        // check for only one team entered and or no team entered
        if(teamOne.first != nil && playerOne.first != nil && teamOne.first != teamTwo.last && playerOne.first != playerTwo.last){
            self.performSegue(withIdentifier: "newGameButtonSegue", sender: nil);
            
        }else{
            // if teams or players are not avaiable top be pulled alert error appears
            dataReturnNilAlert()
        }
    }
    // if teams or players are not avaiable top be pulled alert error appears
    func dataReturnNilAlert(){
        
        // create the alert
        let nilAlert = UIAlertController(title: "Data Error", message: "Please add Teams and Players to App before starting a new Game.", preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        nilAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(nilAlert, animated: true, completion: nil)
        
    }
}
