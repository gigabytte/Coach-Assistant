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
import StoreKit
import MobileCoreServices
import Zip

final class Settings_Backup_View_Controller: UITableViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver, UIPopoverPresentationControllerDelegate{
    
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
    
    var realmFileURLArray: [URL] = [URL]()
    
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
        SKPaymentQueue.default().add(self)
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
    
    
    func deleteAllProfilePics(){
        let playerImagesDir =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!).appendingPathComponent("PlayerImages")
        let teamLogosDir =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!).appendingPathComponent("TeamLogo")
        
        do {
            let player_fileURLs = try FileManager.default.contentsOfDirectory(at: playerImagesDir,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            let team_fileURLs = try FileManager.default.contentsOfDirectory(at: teamLogosDir,
                                                                              includingPropertiesForKeys: nil,
                                                                              options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            let allURLS = player_fileURLs + team_fileURLs
            
            for fileURL in allURLS {
                
                try FileManager.default.removeItem(at: fileURL)
                
            }
        
        } catch  {
            print(error)
            fatalErrorAlert("Unable to delete all profile and or team logos from App Directory. Please try again.")
            
        }
    }
    
    func zipProfileImages(){
        
         if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let playerImagesDir =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!).appendingPathComponent("PlayerImages")
            let teamLogosDir =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!).appendingPathComponent("TeamLogo")
        
            do {
                let player_fileURLs = try FileManager.default.contentsOfDirectory(at: playerImagesDir,
                                                                                  includingPropertiesForKeys: nil,
                                                                                  options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
                let team_fileURLs = try FileManager.default.contentsOfDirectory(at: teamLogosDir,
                                                                                includingPropertiesForKeys: nil,
                                                                                options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
                let backupURL = dir.appendingPathComponent("Backups")

                try Zip.zipFiles(paths: player_fileURLs, zipFilePath: backupURL.appendingPathComponent("PlayerImageBackup.zip"), password: nil, progress: { (progress) in
                    if progress == 1.0{
                        
                    }
                })
                try Zip.zipFiles(paths: team_fileURLs, zipFilePath: backupURL.appendingPathComponent("TeamImageBackup.zip"), password: nil, progress: { (progress) in
                    if progress == 1.0{
                        
                    }
                })
                
            } catch  {
                print(error)
                fatalErrorAlert("Unable to collect profile image for either teams and or players, please contact support.")
            }
        }
    }
    
    func localBackupWriter(showActivity: Bool) -> (URL, Bool){
        var filesToShare = [Any]()
        var finalZipRestingPlace: URL!
        
        var isDir:ObjCBool = false

        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            
            let realmFileSearch = dir.appendingPathComponent("default.realm")
            if FileManager.default.fileExists(atPath: realmFileSearch.path, isDirectory: &isDir){
    
                let playerImagesDir =  dir.appendingPathComponent("PlayerImages")
                let teamLogosDir =  dir.appendingPathComponent("TeamLogo")
                // check to see if player dir is blank if so write tiny txt file to it
                if let playerImages_numberOfFiles = (try? FileManager.default.contentsOfDirectory(atPath: playerImagesDir.path))?.count {
                    if playerImages_numberOfFiles == 0{
                        let text = "blank"
                        try? text.write(to: playerImagesDir.appendingPathComponent("default.txt"), atomically: false, encoding: .utf8)
                        
                    }
                }
                // check to see if team dir is blank if so write tiny txt file to it
                if let playerImages_numberOfFiles = (try? FileManager.default.contentsOfDirectory(atPath: teamLogosDir.path))?.count {
                    if playerImages_numberOfFiles == 0{
                        let text = "blank"
                        try? text.write(to: teamLogosDir.appendingPathComponent("default.txt"), atomically: false, encoding: .utf8)
                        
                    }
                }
                
                    let tempUrl = dir.appendingPathComponent("Backups")
                    finalZipRestingPlace = tempUrl.appendingPathComponent("coachAssistantBackup.zip")
    

                    do {
                        try Zip.zipFiles(paths: Array([playerImagesDir, teamLogosDir, realmFileSearch]), zipFilePath: finalZipRestingPlace, password: nil, progress: { (progress) -> () in
                            print(progress)
                            if progress == 1.0{
                                
                                // check to see if player dir contains place holder txt file
                                if FileManager.default.fileExists(atPath: playerImagesDir.appendingPathComponent("default.txt").path, isDirectory: &isDir) {
                                   
                                    try? FileManager.default.removeItem(at: playerImagesDir.appendingPathComponent("default.txt"))
                                    
                                }
                                
                                // check to see if team dir contains place holder txt file
                                if FileManager.default.fileExists(atPath: teamLogosDir.appendingPathComponent("default.txt").path, isDirectory: &isDir) {
                                    try? FileManager.default.removeItem(at: teamLogosDir.appendingPathComponent("default.txt"))
                                    
                                }
                                
                                // Make the activityViewContoller which shows the share-view
                                // Add the path of the file to the Array
                                if showActivity == true {
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
                                    // present UIactivtyController aka share document popup
                                    self.present(activityViewController, animated: true, completion: nil)
                                    if let popOver = activityViewController.popoverPresentationController {
                                        popOver.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
                                        popOver.sourceView = self.backupTableView
                                        
                                    }
                                }
                                
                            }
                        })
                        
                    }catch{
                        print("Failed to Zip Files")
                        fatalErrorAlert("Failed to Zip Files")
                    }
                    
                   
                 return (finalZipRestingPlace, true)
            }else{
                print("cant find realm file")
                fatalErrorAlert("Cannot locate databse file, backup aborted, please contact support.")
                return (URL(string: "")!, false)
            }
           
        }else{
             return (URL(string: "")!, false)
        }
    
    }

    
    func iCloudDocumentReader(){
        
        var urlConvert = NSURL()
        
        if let urls = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents").appendingPathComponent("coachAssistantBackup.zip"){
            urlConvert = urls as NSURL
            if urlConvert.absoluteString != "" {
                print(urlConvert)
                unZipBackup(documentURL: urls)
            }else{
                fatalErrorAlert("Failed to locate documents in iCloud container, please make sure you have a backup in iCloud before proceeding.")
            }
        }else{
            fatalErrorAlert("Failed to locate documents in iCloud container, please make sure you have a backup in iCloud before proceeding.")
        }
    }
    
    
    func moveFileToLocal(){
        
        var isDir:ObjCBool = false
        
         if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let path = dir.appendingPathComponent("Backups")//.appendingPathComponent("default.realm")
            let realmDefaultPath = path.appendingPathComponent("default.realm")
            
            let backup_playerImagesDir = path.appendingPathComponent("PlayerImages")
            let backup_teamImagesDir = path.appendingPathComponent("TeamLogo")
            
            let playerImagesDir = dir.appendingPathComponent("PlayerImages")
            let teamImagesDir = dir.appendingPathComponent("TeamLogo")
            
            if FileManager.default.fileExists(atPath: realmDefaultPath.path, isDirectory: &isDir) {
                // check to see if player dir contains place holder txt file
                if FileManager.default.fileExists(atPath: backup_playerImagesDir.appendingPathComponent("default.txt").path, isDirectory: &isDir) {
                    
                    try? FileManager.default.removeItem(at: backup_playerImagesDir.appendingPathComponent("default.txt"))
                    
                }
                
                // check to see if team dir contains place holder txt file
                if FileManager.default.fileExists(atPath: backup_teamImagesDir.appendingPathComponent("default.txt").path, isDirectory: &isDir) {
                    try? FileManager.default.removeItem(at: backup_teamImagesDir.appendingPathComponent("default.txt"))
                    
                }
                   
                do {
                    // replace realm.default with backup
             
                    try FileManager.default.replaceItemAt(dir.appendingPathComponent("default.realm"), withItemAt: realmDefaultPath)
                    
                    do{
                        //let playerImagesBckupDIR = playerImagesDir
                        try FileManager.default.replaceItemAt(playerImagesDir, withItemAt: backup_playerImagesDir)
                        
                        
                            do{
                              //  let teamImagesBckupDIR = teamImagesDir
                                try FileManager.default.replaceItemAt(teamImagesDir, withItemAt: backup_teamImagesDir)
                                
                                self.importAlert(message: "Successfully Import Backup of Backup. Restart app in inorder for changes to take full effect")
                            }catch{
                                print(error)
                                fatalErrorAlert("Error attempting to replace player team logo file from backup to home directory. If you had no team logo's backed up previously please ignore this error. If this is not the case please contact support")
                                //cannot copy player images backup to home dir
                            }
                        
                    }catch{
                        fatalErrorAlert("Error attempting to replace player profile images file from backup to home directory. If you had no player profiles backed up previously please ignore this error. If this is not the case please contact support")
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
    
    func iCloudDocumentWriter(fileURL: URL){
        
        var isDir:ObjCBool = false
        
        guard let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents").appendingPathComponent("coachAssistantBackup.zip") else { return }
        
        if FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: &isDir) {
            do {
                try FileManager.default.removeItem(at: iCloudDocumentsURL)
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
            successiCLoudBackupAlert()
            self.deleteAllTempFiles()
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
            if FileManager.default.fileExists(atPath: destinationURL.path){
                do {
                    try Zip.unzipFile(documentURL, destination: destinationURL, overwrite: true, password: nil, progress: { (progress) in
                    print(progress)
                    if progress == 1.0{
                        self.moveFileToLocal()
                    }
                })
                }catch{
                    print("\(error)")
                    fatalErrorAlert("Unable to locate iCloud backup, please try again. If problem persists please contact support.")
                }
            }
       }else{
        print("cannot find backups dir")
        }
    }
    
    func showUIDocumentController(isPickingBackup: Bool){
        
        var types: String = ""
        
        if isPickingBackup == true{
            types = (kUTTypeZipArchive as String)
        }else{
            types = (kUTTypeCommaSeparatedText as String)
        }
        
        let importMenu = UIDocumentPickerViewController(documentTypes: [types], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
    }
    
   
    
    // MARK: - SKProductRequest Delegate
    
    func buyProduct(product: SKProduct) {
        print("Sending the Payment Request to Apple");
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment);
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        print(response.products)
        let count : Int = response.products.count
        if (count>0) {
            
            let validProduct: SKProduct = response.products[0] as SKProduct
            if (validProduct.productIdentifier == self.productID! as String) {
                print(validProduct.localizedTitle)
                print(validProduct.localizedDescription)
                print(validProduct.price)
                self.buyProduct(product: validProduct)
            } else {
                print(validProduct.productIdentifier)
            }
        } else {
            fatalErrorAlert("Could not locate products, please contact support")
            print("nothing")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction{
                
                
                switch trans.transactionState {
                case .purchased:
                    print("Product Purchased")
                    //Do unlocking etc stuff here in case of new purchase
                    UserDefaults.standard.set(true, forKey: "userPurchaseConf")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    self.view.viewWithTag(100)?.removeFromSuperview()
                    self.view.viewWithTag(200)?.removeFromSuperview()
                    break;
                case .failed:
                    print("Purchased Failed");
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    self.view.viewWithTag(100)?.removeFromSuperview()
                    self.view.viewWithTag(200)?.removeFromSuperview()
                    fatalErrorAlert("Failed to request product from Apple, please contact support")
                    break;
                case .restored:
                    print("Already Purchased")
                    UserDefaults.standard.set(true, forKey: "userPurchaseConf")
                    self.view.viewWithTag(100)?.removeFromSuperview()
                    self.view.viewWithTag(200)?.removeFromSuperview()
                    restoreConfAlert()
                    //Do unlocking etc stuff here in case of restor
                    
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                default:
                    
                    break;
                }
            }
        }
    }
    
    
    //If an error occurs, the code will go to this function
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        // Show some alert
        print("Fata storkit error: \(error)")
        fatalErrorAlert("Failed to restore product from Apple, please contact support")
    }
    // -------------------- convert realm to csv --------------------------------
    // creats csv file for  team info table
    func createCSVTeamInfo(){
        let realm = try! Realm()
        
        
        let TeamIDCount =  realm.objects(teamInfoTable.self).filter("teamID >= 0").count
        var tempTeamNameArray: [String] = [String]()
        var tempSeasonYearArray: [String] = [String]()
        var tempLogoURLArray: [String] = [String]()
        var tempActiveStateArray: [String] = [String]()
        // print(TeamIDCount)
        for i in 0..<TeamIDCount{
            
            let teamNameValue = realm.object(ofType: teamInfoTable.self, forPrimaryKey:i)!.nameOfTeam;
            let seasonYearValue = realm.object(ofType: teamInfoTable.self, forPrimaryKey:i)!.seasonYear;
            let urlValue = realm.object(ofType: teamInfoTable.self, forPrimaryKey:i)!.teamLogoURL;
            let activeStateValue = realm.object(ofType: teamInfoTable.self, forPrimaryKey:i)!.activeState;
            tempTeamNameArray.append(teamNameValue)
            tempSeasonYearArray.append(String(seasonYearValue))
            tempLogoURLArray.append(String(urlValue))
            tempActiveStateArray.append(String(activeStateValue))
        }
        
        let fileName = "Realm_Team_Info_Table" + ".csv"
        var csvText = "nameOfTeam,seasonYear,teamLogoURL,activeState\n"
        for x in 0..<tempTeamNameArray.count {
            
            let teamNameVar = tempTeamNameArray[x]
            let seaonYearVar = tempSeasonYearArray[x]
            let logoURLVar = tempLogoURLArray[x]
            let activeStateVar = tempActiveStateArray[x]
            
            let newLine = teamNameVar + "," + seaonYearVar + "," + logoURLVar + ", " + activeStateVar + "\n"
            csvText.append(newLine)
        }
        
        writeToDisk(csvFileString: csvText, FileName: fileName)
        
    }
    // creats csv file for player info table
    func createCSVPlayerInfo(){
        
        let realm = try! Realm()
        
        let playerIDCount =  realm.objects(playerInfoTable.self).filter("playerID >= 0").count
        var tempPlayerNameArray: [String] = [String]()
        var tempjerseyNum: [String] = [String]()
        var tempPositionType: [String] = [String]()
        var tempTeamID: [String] = [String]()
        var tempLineNum: [String] = [String]()
        var tempGoalCount: [String] = [String]()
        var tempAssitsCount: [String] = [String]()
        var tempShotCount: [String] = [String]()
        var tempPlusMinus: [String] = [String]()
        var tempLogoURL: [String] = [String]()
        var tempActiveState: [String] = [String]()
        
        for i in 0..<playerIDCount{
            
            let playerNameValue = realm.object(ofType: playerInfoTable.self, forPrimaryKey:i)!.playerName;
            let jerseyNum = realm.object(ofType: playerInfoTable.self, forPrimaryKey:i)!.jerseyNum;
            let positionType = realm.object(ofType: playerInfoTable.self, forPrimaryKey:i)!.positionType;
            let TeamID = realm.object(ofType: playerInfoTable.self, forPrimaryKey:i)!.TeamID;
            let lineNum = realm.object(ofType: playerInfoTable.self, forPrimaryKey:i)!.lineNum;
            let goalCount = realm.object(ofType: playerInfoTable.self, forPrimaryKey:i)!.goalCount;
            let assitsCount = realm.object(ofType: playerInfoTable.self, forPrimaryKey:i)!.assitsCount;
            let shotCount = realm.object(ofType: playerInfoTable.self, forPrimaryKey:i)!.shotCount;
            let plusMinus = realm.object(ofType: playerInfoTable.self, forPrimaryKey:i)!.plusMinus;
            let logoURL = realm.object(ofType: playerInfoTable.self, forPrimaryKey:i)!.playerLogoURL;
            let activeState = realm.object(ofType: playerInfoTable.self, forPrimaryKey:i)!.activeState;
            tempPlayerNameArray.append(playerNameValue)
            tempjerseyNum.append(String(jerseyNum))
            tempPositionType.append(positionType)
            tempTeamID.append(TeamID)
            tempLineNum.append(String(lineNum))
            tempGoalCount.append(String(goalCount))
            tempAssitsCount.append(String(assitsCount))
            tempShotCount.append(String(shotCount))
            tempPlusMinus.append(String(plusMinus))
            tempLogoURL.append(String(logoURL))
            tempActiveState.append(String(activeState))
            
        }
        
        let fileName = "Realm_Player_Info_Table" + ".csv"
        var csvText = "playerName,jerseyNum,positionType,TeamID,lineNum,goalCount,assitsCount,shotCount,plusMinus,playerLogoURL,activeState\n"
        for x in 0..<tempPlayerNameArray.count {
            
            let playerNameVar = tempPlayerNameArray[x]
            let playerJerseyNum = tempjerseyNum[x]
            let playerPositionTypeVar = tempPositionType[x]
            let playerTeamIDVar = tempTeamID[x]
            let playerLineNumVar = tempLineNum[x]
            let playerGoalCountVar = tempGoalCount[x]
            let playerAssitsCountVar = tempAssitsCount[x]
            let playerShotCountVar = tempShotCount[x]
            let playerPlusMinusVar = tempPlusMinus[x]
            let logoURLVar = tempLogoURL[x]
            let playerActiveStateVar = tempActiveState[x]
            
            let newLine =  playerNameVar + "," + playerJerseyNum + "," + playerPositionTypeVar + "," + playerTeamIDVar + "," + playerLineNumVar + "," + playerGoalCountVar + "," + playerAssitsCountVar + "," + playerShotCountVar + "," + playerPlusMinusVar + "," + logoURLVar + "," + playerActiveStateVar + "\n"
            csvText.append(newLine)
        }
        writeToDisk(csvFileString: csvText, FileName: fileName)
    }
    // creats csv file for new game table
    func createCSVNewGameInfo(){
        
        let realm = try! Realm()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        
        let newGameIDCount =  realm.objects(newGameTable.self).filter("gameID >= 0").count
        var tempDateGamePlayed: [String] = [String]()
        var tempOpposingTeamID: [String] = [String]()
        var tempHomeTeamID: [String] = [String]()
        var tempGameType: [String] = [String]()
        var tempLocation: [String] = [String]()
        var tempWiningTeam: [String] = [String]()
        var tempLosingTeam: [String] = [String]()
        var tempSeasonYear: [String] = [String]()
        var tempTieBool: [String] = [String]()
        var tempActiveGameStatus: [String] = [String]()
        var tempActiveState: [String] = [String]()
        var tempdrawBoardURLS: [String] = [String]()
        
        for i in 0..<newGameIDCount{
            
            let dateGamePlayedValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.dateGamePlayed
            let opposingTeamIDValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.opposingTeamID
            let homeTeamIDValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.homeTeamID
            let gameTypeValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.gameType
            let locationValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.gameLocation
            let winingTeamValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.winingTeamID
            let losingTeamValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.losingTeamID
            let seasonYearValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.seasonYear
            let tieBoolValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.tieGameBool
            let activeGameStatusValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.activeGameStatus
            let activeStateValue = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.activeState
            let drawBoardURls = realm.object(ofType: newGameTable.self, forPrimaryKey:i)!.drawboardURL
            let dateString = formatter.string(from: dateGamePlayedValue!)
            tempDateGamePlayed.append(dateString)
            tempOpposingTeamID.append(String(opposingTeamIDValue))
            tempHomeTeamID.append(String(homeTeamIDValue))
            tempGameType.append(gameTypeValue)
            tempLocation.append(locationValue)
            tempWiningTeam.append(String(winingTeamValue))
            tempLosingTeam.append(String(losingTeamValue))
            tempSeasonYear.append(String(seasonYearValue))
            tempTieBool.append(String(tieBoolValue))
            tempActiveGameStatus.append(String(activeGameStatusValue))
            tempActiveState.append(String(activeStateValue))
            tempdrawBoardURLS.append(String(drawBoardURls.joined(separator: ",")))
            
        }
        
        let fileName = "Realm_New_Game_Info_Table" + ".csv"
        var csvText = "dateGamePlayed,opposingTeamID,homeTeamID,gameType,gameLocation,winingTeamID,losingTeamID,seasonYear,tieBool,activeGameStatus,activeState,drawboardURL\n"
        for x in 0..<newGameIDCount {
            
            let dateGamePlayerVar = tempDateGamePlayed[x]
            let opposingTeamIDVar = tempOpposingTeamID[x]
            let homeTeamIDVar = tempHomeTeamID[x]
            let gameTypeVar = tempGameType[x]
            let locationVar = tempLocation[x]
            let winingTeamVar = tempWiningTeam[x]
            let losingTeamVar = tempLosingTeam[x]
            let seasonYearVar = tempSeasonYear[x]
            let tieBoolVar = tempTieBool[x]
            let activeGameStatusVar = tempActiveGameStatus[x]
            let activeStateVar = tempActiveState[x]
            let urlVar = tempdrawBoardURLS[x]
            
            let newLine =  dateGamePlayerVar + "," + opposingTeamIDVar + "," + homeTeamIDVar + "," + gameTypeVar + "," + locationVar + "," + winingTeamVar + "," + losingTeamVar + "," + seasonYearVar + "," + tieBoolVar + "," + activeGameStatusVar + "," + activeStateVar + "," + urlVar + "\n"
            
            csvText.append(newLine)
        }
        writeToDisk(csvFileString: csvText, FileName: fileName)
        
    }
    // creats csv file for goal marker table
    func createCSVGoalMarkerTable(){
        
        let realm = try! Realm()
        
        let goalMarkerIDCount =  realm.objects(goalMarkersTable.self).filter("cordSetID >= 0").count
        var tempgameID: [String] = [String]()
        var tempgoalType: [String] = [String]()
        var temppowerPlay: [String] = [String]()
        var temppowerPlayID: [String] = [String]()
        var tempTeamID: [String] = [String]()
        var tempgoalieID: [String] = [String]()
        var tempgoalPlayerID: [String] = [String]()
        var tempassitantPlayerID: [String] = [String]()
        var tempsec_assitantPlayerID: [String] = [String]()
        var tempperiodNumSet: [String] = [String]()
        var tempxCordGoal: [String] = [String]()
        var tempyCordGoal: [String] = [String]()
        var tempshotLocation: [String] = [String]()
        var tempactiveState: [String] = [String]()
        
        
        for i in 0..<goalMarkerIDCount{
            
            let gameID = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.gameID
            let goalType = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.goalType
            let powerPlay = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.powerPlay
            let powerPlayID = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.powerPlayID
            let TeamID = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.TeamID
            let goalieID = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.goalieID
            let goalPlayerID = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.goalPlayerID
            let assitantPlayerID = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.assitantPlayerID
            let sec_assitantPlayerID = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.sec_assitantPlayerID
            let periodNumSet = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.periodNum
            let xCordGoal = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.xCordGoal
            let yCordGoal = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.yCordGoal
            let shotLocation = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.shotLocation
            let activeState = realm.object(ofType: goalMarkersTable.self, forPrimaryKey:i)!.activeState
            tempgameID.append(String(gameID))
            tempgoalType.append(goalType)
            temppowerPlay.append(String(powerPlay))
            temppowerPlayID.append(String(powerPlayID))
            tempTeamID.append(String(TeamID))
            tempgoalieID.append(String(goalieID))
            tempgoalPlayerID.append(String(goalPlayerID))
            tempassitantPlayerID.append(String(assitantPlayerID))
            tempsec_assitantPlayerID.append(String(sec_assitantPlayerID))
            tempperiodNumSet.append(String(periodNumSet))
            tempxCordGoal.append(String(xCordGoal))
            tempyCordGoal.append(String(yCordGoal))
            tempshotLocation.append(String(shotLocation))
            tempactiveState.append(String(activeState))
            
        }
        
        let fileName = "Realm_Goal_Marker_Table" + ".csv"
        var csvText = "gameID,goalType,powerPlay,powerPlayID,TeamID,goalieID,goalPlayerID,assitantPlayerID,sec_assitantPlayerID,periodNumSet,xCordGoal,yCordGoal,shotLocation,activeState\n"
        for x in 0..<goalMarkerIDCount{
            
            let gameIDVar = tempgameID[x]
            let goalTypeVar = tempgoalType[x]
            let powerPlayVar = temppowerPlay[x]
            let powerPlayIDVar = temppowerPlayID[x]
            let teamIDVar = tempTeamID[x]
            let goalieIDVar = tempgoalieID[x]
            let goalPlayerIDVar = tempgoalPlayerID[x]
            let assitIDVar = tempassitantPlayerID[x]
            let sec_assitIDVar = tempsec_assitantPlayerID[x]
            let periodNumVar = tempperiodNumSet[x]
            let xCordVar = tempxCordGoal[x]
            let yCordVar = tempyCordGoal[x]
            let shotLocationVar = tempshotLocation[x]
            let activeStateVar = tempactiveState[x]
            
            let newLine =  gameIDVar + "," + goalTypeVar + "," + powerPlayVar + "," + powerPlayIDVar + "," + teamIDVar + "," + goalieIDVar + "," + goalPlayerIDVar + "," + assitIDVar + "," + sec_assitIDVar +
                "," + periodNumVar + "," + xCordVar + "," + yCordVar + "," + shotLocationVar + "," + activeStateVar + "\n"
            
            csvText.append(newLine)
        }
        
        writeToDisk(csvFileString: csvText, FileName: fileName)
    }
    // creats csv file for shot marker table
    func createCSVShotMarkerTable(){
        
        let realm = try! Realm()
        
        let shotMarkerIDCount =  realm.objects(shotMarkerTable.self).filter("cordSetID >= 0").count
        var tempgameID: [String] = [String]()
        var tempTeamID: [String] = [String]()
        var tempgoalieID: [String] = [String]()
        var tempperiodNumSet: [String] = [String]()
        var tempxCordGoal: [String] = [String]()
        var tempyCordGoal: [String] = [String]()
        var tempshotLocation: [String] = [String]()
        var tempactiveState: [String] = [String]()
        
        
        for i in 0..<shotMarkerIDCount{
            
            let gameID = realm.object(ofType: shotMarkerTable.self, forPrimaryKey:i)!.gameID
            let TeamID = realm.object(ofType: shotMarkerTable.self, forPrimaryKey:i)!.TeamID
            let goalieID = realm.object(ofType: shotMarkerTable.self, forPrimaryKey:i)!.goalieID
            let periodNumSet = realm.object(ofType: shotMarkerTable.self, forPrimaryKey:i)!.periodNum
            let xCordGoal = realm.object(ofType: shotMarkerTable.self, forPrimaryKey:i)!.xCordShot
            let yCordGoal = realm.object(ofType: shotMarkerTable.self, forPrimaryKey:i)!.yCordShot
            let shotLocation = realm.object(ofType: shotMarkerTable.self, forPrimaryKey:i)!.shotLocation
            let activeState = realm.object(ofType: shotMarkerTable.self, forPrimaryKey:i)!.activeState
            tempgameID.append(String(gameID))
            tempTeamID.append(String(TeamID))
            tempgoalieID.append(String(goalieID))
            tempperiodNumSet.append(String(periodNumSet))
            tempxCordGoal.append(String(xCordGoal))
            tempyCordGoal.append(String(yCordGoal))
            tempshotLocation.append(String(shotLocation))
            tempactiveState.append(String(activeState))
            
        }
        
        let fileName = "Realm_Shot_Marker_Table" + ".csv"
        var csvText = "gameID,TeamID,goalieID,periodNumSet,xCordGoal,yCordGoal,shotLocation,activeState\n"
        for x in 0..<shotMarkerIDCount{
            
            let gameIDVar = tempgameID[x]
            let teamIDVar = tempTeamID[x]
            let goalieIDVar = tempgoalieID[x]
            let periodNumVar = tempperiodNumSet[x]
            let xCordVar = tempxCordGoal[x]
            let yCordVar = tempyCordGoal[x]
            let shotLocationVar = tempshotLocation[x]
            let activeStateVar = tempactiveState[x]
            
            let newLine =  gameIDVar + "," + teamIDVar + "," + goalieIDVar + "," + periodNumVar + "," + xCordVar + "," + yCordVar + "," + shotLocationVar + "," + activeStateVar + "\n"
            
            csvText.append(newLine)
        }
        
        writeToDisk(csvFileString: csvText, FileName: fileName)
    }
    
    // creats csv file for penalty table
    func createCSVPenaltyTable(){
        
        let realm = try! Realm()
        
        let shotMarkerIDCount =  realm.objects(penaltyTable.self).filter("penaltyID >= 0").count
        var tempGameID: [String] = [String]()
        var temptTeamID: [String] = [String]()
        var tempPlayerID: [String] = [String]()
        var tempPenaltyType: [String] = [String]()
        var tempTimeOfOffense: [String] = [String]()
        var tempxCord: [String] = [String]()
        var tempyCord: [String] = [String]()
        var tempactiveState: [String] = [String]()
        
        
        for i in 0..<shotMarkerIDCount{
            
            let gameID = realm.object(ofType: penaltyTable.self, forPrimaryKey:i)!.gameID
            let teamID = realm.object(ofType: penaltyTable.self, forPrimaryKey:i)!.teamID
            let playerID = realm.object(ofType: penaltyTable.self, forPrimaryKey:i)!.playerID
            let penaltyType = realm.object(ofType: penaltyTable.self, forPrimaryKey:i)!.penaltyType
            let timeOfOffense = realm.object(ofType: penaltyTable.self, forPrimaryKey:i)!.timeOfOffense
            let xCord = realm.object(ofType: penaltyTable.self, forPrimaryKey:i)!.xCord
            let yCord = realm.object(ofType: penaltyTable.self, forPrimaryKey:i)!.yCord
            let activeState = realm.object(ofType: penaltyTable.self, forPrimaryKey:i)!.activeState
            tempGameID.append(String(gameID))
            temptTeamID.append(String(teamID))
            tempPlayerID.append(String(playerID))
            tempPenaltyType.append(String(penaltyType))
            tempTimeOfOffense.append(dateToString.dateToStringFormatter(unformattedDate: timeOfOffense!))
            tempxCord.append(String(xCord))
            tempyCord.append(String(yCord))
            tempactiveState.append(String(activeState))
            
        }
        
        let fileName = "Realm_Penalty_Table" + ".csv"
        var csvText = "gameID,teamID,playerID,penaltyType,timeOfOffense,xCord,yCord,activeState\n"
        for x in 0..<shotMarkerIDCount{
            
            let gameIDVar = tempGameID[x]
            let teamIDVar = tempPlayerID[x]
            let playerIDVar = tempPlayerID[x]
            let penaltyTypeVar = tempPenaltyType[x]
            let timeOfOffenseVar = tempTimeOfOffense[x]
            let xCordVar = tempxCord[x]
            let yCordVar = tempyCord[x]
            let activeStateVar = tempactiveState[x]
            
            let newLine =  gameIDVar + "," + teamIDVar + "," + playerIDVar + "," + penaltyTypeVar + "," + timeOfOffenseVar + "," + xCordVar + "," + yCordVar + "," + activeStateVar + "\n"
            
            csvText.append(newLine)
        }
        writeToDisk(csvFileString: csvText, FileName: fileName)
    }
    
    
    // creats csv file for Overall stats table
    func createCSVOverallStatsTable(){
        
        let realm = try! Realm()
        
        let overallIDCount =  realm.objects(overallStatsTable.self).filter("overallStatsID >= 0").count
        var tempGameID: [String] = [String]()
        var tempPlayerID: [String] = [String]()
        var tempLineNum: [String] = [String]()
        var tempGoalCount: [String] = [String]()
        var tempAssistCount: [String] = [String]()
        var tempPlusMinus: [String] = [String]()
        var tempactiveState: [String] = [String]()
        
        
        for i in 0..<overallIDCount{
            
            let gameID = realm.object(ofType: overallStatsTable.self, forPrimaryKey:i)!.gameID
            let playerID = realm.object(ofType: overallStatsTable.self, forPrimaryKey:i)!.playerID
            let lineNum = realm.object(ofType: overallStatsTable.self, forPrimaryKey:i)!.lineNum
            let goalCount = realm.object(ofType: overallStatsTable.self, forPrimaryKey:i)!.goalCount
            let assistCount = realm.object(ofType: overallStatsTable.self, forPrimaryKey:i)!.assistCount
            let plusMinus = realm.object(ofType: overallStatsTable.self, forPrimaryKey:i)!.plusMinus
            let activeState = realm.object(ofType: overallStatsTable.self, forPrimaryKey:i)!.activeState
            tempGameID.append(String(gameID))
            tempPlayerID.append(String(playerID))
            tempLineNum.append(String(lineNum))
            tempGoalCount.append(String(goalCount))
            tempAssistCount.append(String(assistCount))
            tempPlusMinus.append(String(plusMinus))
            tempactiveState.append(String(activeState))
            
        }
        
        let fileName = "Realm_Overall_Stats_Table" + ".csv"
        var csvText = "gameID,playerID,lineNum,goalCount,assistCount,plusMinus,activeState\n"
        for x in 0..<overallIDCount{
            
            let gameIDVar = tempGameID[x]
            let playerIDVar = tempPlayerID[x]
            let lineNumVar = tempLineNum[x]
            let goalCountVar = tempGoalCount[x]
            let assistCountVar = tempAssistCount[x]
            let plusMinusVar = tempPlusMinus[x]
            let activeStateVar = tempactiveState[x]
            
            let newLine =  gameIDVar + "," + playerIDVar + "," + lineNumVar + "," + goalCountVar + "," + assistCountVar + "," + plusMinusVar + "," + activeStateVar + "\n"
            
            csvText.append(newLine)
        }
        writeToDisk(csvFileString: csvText, FileName: fileName)
    }
    
    // creats csv file for Overall stats table
    func createCSVFaceoffStatsTable(){
        
        let realm = try! Realm()
        
        let overallIDCount =  realm.objects(faceOffInfoTable.self).filter("faceoffID >= 0").count
        var tempGameID: [String] = [String]()
        var tempWiningPlayerID: [String] = [String]()
        var tempLoosingPlayerID: [String] = [String]()
        var tempPeriodNum: [String] = [String]()
        var tempFaceoffLocationCode: [String] = [String]()
        var tempactiveState: [String] = [String]()
        
        
        for i in 0..<overallIDCount{
            
            let gameID = realm.object(ofType: faceOffInfoTable.self, forPrimaryKey:i)!.gameID
            let winingPlayerID = realm.object(ofType: faceOffInfoTable.self, forPrimaryKey:i)!.winingPlayerID
            let losingPlayerID = realm.object(ofType: faceOffInfoTable.self, forPrimaryKey:i)!.losingPlayerID
            let periodNum = realm.object(ofType: faceOffInfoTable.self, forPrimaryKey:i)!.periodNum
            let faceoffLocationCode = realm.object(ofType: faceOffInfoTable.self, forPrimaryKey:i)!.faceoffLocationCode
            let activeState = realm.object(ofType: faceOffInfoTable.self, forPrimaryKey:i)!.activeState
            tempGameID.append(String(gameID))
            tempWiningPlayerID.append(String(winingPlayerID))
            tempLoosingPlayerID.append(String(losingPlayerID))
            tempPeriodNum.append(String(periodNum))
            tempFaceoffLocationCode.append(String(faceoffLocationCode))
            tempactiveState.append(String(activeState))
            
        }
        
        let fileName = "Realm_Faceoff_Stats_Table" + ".csv"
        var csvText = "gameID,winingPlayerID,losingPlayerID,periodNum,faceoffLocationCode,activeState\n"
        for x in 0..<overallIDCount{
            
            let gameIDVar = tempGameID[x]
            let winingPlayerIDVar = tempWiningPlayerID[x]
            let losingPlayerIDVar = tempLoosingPlayerID[x]
            let periodNumVar = tempPeriodNum[x]
            let faceoffLocationCodeVar = tempFaceoffLocationCode[x]
            let activeStateVar = tempactiveState[x]
            
            let newLine =  gameIDVar + "," + winingPlayerIDVar + "," + losingPlayerIDVar + "," + periodNumVar + "," + faceoffLocationCodeVar + "," + activeStateVar + "\n"
            
            csvText.append(newLine)
        }
        writeToDisk(csvFileString: csvText, FileName: fileName)
    }
    // --------------------------------------------------------------------------
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
    
    func writeToDisk(csvFileString: String, FileName: String) {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let tempUrl = dir.appendingPathComponent("Backups")
            let fileURLSaveLocation = tempUrl.appendingPathComponent(FileName)
            
            do {
                try csvFileString.write(to: fileURLSaveLocation, atomically: false, encoding: .utf8)
                realmFileURLArray.append(fileURLSaveLocation)
            } catch {
                fatalErrorAlert("Unable to convert \(FileName) to CSV file, please try again. Contact support is problem persits")
                print("\(error)")
  
            }
        }
    }
    
    func writeZipRealmFiles(){
        ///// check the completion of all these fnctions and abort if needed
        self.createCSVTeamInfo()
        self.createCSVPlayerInfo()
        self.createCSVNewGameInfo()
        self.createCSVPenaltyTable()
        self.createCSVGoalMarkerTable()
        self.createCSVShotMarkerTable()
        self.createCSVFaceoffStatsTable()
        self.createCSVOverallStatsTable()
        // zip realm csv files
        do {
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                
                let tempUrl = dir.appendingPathComponent("Backups")
                let fileURLSaveLocation = tempUrl.appendingPathComponent("coachAssistantDatabaseExport.zip")
                
                
                try Zip.zipFiles(paths: realmFileURLArray, zipFilePath: fileURLSaveLocation, password: nil, progress: { (progress) -> () in
                    print(progress)
                    if progress == 1.0{
                        self.deleteRealmTempFiles()
                        // show activity controller
                        let activityViewController = UIActivityViewController(activityItems: [fileURLSaveLocation], applicationActivities: nil)
                        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.print, UIActivity.ActivityType.assignToContact]
                        // Show the share-view
                        activityViewController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                            if completed == true || completed == false{
                                do{
                                    try FileManager.default.removeItem(at: fileURLSaveLocation)
                                }catch{
                                    print("Attempting to remove old zip file failed \(error)")
                                }
                                self.realmFileURLArray.removeAll()
                            }
                            
                            // User completed activity
                        }
                        
                        // present UIactivtyController aka share document popup
                        self.present(activityViewController, animated: true, completion: nil)
                        if let popOver = activityViewController.popoverPresentationController {
                            popOver.permittedArrowDirections = UIPopoverArrowDirection(rawValue:0)
                            popOver.sourceView = self.backupTableView
                            
                        }
                    }
                }) //Zip
            }
        }catch{
            print("Failed to Zip Files")
        }
        deleteDataPrompt()
        
    }
    
    func deleteRealmTempFiles(){
        print(realmFileURLArray)
        
        for url in realmFileURLArray{
           
            do {
                try FileManager.default.removeItem(at: url)
                
            } catch {
                
                print("print cvant remove")
                
            }
        }
   
    }
    // -------------------------------------------------------------------------------------------------------
    
    // --------------------------------------------------------------------------------------------------------------------------------
    // ----------------------------------------------- popup alerts -------------------------------------------------------------------
    func restoreConfAlert(){
        // create the alert
        let alreadyProAlert = UIAlertController(title: localizedString().localized(value:"Already a Pro!"), message: localizedString().localized(value:"We have restored your Coach Assistant: Ice Hockey 'Pro' Membership, thank you again for your previous purchase :)"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        alreadyProAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(alreadyProAlert, animated: true, completion: nil)
        
    }
    
    func confirmationLocalAlert(){
        
        // create confirmation alert to save to local storage
        let exportAlert = UIAlertController(title: localizedString().localized(value:"Confirmation Alert"), message: localizedString().localized(value:"Are you sure you would like to export all App Data to your Local Storage?"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        exportAlert.addAction(UIAlertAction(title: localizedString().localized(value:"Cancel"), style: UIAlertAction.Style.default, handler: nil))
        exportAlert.addAction(UIAlertAction(title: localizedString().localized(value:"Continue"), style: UIAlertAction.Style.default, handler: { action in
            
           
            self.zipProfileImages()
            self.localBackupWriter(showActivity: true)
     
            
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
            
         
            let localBackupResult = self.localBackupWriter(showActivity: false)
            if localBackupResult.1 == true{
                self.iCloudDocumentWriter(fileURL: localBackupResult.0)
            }
            
            
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
            //remove defauklt home team user default
            UserDefaults.standard.removeObject(forKey: "defaultHomeTeamID")
            //delete all profile images
            self.deleteAllProfilePics()
            
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
    
    // display success alert if export succesful
    func successiCLoudBackupAlert(){
        
        // create the alert
        let sucessfulExportAlert = UIAlertController(title: localizedString().localized(value: "Succesful Export"), message: localizedString().localized(value: "All App Data was Succesfully Backed up to iCloud"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        sucessfulExportAlert.addAction(UIAlertAction(title: localizedString().localized(value: "OK"), style: UIAlertAction.Style.default, handler: nil))
        
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
            if (SKPaymentQueue.canMakePayments()) {
                let productID:NSSet = NSSet(array: [self.productID! as NSString]);
                let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>);
                productsRequest.delegate = self;
                productsRequest.start();
                print("Fetching Products");
            } else {
                print("can't make purchases");
                self.fatalErrorAlert("Failed to make purchase, please make sure you can make purchases in the App Store before continuing. If problem persits please contact support")
                self.view.viewWithTag(100)?.removeFromSuperview()
                self.view.viewWithTag(200)?.removeFromSuperview()
            }
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
            self.showUIDocumentController(isPickingBackup: false)
        }))
        // add an action (button)
        errorAlert.addAction(UIAlertAction(title: "Import Teams", style: UIAlertAction.Style.default, handler: { action in
            self.importPlayersBool = 1
            self.showUIDocumentController(isPickingBackup: false)
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
        case 0:
            break
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
                fatalErrorAlert("Failure to indentify selection. Error code 111")
                print("FATAL CELL SELECTION ERROR")
                break
            }
        case 2:
            switch indexPath.row{
            case 0:
                if (icloudToggleSwitch.isOn == true){
                    iCloudDocumentReader()
                    deleteAllTempFiles()
                    //remove defauklt home team user default
                    UserDefaults.standard.removeObject(forKey: "defaultHomeTeamID")
                }else{
                    self.importPlayersBool = 2
                    self.showUIDocumentController(isPickingBackup: true)
                    deleteAllTempFiles()
                    //remove defauklt home team user default
                    UserDefaults.standard.removeObject(forKey: "defaultHomeTeamID")
                }
                
                break
            case 1:
                importPlayersTeamTypeAlert()
                
                break
            default:
                fatalErrorAlert("Failure to indentify selection. Error code 111")
                print("FATAL CELL SELECTION ERROR")
                break
            }
        case 3:
            print("Exporting all Realm Tables as CSV to zip file")
            writeZipRealmFiles()
            break
        case 4:
            deleteDataPrompt()
            break
        default:
            print("FATAL CELL SELECTION ERROR")
            fatalErrorAlert("Failure to indentify selection. Error code 111")
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------
}
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
                            realm.add(newTeam, update: .modified)
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
                unZipBackup(documentURL: urls.first!)
                
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
