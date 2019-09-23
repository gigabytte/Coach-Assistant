//
//  Initial_Setup_Welcome_Page_View_Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-09-02.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import MobileCoreServices
import RealmSwift
import Zip

class Initial_Setup_Welcome_Page_View_Controller: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("qwdwqdqqwd")
        // Do any additional setup after loading the view.
    }
    
    func showUIDocumentController(){
        //kUTTypeZipArchive
        let importMenu = UIDocumentPickerViewController(documentTypes: [kUTTypeZipArchive as String], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
    }
    // --------------------------------------- popup alerts -------------------------------------------------------
    func fatalErrorAlert(_ msg: String){
        
        let errorAlert = UIAlertController(title: localizedString().localized(value:"Whoops!"), message: localizedString().localized(value:"\(msg)"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(errorAlert, animated: true, completion: nil)
        
    }
    
    func importAlert(message: String){
        
        // create the alert
        let importAlert = UIAlertController(title: localizedString().localized(value: message), message: "", preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        importAlert.addAction(UIAlertAction(title: localizedString().localized(value: "OK"), style: UIAlertAction.Style.default, handler: { action in
            let realm = try! Realm()
            let teamID = (realm.objects(teamInfoTable.self).filter(NSPredicate(format: "activeState == true")).value(forKeyPath: "teamID") as! [Int]).compactMap({Int($0)}).first
            
            if teamID != nil{
                UserDefaults.standard.set(teamID, forKey: "defaultHomeTeamID")
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "initialSetupPageMover"), object: nil, userInfo: ["sideNumber":5])
        }))
        
        // show the alert
        self.present(importAlert, animated: true, completion: nil)
    }
    //----------------------------------------------------------------------------------------------------------------
    
  
    @IBAction func importGameBackup(_ sender: UIButton) {
        self.showUIDocumentController()
        
    }
}
extension Initial_Setup_Welcome_Page_View_Controller: UIDocumentPickerDelegate,UINavigationControllerDelegate{
    
    
    func documentPicker(_ documentPicker: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        if urls.first?.pathExtension == "zip"{
           
            if  urls.count > 1 {
                fatalErrorAlert("Please import your 'coachAssistantBackup.zip file. The file selected does not meet this criteria.'")
            }else {
                unZipBackup(documentURL: urls.first!)
                
                return
            }
        }else{
            fatalErrorAlert("Please import your 'coachAssistantBackup.zip file. The file selected does not meet this criteria.'")
        }
    }
    
    func documentMenu(_ documentMenu: UIDocumentPickerViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("document Picker Was ")
        controller.dismiss(animated: true, completion: nil)
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
    
    func unZipBackup(documentURL: URL){
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let destinationURL = dir.appendingPathComponent("Backups")
            if FileManager.default.fileExists(atPath: destinationURL.path){
                do{
                    try Zip.unzipFile(documentURL, destination: destinationURL, overwrite: true, password: nil, progress: { (progress) in
                        print(progress)
                        if progress == 1.0{
                            self.moveFileToLocal()
                        }
                    })
                }catch{
                    fatalErrorAlert("Cannot unzip backup, please contact support")
                }
            }
        }else{
            fatalErrorAlert("Cannot find backups directory, please contact support")
            print("cannot find backups dir")
        }
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
                            deleteAllTempFiles()
                            self.importAlert(message: "Successfully Import Backup of Backup. Restart app in inorder for changes to take full effect")
                        }catch{
                            print(error)
                            fatalErrorAlert("Error attempting to replace team logo's file from backup to home directory, please contact support")
                            //cannot copy player images backup to home dir
                        }
                        
                    }catch{
                        fatalErrorAlert("Error attempting to replace player profile images file from backup to home directory, please contact support")
                    }
                }catch{
                    // no playrimages dir in home dir to remove
                    print(error)
                    fatalErrorAlert("Error attempting to replace database file to home directory, please contact support")
                }
                
            }else{
                fatalErrorAlert("Error finding backup databse file, please try again before contacting support")
            }
        }
    }
}

