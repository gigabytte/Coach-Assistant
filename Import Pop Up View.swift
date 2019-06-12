//
//  Import Pop Up View.swift
//
//
//  Created by Greg Brooks on 2019-03-05.
//

import UIKit
import Realm
import RealmSwift

class Import_Pop_Up_View: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let realm = try! Realm()
    
    @IBOutlet weak var popUpTitle: UILabel!
    @IBOutlet weak var Popupview: UIView!
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noFilesFoundLabel: UILabel!
    
    var fileNamesArray: [String] = [String]()
    var selectedFileNamesArray: [String] = [String]()
    var limit: String = "7"
    var setupPhaseBool: Bool!
    var importFromIcloudBool: Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Import from icloud bool \(importFromIcloudBool)")
        
        importFromSetup()
        // add blur effect to view along with popUpView
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.addSubview(Popupview)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Apply radius to Popupview
        Popupview.layer.cornerRadius = 10
        Popupview.layer.masksToBounds = true
        
        if (fileCollection().isEmpty == true){
            print("NO items present to Import")
            noFilesFoundLabel.isHidden = false
            importButton.alpha = 0.5
            importButton.isUserInteractionEnabled = false
            
        }else{
            print("Items Available to Import")
            noFilesFoundLabel.isHidden = true
            importButton.alpha = 1.0
            importButton.isUserInteractionEnabled = true
            
        }
        
    }
    
    func importFromSetup(){
        /* sets button requirments based on if user as accessed this view from
         the setup process */
        if (setupPhaseBool == true){
            print("Segue from setup")
            importButton.setTitle("Import and Finish Setup", for: .normal)
            cancelButton.setTitle("Back to Setup", for: .normal)
        }
        
    }
    
    // get all files in file app that start with Realm_ and place in array
    func fileCollection() -> [String]{
        
        if (importFromIcloudBool == false){
            let fileManager = FileManager.default
            let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
            let documentsPath = documentsUrl.path
            
            do {
                if let documentPath = documentsPath
                {
                    let fileNames = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
                    let csvFileNames = fileNames.filter{$0.contains("Realm_")}
                    for fileName in csvFileNames {
                        
                        if (fileName.hasSuffix(".csv"))
                        {
                            fileNamesArray.append(fileName)
                        }
                    }
                }
                
            } catch {
                print("Could not find documents: \(error)")
            }
            return(fileNamesArray)
        }else{
            // Browse your icloud container to find the file you want
            if let icloudFolderURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents"),
                let urls = try? FileManager.default.contentsOfDirectory(at: icloudFolderURL, includingPropertiesForKeys: nil, options: []) {
                
                for x in 0..<urls.count{
                    // Here select the file url you are interested in (for the exemple we take the first)
                    let myURL = urls[x]
                    // We have our url
                    var lastPathComponent = myURL.lastPathComponent
                    if lastPathComponent.contains("Realm_") {
                        // Delete the "." which is at the beginning of the file name
                        //lastPathComponent.removeFirst()
                        let folderPath = myURL.deletingLastPathComponent().path
                        let downloadedFilePath = lastPathComponent.replacingOccurrences(of: ".icloud", with: "")
                        fileNamesArray.append(lastPathComponent)
                        
                    }
                    
                }
                
            }
            print("icloud \(fileNamesArray)")
            return(fileNamesArray)
        }
    }
    
    func documentURLProducer() -> URL{
        if (importFromIcloudBool == false){
            print("Parsing Local")
            let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            return(documentsUrl)
        }else{
            let documentsUrl = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
            return(documentsUrl!)
        }
    }
    
    // converts string to date format, retuns date format
    func stringToDateFormatter(stringDate: String) -> Date{
        // string to date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let date = dateFormatter.date(from: stringDate)
        return(date!)
    }
    
    // convert csv files to string then convert [[string]] to new game table in realm
    func csvStringToRealmNewGameTable() -> Bool{
        // get document path based on search for spefic file
        let documentsUrl = documentURLProducer()
        let firstDocumentPath = documentsUrl.appendingPathComponent(fileCollection()[fileCollection().firstIndex(of: "Realm_New_Game_Info_Table.csv")!])
        print(firstDocumentPath)
        var firstFileContentsParsed: [[String]] = [[String]]()
        // get contents of specfic csv file and place into array above
        do {
            firstFileContentsParsed =  (try String(contentsOf: firstDocumentPath, encoding: .utf8)).components(separatedBy: "\n").map{ $0.components(separatedBy: ",") }
        } catch {
            print("Error Finding Contents of File")
        }
        
        if (firstFileContentsParsed[0].count == 11){
            try? realm.write ({
                //delete contents of table in realm DB
                realm.delete(realm.objects(newGameTable.self))
                print(realm.objects(newGameTable.self))
                for i in 1..<firstFileContentsParsed.count - 1{
                    if(firstFileContentsParsed[i].contains{$0 != ""}){
                        var primaryID: Int!
                        if (self.realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int? != nil){
                            primaryID = (self.realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int? ?? 0) + 1;
                        }else{
                            primaryID = (self.realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int? ?? 0);
                        }
                        self.realm.create(newGameTable.self, value: ["gameID": primaryID])
                        let primaryGameID = self.realm.object(ofType: newGameTable.self, forPrimaryKey: primaryID)
                        var count = 0
                        primaryGameID?.dateGamePlayed = stringToDateFormatter(stringDate: firstFileContentsParsed[i][count]); count += 1
                        primaryGameID?.opposingTeamID = Int(firstFileContentsParsed[i][count])!; count += 1
                        primaryGameID?.homeTeamID = Int(firstFileContentsParsed[i][count])!; count += 1
                        primaryGameID?.gameType = firstFileContentsParsed[i][count]; count += 1
                        primaryGameID?.gameLocation = firstFileContentsParsed[i][count]; count += 1
                        primaryGameID?.winingTeamID = Int(firstFileContentsParsed[i][count])!; count += 1
                        primaryGameID?.losingTeamID = Int(firstFileContentsParsed[i][count])!; count += 1
                        primaryGameID?.seasonYear = Int(firstFileContentsParsed[i][count])!; count += 1
                        if (Bool(firstFileContentsParsed[i][count]) != nil && Bool(firstFileContentsParsed[i][count])!){
                            primaryGameID?.tieGameBool = (Bool(firstFileContentsParsed[i][count]))!; count += 1
                        }else{
                            let set = CharacterSet(charactersIn: "truefalse")
                            primaryGameID?.tieGameBool = Bool((firstFileContentsParsed[i][count]).lowercased().components(separatedBy: set.inverted).joined())!; count += 1
                        }
                        if (Bool(firstFileContentsParsed[i][count]) != nil && Bool(firstFileContentsParsed[i][count])!){
                            primaryGameID?.activeGameStatus = (Bool(firstFileContentsParsed[i][count]))!; count += 1
                        }else{
                            let set = CharacterSet(charactersIn: "truefalse")
                            primaryGameID?.activeGameStatus = Bool((firstFileContentsParsed[i][count]).lowercased().components(separatedBy: set.inverted).joined())!; count += 1
                        }
                        if (Bool(firstFileContentsParsed[i][count]) != nil && Bool(firstFileContentsParsed[i][count])!){
                            primaryGameID?.activeState = (Bool(firstFileContentsParsed[i][count]))!; count += 1
                        }else{
                            let set = CharacterSet(charactersIn: "truefalse")
                            primaryGameID?.activeState = Bool((firstFileContentsParsed[i][count]).lowercased().components(separatedBy: set.inverted).joined())!; count += 1
                        }
                    }else{
                        acceptedIncorrectDataFormat(fileType: "New Game Table")
                        break
                    }
                }
            })
            print("New Game Success")
            return(true)
        }else{
            incorrectDataFormat(fileType: "New Game Table")
            return(false)
        }
    }
    
    // convert csv files to string then convert [[string]] to team table in realm
    func csvStringToRealmTeamTable() -> Bool{
        // get document path based on search for spefic file
        let documentsUrl = documentURLProducer()
        let sectDocumentPath = documentsUrl.appendingPathComponent(fileCollection()[fileCollection().firstIndex(of: "Realm_Team_Info_Table.csv")!])
        
        var secFileContentsParsed: [[String]] = [[String]]()
        // get contents of specfic csv file and place into array above
        do {
            secFileContentsParsed =  (try String(contentsOf: sectDocumentPath, encoding: .utf8)).components(separatedBy: "\n").map{ $0.components(separatedBy: ",") }
        } catch {
            print("Error Finding Containts of File")
        }
        
        if (secFileContentsParsed[1].count == 3){
            try? realm.write ({
                //delete contents of table in realm DB
                realm.delete(realm.objects(teamInfoTable.self))
                
                for i in 1..<secFileContentsParsed.count - 1{
                    if(secFileContentsParsed[i].contains{$0 != ""}){
                        var primaryID: Int!
                        if (self.realm.objects(teamInfoTable.self).max(ofProperty: "teamID") as Int? != nil){
                            primaryID = (self.realm.objects(teamInfoTable.self).max(ofProperty: "teamID") as Int? ?? 0) + 1;
                        }else{
                            primaryID = (self.realm.objects(teamInfoTable.self).max(ofProperty: "teamID") as Int? ?? 0);
                        }
                        self.realm.create(teamInfoTable.self, value: ["teamID": primaryID])
                        let primaryTeamID = self.realm.object(ofType: teamInfoTable.self, forPrimaryKey: primaryID)
                        var count = 0
                        primaryTeamID?.nameOfTeam = secFileContentsParsed[i][count]; count += 1
                        primaryTeamID?.seasonYear = Int(secFileContentsParsed[i][count])!; count += 1
                        if (Bool(secFileContentsParsed[i][count]) != nil && Bool(secFileContentsParsed[i][count])!){
                            primaryTeamID?.activeState = (Bool(secFileContentsParsed[i][count]))!; count += 1
                        }else{
                            let set = CharacterSet(charactersIn: "truefalse")
                            primaryTeamID?.activeState = Bool((secFileContentsParsed[i][count]).lowercased().components(separatedBy: set.inverted).joined())!; count += 1
                        }
                    }else{
                        incorrectDataFormat(fileType: "Team Info Table")
                        break
                    }
                }
            })
            print("Team Table Success")
            return(true)
        }else{
            incorrectDataFormat(fileType: "Team Info Table")
            return(false)
        }
    }
    
    // convert csv files to string then convert [[string]] to player info table in realm
    func csvStringToRealmPlayerTable() -> Bool{
        // get document path based on search for spefic file
        let documentsUrl = documentURLProducer()
        let thirdDocumentPath = documentsUrl.appendingPathComponent(fileCollection()[fileCollection().firstIndex(of: "Realm_Player_Info_Table.csv")!])
        
        var thirdFileContentsParsed: [[String]] = [[String]]()
        // get contents of specfic csv file and place into array above
        do {
            thirdFileContentsParsed =  (try String(contentsOf: thirdDocumentPath, encoding: .utf8)).components(separatedBy: "\n").map{ $0.components(separatedBy: ",") }
        } catch {
            print("Error Finding Containts of File")
        }
        
        if (thirdFileContentsParsed[0].count == 10){
            try? realm.write ({
                //delete contents of table in realm DB
                realm.delete(realm.objects(playerInfoTable.self))
                
                for i in 1..<thirdFileContentsParsed.count - 1{
                    if(thirdFileContentsParsed[i].contains{$0 != ""}){
                        var primaryID: Int!
                        if (self.realm.objects(playerInfoTable.self).max(ofProperty: "playerID") as Int? != nil){
                            primaryID = (self.realm.objects(playerInfoTable.self).max(ofProperty: "playerID") as Int? ?? 0) + 1;
                        }else{
                            primaryID = (self.realm.objects(playerInfoTable.self).max(ofProperty: "playerID") as Int? ?? 0);
                        }
                        self.realm.create(playerInfoTable.self, value: ["playerID": primaryID])
                        let primaryPlayerID = self.realm.object(ofType: playerInfoTable.self, forPrimaryKey: primaryID)
                        var count = 0
                        primaryPlayerID?.playerName = thirdFileContentsParsed[i][count]; count += 1
                        primaryPlayerID?.jerseyNum = Int(thirdFileContentsParsed[i][count])!; count += 1
                        primaryPlayerID?.positionType = thirdFileContentsParsed[i][count]; count += 1
                        primaryPlayerID?.TeamID = thirdFileContentsParsed[i][count]; count += 1
                        primaryPlayerID?.lineNum = Int(thirdFileContentsParsed[i][count])!; count += 1
                        primaryPlayerID?.goalCount = Int(thirdFileContentsParsed[i][count])!; count += 1
                        primaryPlayerID?.assitsCount = Int(thirdFileContentsParsed[i][count])!; count += 1
                        primaryPlayerID?.shotCount = Int(thirdFileContentsParsed[i][count])!; count += 1
                        primaryPlayerID?.plusMinus = Int(thirdFileContentsParsed[i][count])!; count += 1
                        if (Bool(thirdFileContentsParsed[i][count]) != nil && Bool(thirdFileContentsParsed[i][count])!){
                            primaryPlayerID?.activeState = (Bool(thirdFileContentsParsed[i][count]))!; count += 1
                        }else{
                            let set = CharacterSet(charactersIn: "truefalse")
                            primaryPlayerID?.activeState = Bool((thirdFileContentsParsed[i][count]).lowercased().components(separatedBy: set.inverted).joined())!; count += 1
                        }
                    }else{
                        incorrectDataFormat(fileType: "Player Info Table")
                        break
                    }
                }
            })
            print("Player Table Success")
            return(true)
        }else{
            incorrectDataFormat(fileType: "Player Info Table")
            return(false)
        }
    }
    
    // convert csv files to string then convert [[string]] to goal Marker table in realm
    func csvStringToRealmGoalMarkerTable() -> Bool{
        // get document path based on search for spefic file
        let documentsUrl = documentURLProducer()
        let fourthDocumentPath = documentsUrl.appendingPathComponent(fileCollection()[fileCollection().firstIndex(of: "Realm_Goal_Marker_Table.csv")!])
        
        var fourthFileContentsParsed: [[String]] = [[String]]()
        // get contents of specfic csv file and place into array above
        do {
            fourthFileContentsParsed =  (try String(contentsOf: fourthDocumentPath, encoding: .utf8)).components(separatedBy: "\n").map{ $0.components(separatedBy: ",") }
        } catch {
            print("Error Finding Containts of File")
        }
        
        if (fourthFileContentsParsed[0].count == 13){
            try? realm.write ({
                //delete contents of table in realm DB
                realm.delete(realm.objects(goalMarkersTable.self))
                
                for i in 1..<fourthFileContentsParsed.count - 1{
                    if(fourthFileContentsParsed[i].contains{$0 != ""}){
                        var primaryID: Int!
                        if (self.realm.objects(goalMarkersTable.self).max(ofProperty: "cordSetID") as Int? != nil){
                            primaryID = (self.realm.objects(goalMarkersTable.self).max(ofProperty: "cordSetID") as Int? ?? 0) + 1;
                        }else{
                            primaryID = (self.realm.objects(goalMarkersTable.self).max(ofProperty: "cordSetID") as Int? ?? 0);
                        }
                        self.realm.create(goalMarkersTable.self, value: ["cordSetID": primaryID])
                        let primaryMarkerID = self.realm.object(ofType: goalMarkersTable.self, forPrimaryKey: primaryID)
                        var count = 0
                        primaryMarkerID?.gameID = Int(fourthFileContentsParsed[i][count])!; count += 1
                        primaryMarkerID?.goalType = fourthFileContentsParsed[i][count]; count += 1
                        primaryMarkerID?.powerPlay = Bool(fourthFileContentsParsed[i][count])!; count += 1
                        primaryMarkerID?.TeamID = Int(fourthFileContentsParsed[i][count])!; count += 1
                        primaryMarkerID?.goalieID = Int(fourthFileContentsParsed[i][count])!; count += 1
                        primaryMarkerID?.goalPlayerID = Int(fourthFileContentsParsed[i][count])!; count += 1
                        primaryMarkerID?.assitantPlayerID = Int(fourthFileContentsParsed[i][count])!; count += 1
                        primaryMarkerID?.sec_assitantPlayerID = Int(fourthFileContentsParsed[i][count])!; count += 1
                        primaryMarkerID?.periodNum = Int(fourthFileContentsParsed[i][count])!; count += 1
                        primaryMarkerID?.xCordGoal = Int(fourthFileContentsParsed[i][count])!; count += 1
                        primaryMarkerID?.yCordGoal = Int(fourthFileContentsParsed[i][count])!; count += 1
                        primaryMarkerID?.shotLocation = Int(fourthFileContentsParsed[i][count])!; count += 1
                        if (Bool(fourthFileContentsParsed[i][count]) != nil && Bool(fourthFileContentsParsed[i][count])!){
                            primaryMarkerID?.activeState = (Bool(fourthFileContentsParsed[i][count]))!; count += 1
                        }else{
                            let set = CharacterSet(charactersIn: "truefalse")
                            primaryMarkerID?.activeState = Bool((fourthFileContentsParsed[i][count]).lowercased().components(separatedBy: set.inverted).joined())!; count += 1
                        }
                    }else{
                        acceptedIncorrectDataFormat(fileType: "Goal Marker Table")
                        break
                    }
                }
            })
            print("Goal Marker Table Success")
            return(true)
        }else{
            incorrectDataFormat(fileType: "Goal Marker Table")
            return(false)
        }
    }
    
    // convert csv files to string then convert [[string]] to shot Marker table in realm
    func csvStringToRealmShotlMarkerTable() -> Bool{
        // get document path based on search for spefic file
        let documentsUrl = documentURLProducer()
        let fifthDocumentPath = documentsUrl.appendingPathComponent(fileCollection()[fileCollection().firstIndex(of: "Realm_Shot_Marker_Table.csv")!])
        
        var fifthFileContentsParsed: [[String]] = [[String]]()
        // get contents of specfic csv file and place into array above
        do {
            fifthFileContentsParsed =  (try String(contentsOf: fifthDocumentPath, encoding: .utf8)).components(separatedBy: "\n").map{ $0.components(separatedBy: ",") }
        } catch {
            print("Error Finding Containts of File")
        }
        
        if (fifthFileContentsParsed[0].count == 8){
            try? realm.write ({
                //delete contents of table in realm DB
                realm.delete(realm.objects(shotMarkerTable.self))
                
                for i in 1..<fifthFileContentsParsed.count - 1{
                    if(fifthFileContentsParsed[i].contains{$0 != ""}){
                        var primaryID: Int!
                        if (self.realm.objects(shotMarkerTable.self).max(ofProperty: "cordSetID") as Int? != nil){
                            primaryID = (self.realm.objects(shotMarkerTable.self).max(ofProperty: "cordSetID") as Int? ?? 0) + 1;
                        }else{
                            primaryID = (self.realm.objects(shotMarkerTable.self).max(ofProperty: "cordSetID") as Int? ?? 0);
                        }
                        self.realm.create(shotMarkerTable.self, value: ["cordSetID": primaryID])
                        let primaryMarkerID = self.realm.object(ofType: shotMarkerTable.self, forPrimaryKey: primaryID)
                        var count = 0
                        primaryMarkerID?.gameID = Int(fifthFileContentsParsed[i][count])!; count += 1
                        primaryMarkerID?.TeamID = Int(fifthFileContentsParsed[i][count])!; count += 1
                        primaryMarkerID?.goalieID = Int(fifthFileContentsParsed[i][count])!; count += 1
                        primaryMarkerID?.periodNum = Int(fifthFileContentsParsed[i][count])!; count += 1
                        primaryMarkerID?.xCordShot = Int(fifthFileContentsParsed[i][count])!; count += 1
                        primaryMarkerID?.yCordShot = Int(fifthFileContentsParsed[i][count])!; count += 1
                        primaryMarkerID?.shotLocation = Int(fifthFileContentsParsed[i][count])!; count += 1
                        if (Bool(fifthFileContentsParsed[i][count]) != nil && Bool(fifthFileContentsParsed[i][count])!){
                            primaryMarkerID?.activeState = (Bool(fifthFileContentsParsed[i][count]))!; count += 1
                        }else{
                            let set = CharacterSet(charactersIn: "truefalse")
                            primaryMarkerID?.activeState = Bool((fifthFileContentsParsed[i][count]).lowercased().components(separatedBy: set.inverted).joined())!; count += 1
                        }
                    }else{
                        acceptedIncorrectDataFormat(fileType: "Shot Marker Table")
                        break
                    }
                    
                }
            })
            print("Shot Marker Table Success")
            return(true)
        }else{
            incorrectDataFormat(fileType: "Shot Marker Table")
            return(false)
        }
    }
    
    // convert csv files to string then convert [[string]] to penalty table in realm
    func csvStringToRealmPenaltyTable() -> Bool{
        // get document path based on search for spefic file
        let documentsUrl = documentURLProducer()
        let sixDocumentPath = documentsUrl.appendingPathComponent(fileCollection()[fileCollection().firstIndex(of: "Realm_Penalty_Table.csv")!])
        
        var sixFileContentsParsed: [[String]] = [[String]]()
        // get contents of specfic csv file and place into array above
        do {
            sixFileContentsParsed =  (try String(contentsOf: sixDocumentPath, encoding: .utf8)).components(separatedBy: "\n").map{ $0.components(separatedBy: ",") }
        } catch {
            print("Error Finding Containts of File")
        }
        
        if (sixFileContentsParsed[0].count == 7){
            try? realm.write ({
                //delete contents of table in realm DB
                realm.delete(realm.objects(penaltyTable.self))
                
                for i in 1..<sixFileContentsParsed.count - 1{
                    if(sixFileContentsParsed[i].contains{$0 != ""}){
                        var primaryID: Int!
                        if (self.realm.objects(penaltyTable.self).max(ofProperty: "penaltyID") as Int? != nil){
                            primaryID = (self.realm.objects(penaltyTable.self).max(ofProperty: "penaltyID") as Int? ?? 0) + 1;
                        }else{
                            primaryID = (self.realm.objects(penaltyTable.self).max(ofProperty: "penaltyID") as Int? ?? 0);
                        }
                        self.realm.create(penaltyTable.self, value: ["penaltyID": primaryID])
                        let primaryMarkerID = self.realm.object(ofType: penaltyTable.self, forPrimaryKey: primaryID)
                        var count = 0
                        primaryMarkerID?.gameID = Int(sixFileContentsParsed[i][count])!; count += 1
                        primaryMarkerID?.playerID = Int(sixFileContentsParsed[i][count])!; count += 1
                        primaryMarkerID?.penaltyType = sixFileContentsParsed[i][count]; count += 1
                        primaryMarkerID?.timeOfOffense = stringToDate.stringToDateFormatter(unformattedString: sixFileContentsParsed[i][count]); count += 1
                        primaryMarkerID?.xCord = Int(sixFileContentsParsed[i][count])!; count += 1
                        primaryMarkerID?.yCord = Int(sixFileContentsParsed[i][count])!; count += 1
                        if (Bool(sixFileContentsParsed[i][count]) != nil && Bool(sixFileContentsParsed[i][count])!){
                            primaryMarkerID?.activeState = (Bool(sixFileContentsParsed[i][count]))!; count += 1
                        }else{
                            let set = CharacterSet(charactersIn: "truefalse")
                            primaryMarkerID?.activeState = Bool((sixFileContentsParsed[i][count]).lowercased().components(separatedBy: set.inverted).joined())!; count += 1
                        }
                    }else{
                        acceptedIncorrectDataFormat(fileType: "Penalty Table")
                        break
                    }
                    
                }
            })
            print("Shot Marker Table Success")
            return(true)
        }else{
            incorrectDataFormat(fileType: "Penalty Table")
            return(false)
        }
    }
    
    // convert csv files to string then convert [[string]] to penalty table in realm
    func csvStringToRealmOverallStatsTable() -> Bool{
        // get document path based on search for spefic file
        let documentsUrl = documentURLProducer()
        let sevenDocumentPath = documentsUrl.appendingPathComponent(fileCollection()[fileCollection().firstIndex(of: "Realm_Overall_Stats_Table.csv")!])
        
        var sevenFileContentsParsed: [[String]] = [[String]]()
        // get contents of specfic csv file and place into array above
        do {
            sevenFileContentsParsed =  (try String(contentsOf: sevenDocumentPath, encoding: .utf8)).components(separatedBy: "\n").map{ $0.components(separatedBy: ",") }
        } catch {
            print("Error Finding Containts of File")
        }
        
        if (sevenFileContentsParsed[0].count == 7){
            try? realm.write ({
                //delete contents of table in realm DB
                realm.delete(realm.objects(overallStatsTable.self))
                
                for i in 1..<sevenFileContentsParsed.count - 1{
                    if(sevenFileContentsParsed[i].contains{$0 != ""}){
                        var primaryID: Int!
                        if (self.realm.objects(overallStatsTable.self).max(ofProperty: "overallStatsID") as Int? != nil){
                            primaryID = (self.realm.objects(overallStatsTable.self).max(ofProperty: "overallStatsID") as Int? ?? 0) + 1;
                        }else{
                            primaryID = (self.realm.objects(overallStatsTable.self).max(ofProperty: "overallStatsID") as Int? ?? 0);
                        }
                        self.realm.create(overallStatsTable.self, value: ["overallStatsID": primaryID])
                        let primaryOverallID = self.realm.object(ofType: overallStatsTable.self, forPrimaryKey: primaryID)
                        var count = 0
                        primaryOverallID?.gameID = Int(sevenFileContentsParsed[i][count])!; count += 1
                        primaryOverallID?.playerID = Int(sevenFileContentsParsed[i][count])!; count += 1
                        primaryOverallID?.lineNum = Int(sevenFileContentsParsed[i][count])!; count += 1
                        primaryOverallID?.goalCount = Int(sevenFileContentsParsed[i][count])!; count += 1
                        primaryOverallID?.assistCount = Int(sevenFileContentsParsed[i][count])!; count += 1
                        primaryOverallID?.plusMinus = Int(sevenFileContentsParsed[i][count])!; count += 1
                        if (Bool(sevenFileContentsParsed[i][count]) != nil && Bool(sevenFileContentsParsed[i][count])!){
                            primaryOverallID?.activeState = (Bool(sevenFileContentsParsed[i][count]))!; count += 1
                        }else{
                            let set = CharacterSet(charactersIn: "truefalse")
                            primaryOverallID?.activeState = Bool((sevenFileContentsParsed[i][count]).lowercased().components(separatedBy: set.inverted).joined())!; count += 1
                        }
                    }else{
                        acceptedIncorrectDataFormat(fileType: "Overall Stats Table")
                        break
                    }
                    
                }
            })
            print("Overall Stats Table Success")
            return(true)
        }else{
            incorrectDataFormat(fileType: "Overall Stats Table")
            return(false)
        }
    }
    
    
    func incorrectDataFormat(fileType: String) -> Bool{
        
        let alertController = UIAlertController(title: "File Format Error", message:
            "The \(fileType) format is incorrect please select another file and try again", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
        }))
        self.present(alertController, animated: true, completion: nil)
        print("The \(fileType) format is incorrect please select another file and try again")
        return true
    }
    
    func acceptedIncorrectDataFormat(fileType: String){
        
        let alertController = UIAlertController(title: "File Format Error", message:
            "The \(fileType) format is blank please make sure this is correct, process will still continue", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
            print("The \(fileType) format is blank please make sure this is correct, process will still continue")
            print("Import Success")
            self.performSegue(withIdentifier: "importButtonSegue", sender: nil);
        }))
    }
    
    func errorShake(){
        //produce shake animation on error of double home team
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.06
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = CGPoint(x: Popupview.center.x - 10, y: Popupview.center.y)
        animation.toValue = CGPoint(x: Popupview.center.x + 10, y: Popupview.center.y)
        Popupview.layer.add(animation, forKey: "position")
        popUpTitle.text = "Please Select \(limit) Files"
        popUpTitle.textColor = UIColor.red
    }
    
    func notEnoughFiles(fileCount: Int){
        
        let alertController = UIAlertController(title: "File Selection Error", message:
            "Please select more than \(fileCount) and no more than \(limit) files!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
            print("No enough files selected!")
        }))
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        if (setupPhaseBool != true){
            self.performSegue(withIdentifier: "Back_To_Settings_Import", sender: nil);
        }else{
            self.performSegue(withIdentifier: "Back_To_Setup_Import", sender: nil);
        }
    }
    
    @IBAction func importButton(_ sender: UIButton) {
        if let sr = tableView.indexPathsForSelectedRows {
            if (sr.count == Int(limit)!){
                print("Enough files selected")
        
                if (csvStringToRealmNewGameTable() != false && csvStringToRealmTeamTable() != false && csvStringToRealmPlayerTable() != false && csvStringToRealmGoalMarkerTable() != false && csvStringToRealmShotlMarkerTable() != false && csvStringToRealmPenaltyTable() != false && csvStringToRealmOverallStatsTable() != false && setupPhaseBool != true){
                    print("Import Success")
                    self.performSegue(withIdentifier: "Back_To_Settings_Import", sender: nil);
                }else if (csvStringToRealmNewGameTable() != false && csvStringToRealmTeamTable() != false && csvStringToRealmPlayerTable() != false && csvStringToRealmGoalMarkerTable() != false && csvStringToRealmShotlMarkerTable() != false && csvStringToRealmPenaltyTable() != false && csvStringToRealmOverallStatsTable() != false && setupPhaseBool == true){
                    self.performSegue(withIdentifier: "Back_To_Setup_Import", sender: nil);
                }
            }else{
                errorShake()
            }
        }else{
            errorShake()
        }
        
    }
    // Returns count of items in tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.fileNamesArray.count;
    }
    
    
    // Select item from tableView
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let sr = tableView.indexPathsForSelectedRows {
            if (sr.count > Int(limit)! ){
                
                let alertController = UIAlertController(title: "Oops", message:
                    "No More than \(limit) File Selctions at a Time", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                    print(indexPath)
                    // deselect ectra row
                    tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
                    tableView.deselectRow(at: indexPath, animated: true)
                    // remove deselected file names
                    self.selectedFileNamesArray = self.selectedFileNamesArray.filter(){$0 != self.fileNamesArray[indexPath.row]}
                    
                }))
                self.present(alertController, animated: true, completion: nil)
                print("More than \(limit) items were selcted!")
                
            }
        }
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCell.AccessoryType.checkmark
        {
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
            
            // remove deselected file names
            selectedFileNamesArray = selectedFileNamesArray.filter(){$0 != fileNamesArray[indexPath.row]}
        }
        else
        {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
            // get selected file names
            selectedFileNamesArray.append(fileNamesArray[indexPath.row])
        }
        print("File Name : " + fileNamesArray[indexPath.row])
        print("Files Added to Array: ", selectedFileNamesArray)
    }
    
    //Assign values for tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = fileNamesArray[indexPath.row]
        
        return cell
    }
    
    // delay loop
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
}
