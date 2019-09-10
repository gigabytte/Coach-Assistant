//
//  Settings_Backup View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-19.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import SwiftyStoreKit
import MobileCoreServices
import Zip

final class Settings_Backup_View_Controller: UITableViewController, UIPopoverPresentationControllerDelegate{
    
    @IBOutlet weak var backToiClkoudLabel: UILabel!
    @IBOutlet var backupTableView: UITableView!
    @IBOutlet weak var icloudToggleSwitch: UISwitch!
    @IBOutlet weak var backupDateLabel: UILabel!
    @IBOutlet weak var backupLabel: UILabel!
    @IBOutlet weak var importLabel: UILabel!
    
    var successImport: Bool!
    var productID: String!
    var runOnceBool: Bool = false
    var importPlayersBool: Int!
    
    var csvText_newGameTable: String!
    var csvText_faceoffTable: String!
    var csvText_goalMarkerTable: String!
    var csvText_overallStatsTable: String!
    var csvText_penaltyInfoTable: String!
    var csvText_playerInfoTable: String!
    var csvText_shotMarkerTable: String!
    var csvText_teamInfoTable: String!
    
    
    var pathURLs: [URL] = [URL]()
    
    var playerNamesFromCSV: [String] = [String]()
    var playerJerseyNumFromCSV: [Int] = [Int]()
    var playerLineNumFromCSV: [Int] = [Int]()
    var playerLineTypeFromCSV: [String] = [String]()
    
    var teamNameFromCSV: [String] = [String]()
    var teamSeasonYearFromCSV: [Int] = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(myMethod(notification:)), name: NSNotification.Name(rawValue: "backupSettingsPageRefresh"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(myColorMethod(notification:)), name: NSNotification.Name(rawValue: "darModeToggle"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(myResetMethod(notification:)), name: NSNotification.Name(rawValue: "deleteOldValues"), object: nil)
        
        productID = universalValue().coachAssistantProID
        // check is icloud conatiner exsiss on user icloud account

        backupUpDateCheck()
    
        
        // check icloud exprt criteria
        reloadView()
        print("Back Up View Controller Called")
        viewColour()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (UserDefaults.standard.bool(forKey: "userPurchaseConf") != true && runOnceBool == false){
            upgradeNowAlert()
            runOnceBool = true
        }
        reloadView()
        print("Back Up View Controller Appeared")
    }
    
    func viewColour(){
        
        self.tableView.backgroundColor = systemColour().tableViewColor()
    }
    
   
    
    func reloadView(){
        
        icloudToggleSwitch.isOn = UserDefaults.standard.bool(forKey: "iCloudBackupToggle")
        
        if (UserDefaults.standard.bool(forKey: "userPurchaseConf") == true){
            if (icloudAccountCheck().isICloudContainerAvailable() == true){
                if (icloudToggleSwitch.isOn == true){
                    
                    print("User can export to iCloud")
                    backupLabel.text = "iCloud Backup"
                    importLabel.text = "Import Game Saves from iCloud"
                    
                    
                }else{
                    print("User cannot export to iCLoud!")
                    
                    backupLabel.text = "Backup Locally"
                    importLabel.text = "Import Backup Game Saves Locally"
                    
                }
            }else{
                print("USer not logged in icloud")
                missingIcloudCredsAlert()
            }
        }else{
            print("User is not PRO yet cannot use iCloud")
            icloudToggleSwitch.isUserInteractionEnabled = false
            icloudToggleSwitch.alpha = 0.5
            backToiClkoudLabel.alpha = 0.5
          
        }
    }
    // ------------------------- listener functions ---------------------------------
    @objc func myMethod(notification: NSNotification){
     
        delayClass().delay(0.5){
            self.importAlert(message: localizedString().localized(value: "Your data was Successfully Imported!"))
        }
    }
    
    @objc func myColorMethod(notification: NSNotification){
        viewColour()
    }
    
    @objc func myResetMethod(notification: NSNotification){
        playerLineNumFromCSV.removeAll()
        playerLineTypeFromCSV.removeAll()
        playerNamesFromCSV.removeAll()
        playerJerseyNumFromCSV.removeAll()
    }
    
    // -----------------------------------------------------------------------------------
    @IBAction func icouldToggleSwitch(_ sender: Any) {
        
        if (icloudToggleSwitch.isOn == true && icloudAccountCheck().isICloudContainerAvailable() == true){
            
            
            backupLabel.text = "iCloud Backup"
            importLabel.text = "Import iCloud Backup"
        
            UserDefaults.standard.set(true, forKey: "iCloudBackupToggle")
        }else {
            icloudToggleSwitch.isOn = false
            missingIcloudCredsAlert()
            backupLabel.text = "Backup Locally"
            importLabel.text = "Import Backup Locally"
            
            
            UserDefaults.standard.set(false, forKey: "iCloudBackupToggle")
        }
    }
    
    
    
    func backupUpDateCheck(){
        
        if(UserDefaults.standard.object(forKey: "lastBackup") != nil){
            backupDateLabel.text = "Last Known Backup: \(UserDefaults.standard.object(forKey: "lastBackup") as! String)"
        }else{
            backupDateLabel.text = "Backup has not been Performed!"
        }
        
    }

    
    func lineTypeFormatChecker(lineType: String) -> Bool{
        switch lineType.trimmingCharacters(in: .whitespacesAndNewlines) {
        case "LW":
            return true
        case "RW":
            return true
        case "LD":
            return true
        case "RD":
            return true
        case "G":
            return true
        default:
            return false
        }
    }
    
    func lineNumeFormatChecker(lineNum: Int) -> Bool{
        if lineNum <= 6 && lineNum >= 0 {
            return true
        }
        return false
    }
    
    func importPlayersFormatChecker(fileName: URL) -> Bool{
        
        var firstFileContentsParsed: [[String]] = [[String]]()
        var playerInfoMultiArray = [[String]]()
        
        do {
            firstFileContentsParsed =  (try String(contentsOf: fileName, encoding: .utf8)).components(separatedBy: "\n").map{ $0.components(separatedBy: ",") }
        } catch {
            print("Error Finding Contents of File")
            fatalErrorAlert("Error Attempting to Find Contents of File has failed. Please make sure you are importing a compatible file")
            
        }
        
         if firstFileContentsParsed[0].count == 4 {
            // copy contents of old array into newly formatted array
            for x in 1..<firstFileContentsParsed.count{
                if firstFileContentsParsed[x][0] != "" && firstFileContentsParsed[x][0] != "\r" && firstFileContentsParsed[x][0] != "\n"{
                   
                    playerInfoMultiArray.append(firstFileContentsParsed[x])
                 
                }
            }
     
            // start at second row ignore first one
            for x in 0..<playerInfoMultiArray.count{
                if playerInfoMultiArray[x].count == 4 {
                    // check to see if player name is filled in
                    if playerInfoMultiArray[x][0] == ""{
                         fatalErrorAlert("Player Name Error ocuured attempting to parse the player file imported, please refer to the CSV file format on coachassistant.ca")
                        return false
                        
                    }else{
                        
                        // append player name if format right
                        playerNamesFromCSV.append(playerInfoMultiArray[x][0])
                        // check to see if the player name has a jersey number
                        if playerInfoMultiArray[x][1] == "" && canCast().clastToInt(valueToCast: playerInfoMultiArray[x][1]) == false {
                            fatalErrorAlert("Jersey Number Error ocuured attempting to parse the player file imported, please refer to the CSV file format on coachassistant.ca")
                            return false
                        }else{
                       
                            // append jersey number if format right
                            playerJerseyNumFromCSV.append(Int(playerInfoMultiArray[x][1])!)
                        
                            // check to see if the player name has a line number
                            if playerInfoMultiArray[x][2] == "" && canCast().clastToInt(valueToCast: playerInfoMultiArray[x][2]) == false{
                                fatalErrorAlert("Line Number Error ocuured attempting to parse the player file imported, please refer to the CSV file format on coachassistant.ca")
                                return false
                            }else{
                                if lineNumeFormatChecker(lineNum: Int(playerInfoMultiArray[x][2])!) == true{
                                    // append line number if format right
                                    playerLineNumFromCSV.append(Int(playerInfoMultiArray[x][2])!)
                                    // check to see if the player name has a line type
                                    if playerInfoMultiArray[x][3] == "" && lineTypeFormatChecker(lineType: playerInfoMultiArray[x][3]) == false{
                                        fatalErrorAlert("Line Type Error ocuured attempting to parse the player file imported, please refer to the CSV file format on coachassistant.ca")
                                        return false
                                    }else{
                                        // append line type if format right
                                        playerLineTypeFromCSV.append((playerInfoMultiArray[x][3]).trimmingCharacters(in: .whitespacesAndNewlines))
                                        
                                    }
                                }else{
                                    fatalErrorAlert("Line Number Error ocuured attempting to parse the player file imported, please refer to the CSV file format on coachassistant.ca")
                                    return false
                                }
                               
                            }
                        }
                    }
                }else{
                    fatalErrorAlert("ERROR, Attempting to parse the player file imported, please refer to the CSV file format on coachassistant.ca")
                    return false
                }
            }
            return true
        }else{
            fatalErrorAlert("ERROR, Attempting to parse the player file imported, please refer to the CSV file format on coachassistant.ca")
            return false
        }
    }

    
    // convert csv files to string then convert [[string]] to team table in realm
    func csvStringToRealmTeamTable(fileName: URL) -> Bool{

        var firstFileContentsParsed: [[String]] = [[String]]()
        var teamInfoMultiArray = [[String]]()
        // get contents of specfic csv file and place into array above
        do {
            firstFileContentsParsed =  (try String(contentsOf: fileName, encoding: .utf8)).components(separatedBy: "\n").map{ $0.components(separatedBy: ",") }
        } catch {
            print("Error Finding Containts of File")
            fatalErrorAlert("ERROR, attempting to find contents of file has failed. Please make sure you are importing a compatible file")
        }
    
        var rowIndexCount: Int = 0
        
        // copy contents of old array into newly formatted array
        for x in 1..<firstFileContentsParsed.count{
            
            if firstFileContentsParsed[x].indices.contains(0) {
                if firstFileContentsParsed[x][0] != "" && firstFileContentsParsed[x][0] != "\r" && firstFileContentsParsed[x][0] != "\n"{
                
                    // check to see if 2d row is already created
                    if !teamInfoMultiArray.indices.contains(rowIndexCount){
                        teamInfoMultiArray.append(["", ""])
                    }
                   
                    // add team name to array
                    teamInfoMultiArray[rowIndexCount][0] = (firstFileContentsParsed[x][0])
                    
                }
            }
            if firstFileContentsParsed[x].indices.contains(1) {
                if firstFileContentsParsed[x][1] != "" && firstFileContentsParsed[x][1] != "\r" && firstFileContentsParsed[x][1] != "\n"{
                
                    // check to see if 2d row is already created
                    if !teamInfoMultiArray.indices.contains(rowIndexCount){
                        teamInfoMultiArray.append(["", ""])
                    }
                    // add team name to array
                    teamInfoMultiArray[rowIndexCount][1] = (firstFileContentsParsed[x][1])
                }
            }
            rowIndexCount = rowIndexCount + 1
        }
        
            for x in 0..<teamInfoMultiArray.count{
                if (teamInfoMultiArray[x].count == 2){
                    if teamInfoMultiArray[x][0] == ""{
                        print("Error Finding Containts of File team name")
                        fatalErrorAlert("Team Name ERROR ocuured attempting to parse the player file imported, please refer to the CSV file format on coachassistant.ca")
                        return false
                    }else{
                        teamNameFromCSV.append(teamInfoMultiArray[x][0])
                        if teamInfoMultiArray[x][1] != "" {
                            let value = (teamInfoMultiArray[x][1]).trimmingCharacters(in: .whitespacesAndNewlines)
                            if canCast().clastToInt(valueToCast: value) == true && Int(value)! >= 1990 {
                                teamSeasonYearFromCSV.append(Int(value)!)
                            }else{
                                teamSeasonYearFromCSV.append(getDate().getYear())
                            }
                
                        }else{
                            teamSeasonYearFromCSV.append(getDate().getYear())
                        }
                    }
                }else{
                    fatalErrorAlert("ERROR, Attempting to parse the team file imported, please refer to the CSV file format on coachassistant.ca")
                    return false
                    
                }
            }

            return true
    }

    
    func zipGameSaves(fileURL: [URL]){
        do {
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                
                let tempUrl = dir.appendingPathComponent("GameSaves")
                let fileURLSaveLocation = tempUrl.appendingPathComponent("gameSavesBackup.zip")
                
                try Zip.zipFiles(paths: fileURL, zipFilePath: fileURLSaveLocation, password: nil, progress: { (progress) -> () in
                    print(progress)
                }) //Zip
            }
        }catch{
            print("Failed to Zip Files")
        }
        
    }
    
    func decompressZipGameSaves(){
        do {
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                
                let tempUrl = dir.appendingPathComponent("GameSaves")
                let fileURL = tempUrl.appendingPathComponent("gameSavesBackup.zip")
                try Zip.quickUnzipFile(fileURL, progress: { (progress) in
                    print(progress)
                    
                })
            }
        }catch{
            print("Unable to unzip gamesaves file")
                
        }
        
    }
    
    func localBackupWriter() -> URL{
        var filesToShare = [Any]()
        var finalZipRestingPlace: URL!
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let realmFileSearch = dir.appendingPathComponent("default.realm")
            
            if FileManager.default.fileExists(atPath: realmFileSearch.path) {
                
                let tempUrl = dir.appendingPathComponent("Backups")
                finalZipRestingPlace = tempUrl.appendingPathComponent("coachAssistantBackup.zip")
                do {
                    try Zip.zipFiles(paths: [realmFileSearch], zipFilePath: finalZipRestingPlace, password: nil, progress: { (progress) -> () in
                        print(progress)
                        if progress == 1.0{
                            // Make the activityViewContoller which shows the share-view
                            // Add the path of the file to the Array
                            filesToShare.append(finalZipRestingPlace!)
                            
                            let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
                            activityViewController.excludedActivityTypes = [UIActivity.ActivityType.print, UIActivity.ActivityType.assignToContact]
                            // Show the share-view
                            activityViewController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                                if completed {
                                    let date = "\(getDate().getYear()).\(getDate().getMonth()).\(getDate().getDay())"
                                    
                                    UserDefaults.standard.set(date, forKey: "lastBackup")
                                    self.backupUpDateCheck()
                                }
                                // User completed activity
                            }
                            
                            self.present(activityViewController, animated: true, completion: nil)
                            if let popOver = activityViewController.popoverPresentationController {
                                popOver.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
                                popOver.sourceView = self.backupTableView
                                
                            }
                            
                        }
                    })
                    
                }catch{
                    print("Failed to Zip Files")
                    self.fatalErrorAlert("Failed to Zip Files")
                }
                
            }else{
                print("cant find realm file")
            }
        }
        return finalZipRestingPlace
    }
    
    func iCloudDocumentReader(){
        
        if let icloudFolderURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents"),
            let urls = try? FileManager.default.contentsOfDirectory(at: icloudFolderURL, includingPropertiesForKeys: nil, options: []) {
            unZipBackup(documentURL: urls.first!)
        }else{
            fatalErrorAlert("Failed to locate documents in iCloud container, please make sure you have a backup in iCloud before proceeding.")
        }
    }
    
    func moveFileToLocal(){
         if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let realmDefaultPath = dir.appendingPathComponent("Backups").appendingPathComponent("default.realm")
            if FileManager.default.fileExists(atPath: realmDefaultPath.path){
                do {
                    try FileManager.default.copyItem(at: realmDefaultPath, to: dir)
                    let date = "\(getDate().getYear()).\(getDate().getMonth()).\(getDate().getDay())"
                    
                    UserDefaults.standard.set(date, forKey: "lastBackup")
                    self.backupUpDateCheck()
                }
                catch {
                    //Error handling
                    print("Error in coping item from local directory to icloud container")
                    fatalErrorAlert("Error Copying file from temp directory to workling directory. Operation aborted, please try again before contacting support")
                }
            }else{
                fatalErrorAlert("Error Copying file from temp directory to workling directory. Operation aborted, please try again before contacting support")
            }
        }
    }
    
    func iCloudDocumentWriter(fileURL: URL){
        
        var isDir:ObjCBool = false
        
        guard let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents").appendingPathComponent("coachAssistantBackup") else { return }
        
        if FileManager.default.fileExists(atPath: fileURL.path, isDirectory: &isDir) {
            do {
                try FileManager.default.removeItem(at: fileURL)
            }
            catch {
                //Error handling
                print("Error in removing item from icloud container")
                fatalErrorAlert("Error in removing old file from iCloud container, please contact support")
            }
        }
        
        do {
            try FileManager.default.copyItem(at: fileURL, to: iCloudDocumentsURL)
            let date = "\(getDate().getYear()).\(getDate().getMonth()).\(getDate().getDay())"
            
            UserDefaults.standard.set(date, forKey: "lastBackup")
            self.backupUpDateCheck()
        }
        catch {
            //Error handling
            print("Error in coping item from local directory to icloud container")
            fatalErrorAlert("Error in coping item from local directory to icloud container, please contact support")
        }
        
    }
    
    func unZipBackup(documentURL: URL){
        
       if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let destinationURL = dir.appendingPathComponent("Backups")
        
            try! Zip.unzipFile(documentURL, destination: destinationURL, overwrite: true, password: nil, progress: { (progress) in
                print(progress)
                if progress == 1.0{
                    let realmDefaultPath = destinationURL.appendingPathComponent("default.realm")
                    if FileManager.default.fileExists(atPath: realmDefaultPath.path){

                        print("path ext is: \(realmDefaultPath.pathExtension)")
                        if realmDefaultPath.pathExtension != "realm"{
                            self.fatalErrorAlert("File failed inspection test. Make sure the file being imported is of type 'default.realm'. Import aborted")
                            do{
                                try FileManager.default.removeItem(at: realmDefaultPath)
                            }catch let error as NSError{
                                print(error)
                            }
                        }else{
                            self.reloadAppAlert()
                            
                        }
                       
                    }else{
                        self.fatalErrorAlert("Failed to remove current working database file. Please make sure pp is not configuting any teams or players in the background. Import aborted, contact support if problem persists")
                    }
                }
            }, fileOutputHandler: { (result) in
                if !result.isFileURL == true{
                    print("Unable to locate unzipped file, Whoops!")
                }
            })
        }
    }
    
    func showUIDocumentController(){
        
        let importMenu = UIDocumentPickerViewController(documentTypes: [String(kUTTypeCommaSeparatedText), String(kUTTypeZipArchive)], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
    }
    
   
    
    // -------------------------------------------------------- swifty store kit stuffss ------------------------------------------------------
    func productRetrieve(){
        
        SwiftyStoreKit.retrieveProductsInfo([productID]) { result in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                print("Product: \(product.localizedDescription), price: \(priceString)")
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
            }
            else {
                print("Error: \(String(describing: result.error))")
                self.purchaseErrorAlert(alertMsg: "An upgrade cannot be found an unknown error occured. Please contact support.")
            }
        }
    }
    
    func productPurchase(){
        
        SwiftyStoreKit.purchaseProduct(productID, quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                UserDefaults.standard.set(true, forKey: "userPurchaseConf")
                self.reloadAppAlert()
                
            case .error(let error):
                switch error.code {
                case .unknown:
                    print("Unknown error. Please contact support")
                    self.purchaseErrorAlert(alertMsg: "Unknown error. Please contact support")
                case .clientInvalid:
                    print("Not allowed to make the payment")
                case .paymentCancelled:
                    break
                case .paymentInvalid:
                    print("The purchase identifier was invalid")
                case .paymentNotAllowed:
                    print("The device is not allowed to make the payment")
                    self.purchaseErrorAlert(alertMsg: "The device is not allowed to make the payment")
                case .storeProductNotAvailable:
                    print("The product is not available in the current storefront")
                    self.purchaseErrorAlert(alertMsg: "The product is not available in the current storefront")
                case .cloudServicePermissionDenied:
                    print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed:
                    print("Could not connect to the network")
                    self.purchaseErrorAlert(alertMsg: "Could not connect to the network, please make sure your are connected to the internet")
                case .cloudServiceRevoked:
                    print("User has revoked permission to use this cloud service")
                    self.purchaseErrorAlert(alertMsg: "Please update your account premisions or call Apple for furthur assitance regarding your cloud premissions")
                default:
                    print((error as NSError).localizedDescription)
                }
            }
        }
        
    }
    // ---------------------------------------------- popup viewcontroller stuffssssss --------------------------
    // popup default team selection view
    func popupPlayerAssignmentVC(){
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let popupVC = storyboard.instantiateViewController(withIdentifier: "Settings_Assign_Players_View_Controller") as! Settings_Assign_Players_View_Controller
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = .crossDissolve
        
        popupVC.playerNameArray = playerNamesFromCSV
        popupVC.playerJerseyNumArray = playerJerseyNumFromCSV
        popupVC.playerLineNumArray = playerLineNumFromCSV
        popupVC.playerLineTypeArray = playerLineTypeFromCSV
        
        let pVC = popupVC.popoverPresentationController
        pVC?.permittedArrowDirections = .any
        pVC?.delegate = self
        
        present(popupVC, animated: true, completion: nil)
        print("popupPlayerAssignmentVC is presentd")
        
        print(playerJerseyNumFromCSV)
    }
    // -------------------------------------------------------------------------------------------------------
    
    // --------------------------------------------------------------------------------------------------------------------------------
    // ----------------------------------------------- popup alerts -------------------------------------------------------------------
    
    func confirmationLocalAlert(){
        
        // create confirmation alert to save to local storage
        let exportAlert = UIAlertController(title: localizedString().localized(value:"Confirmation Alert"), message: localizedString().localized(value:"Are you sure you would like to export all App Data to your Local Storage?"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        exportAlert.addAction(UIAlertAction(title: localizedString().localized(value:"Cancel"), style: UIAlertAction.Style.default, handler: nil))
        exportAlert.addAction(UIAlertAction(title: localizedString().localized(value:"Continue"), style: UIAlertAction.Style.default, handler: { action in
            
           
            
            self.localBackupWriter()
     
            
        }))
        // show the alert
        self.present(exportAlert, animated: true, completion: nil)
        
    }
    
    func confirmationiCloudAlert(){
        
        // create confirmation alert to save to icloiud storage
        let exportAlert = UIAlertController(title: localizedString().localized(value:"Confirmation Alert"), message: localizedString().localized(value:"Are you sure you would like to export all App Data to your iCloud Account?"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        exportAlert.addAction(UIAlertAction(title: localizedString().localized(value:"Cancel"), style: UIAlertAction.Style.default, handler: nil))
        exportAlert.addAction(UIAlertAction(title: localizedString().localized(value:"Continue"), style: UIAlertAction.Style.default, handler: { action in
            
         
            
            self.iCloudDocumentWriter(fileURL: self.localBackupWriter())
            
        }))
        // show the alert
        self.present(exportAlert, animated: true, completion: nil)
        
    }
    
    func purchaseErrorAlert(alertMsg: String){
        // create the alert
        let alreadyProAlert = UIAlertController(title: "Whoops!", message: alertMsg, preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        alreadyProAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(alreadyProAlert, animated: true, completion: nil)
    }
    
    func importAlert(message: String){
        
        // create the alert
        let importAlert = UIAlertController(title: localizedString().localized(value: message), message: "", preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        importAlert.addAction(UIAlertAction(title: localizedString().localized(value: "OK"), style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(importAlert, animated: true, completion: nil)
    }
    
    
    // display prompt before excuting realm deletion
    func deleteDataPrompt(){
        let realm = try! Realm()
        // create the alert
        let dataDelete = UIAlertController(title: localizedString().localized(value: "App Data Deletion"), message: localizedString().localized(value: "Would you like to wipe all data stored locally on this device?"), preferredStyle: UIAlertController.Style.alert)
        dataDelete.addAction(UIAlertAction(title: localizedString().localized(value: "Cancel"), style: UIAlertAction.Style.cancel, handler: nil))
        // add an action (button)
        dataDelete.addAction(UIAlertAction(title: localizedString().localized(value: "Yes"), style: UIAlertAction.Style.destructive, handler: {action in
            try? realm.write ({
                //delete contents of DB
                realm.deleteAll()
            })
            UserDefaults.standard.removeObject(forKey: "defaultHomeTeamID")
        }))
        
        // show the alert
        self.present(dataDelete, animated: true, completion: nil)
        
    }
    // display success alert if export succesful
    func successLocalAlert(){
        
        // create the alert
        let sucessfulExportAlert = UIAlertController(title: localizedString().localized(value: "Succesful Export"), message: localizedString().localized(value: "All App Data was Succesfully Exported Locally"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        sucessfulExportAlert.addAction(UIAlertAction(title: localizedString().localized(value: "Cancel"), style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(sucessfulExportAlert, animated: true, completion: nil)
        
    }
    
    // upgrade alert used to display the use cases for upgrading to pro
    func upgradeNowAlert(){
     
        // create the alert
        let notPro = UIAlertController(title: localizedString().localized(value: "You're Missing Out!"), message: localizedString().localized(value: "Upgrade now and unlock the ability to backup your teams stats to the Cloud! Coach Assistant Pro memebers get iCloud backup and import access across all devices with PRO!"), preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        notPro.addAction(UIAlertAction(title: localizedString().localized(value:"No Thanks"), style: UIAlertAction.Style.default, handler: nil))
        // add an action (button)
        notPro.addAction(UIAlertAction(title: localizedString().localized(value:"Upgrade Now!"), style: UIAlertAction.Style.destructive, handler: { action in
            self.productRetrieve()
            self.productPurchase()
        }))
        // show the alert
        self.present(notPro, animated: true, completion: nil)
        
        
    }
    
    func missingIcloudCredsAlert(){
        
        // create the alert
        let sucessfulExportAlert = UIAlertController(title: localizedString().localized(value:"iCloud Error"), message: localizedString().localized(value:"In order to backup to iCloud you must first be logged into and or have access to an iCloud account"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        sucessfulExportAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(sucessfulExportAlert, animated: true, completion: nil)
    }
    
    func icloudOnAlert(){
        // create the alert
        let icloudOnALert = UIAlertController(title: localizedString().localized(value:"iCloud Backup On"), message: localizedString().localized(value:"Backups and Imports will now be made in conjuntion with iCloud, to export / import locally on this device please toggle off 'Backup to iCloud'"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        icloudOnALert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(icloudOnALert, animated: true, completion: nil)
        
    }
    
    func reloadAppAlert(){
        
        // create the alert
        let reloadAppAlert = UIAlertController(title: localizedString().localized(value: "App Restart Needed!"), message: localizedString().localized(value:"Please reload app for chnages to take full effect."), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        reloadAppAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            self.reloadView()
        }))
        
        // show the alert
        self.present(reloadAppAlert, animated: true, completion: nil)
    }
    
    func fatalErrorAlert(_ msg: String){
        
        let errorAlert = UIAlertController(title: localizedString().localized(value:"Whoops!"), message: localizedString().localized(value:"\(msg)"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(errorAlert, animated: true, completion: nil)
        
    }
    
    func importPlayersTeamTypeAlert(){
        
        let errorAlert = UIAlertController(title: localizedString().localized(value:"Import File Type"), message: localizedString().localized(value: "Would you like to Import Players or Teams"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        errorAlert.addAction(UIAlertAction(title: "Import Players", style: UIAlertAction.Style.default, handler: { action in
            self.importPlayersBool = 0
            self.showUIDocumentController()
        }))
        // add an action (button)
        errorAlert.addAction(UIAlertAction(title: "Import Teams", style: UIAlertAction.Style.default, handler: { action in
            self.importPlayersBool = 1
            self.showUIDocumentController()
        }))
        // add an action (button)
        errorAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        // show the alert
        self.present(errorAlert, animated: true, completion: nil)
        
    }
    
    
    // -------------------------------------------------------------------------------------------------------------------------------------
    
    // ----------------------------------------------- tableview stuffssss -------------------------------------------------------------
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        switch indexPath.section {
        case 1:
            switch indexPath.row{
            case 0:
                if (icloudToggleSwitch.isOn == true){
                    confirmationiCloudAlert()
                    
                }else{
                    confirmationLocalAlert()
                }
                break

            default:
                print("FATAL CELL SELECTION ERROR")
                break
            }
        case 2:
            switch indexPath.row{
            case 0:
                if (icloudToggleSwitch.isOn == true){
                    iCloudDocumentReader()
                    moveFileToLocal()
                }else{
                    self.importPlayersBool = 2
                    self.showUIDocumentController()
                }
                
                break
            case 1:
                importPlayersTeamTypeAlert()
                
                break
            default:
                print("FATAL CELL SELECTION ERROR")
                break
            }
        case 3:
            print("Asking User to delete app data")
            deleteDataPrompt()
            break
        default:
            print("FATAL CELL SELECTION ERROR")
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------
    // -------------------------------------------------------- segeu stuffsss ----------------------------------------------------------------
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check is appropriate segue is being used
        if (segue.identifier == "importPopUpSegue"){
            // set var vc as destination segue
            let vc = segue.destination as! Import_Pop_Up_View
            if (icloudToggleSwitch.isOn == true){
                vc.importFromIcloudBool = true
            }else{
                vc.importFromIcloudBool = false
            }
            
        }
    }
    
}
// --------------------------------------------------------------------------------------------------------------------------------
extension Settings_Backup_View_Controller: UIDocumentPickerDelegate,UINavigationControllerDelegate{
    
    func genRealmPrimaryID() -> Int{
        
        let realm = try! Realm()
        
        if (realm.objects(teamInfoTable.self).max(ofProperty: "teamID") as Int? != nil){
            return (realm.objects(teamInfoTable.self).max(ofProperty: "teamID") as Int? ?? 0) + 1;
        }else{
            return (realm.objects(teamInfoTable.self).max(ofProperty: "teamID") as Int? ?? 0);
            
        }
    }
    
    func documentPicker(_ documentPicker: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        switch importPlayersBool{
        case 0:
            if  urls.count > 1 {
                fatalErrorAlert("No more than one file can be selected please select a player CSV file.")
            }else {
                // passed multi file selection checker
                
                // check to see if player csv file format is correct
                if importPlayersFormatChecker(fileName: urls.first!) == true{
                    popupPlayerAssignmentVC()
                    importPlayersBool = nil
                }
                
                return
                
            }
            break
        case 1:
            if  urls.count > 1 {
                fatalErrorAlert("No more than one file can be selected please select a team CSV file.")
            }else {
                // passed multi file selection checker
                if csvStringToRealmTeamTable(fileName: urls.first!) == true{
                    
                    let realm = try! Realm()
                    
                    print(teamNameFromCSV)
                    
                    for x in 0..<teamNameFromCSV.count{
                        let newTeam = teamInfoTable()
                        newTeam.teamID = genRealmPrimaryID()
                        
                        try! realm.write{
                            newTeam.nameOfTeam = teamNameFromCSV[x]
                            newTeam.seasonYear = teamSeasonYearFromCSV[x]
                            newTeam.activeState = true
                            realm.add(newTeam, update: true)
                        }
                    }
                    importAlert(message: "All Teams Imported Suyccessfully!")
                    importPlayersBool = nil
                }
                
                return
                
            }
            break
        case 2:
            if  urls.count > 1 {
                fatalErrorAlert("Please import your 'coachAssistantBackup.zip file. THe file selected does not meet this criteria.'")
            }else {
                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    
                    let realmFileSearch = dir.appendingPathComponent("default.realm")
                    
                    if FileManager.default.fileExists(atPath: realmFileSearch.path) {
                        do{
                            try FileManager.default.removeItem(at: realmFileSearch)
                            unZipBackup(documentURL: urls.first!)
                            moveFileToLocal()
                        }catch let error as NSError{
                            print(error)
                        }
                    }
                }
                
                return
            }
            break
        default:
            fatalErrorAlert("Unable to determine course of action based on file imported. Please try again.")
            break
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
    
}
