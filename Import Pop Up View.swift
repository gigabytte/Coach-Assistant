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
    
    @IBOutlet weak var Popupview: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var fileNamesArray: [String] = [String]()
    var selectedFileNamesArray: [String] = [String]()
    var limit: String = "5"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        fileCollection()
        
    }
    
    func fileCollection() -> [String]{
        
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
                        let filePathName = "\(documentPath)/\(fileName)"
                        fileNamesArray.append(fileName)
                    }
                }
            }
            
        } catch {
            print("Could not find documents: \(error)")
        }
        return(fileNamesArray)
    }

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
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let firstDocumentPath = documentsUrl.appendingPathComponent(fileCollection()[fileCollection().firstIndex(of: "Realm_New_Game_Info_Table.csv")!])
        
        var firstFileContentsParsed: [[String]] = [[String]]()
        // get contents of specfic csv file and place into array above
        do {
            firstFileContentsParsed =  (try String(contentsOf: firstDocumentPath, encoding: .utf8)).components(separatedBy: "\n").map{ $0.components(separatedBy: ",") }
        } catch {
            print("Error Finding Contents of File")
        }
        
        if (firstFileContentsParsed[0].count == 9){
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
                        primaryGameID?.winingTeamID = Int(firstFileContentsParsed[i][count])!; count += 1
                        primaryGameID?.losingTeamID = Int(firstFileContentsParsed[i][count])!; count += 1
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
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let sectDocumentPath = documentsUrl.appendingPathComponent(fileCollection()[fileCollection().firstIndex(of: "Realm_Team_Info_Table.csv")!])
        
        var secFileContentsParsed: [[String]] = [[String]]()
        // get contents of specfic csv file and place into array above
        do {
            secFileContentsParsed =  (try String(contentsOf: sectDocumentPath, encoding: .utf8)).components(separatedBy: "\n").map{ $0.components(separatedBy: ",") }
        } catch {
            print("Error Finding Containts of File")
        }
    
        if (secFileContentsParsed[1].count == 2){
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
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
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
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fourthDocumentPath = documentsUrl.appendingPathComponent(fileCollection()[fileCollection().firstIndex(of: "Realm_Goal_Marker_Table.csv")!])
        
        var fourthFileContentsParsed: [[String]] = [[String]]()
        // get contents of specfic csv file and place into array above
        do {
            fourthFileContentsParsed =  (try String(contentsOf: fourthDocumentPath, encoding: .utf8)).components(separatedBy: "\n").map{ $0.components(separatedBy: ",") }
        } catch {
            print("Error Finding Containts of File")
        }
        
        if (fourthFileContentsParsed[0].count == 15){
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
                        primaryMarkerID?.againstFLine = Int(fourthFileContentsParsed[i][count])!; count += 1
                        primaryMarkerID?.againstDLine = Int(fourthFileContentsParsed[i][count])!; count += 1
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
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
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
    
    @IBAction func cancelButton(_ sender: Any) {
        self.performSegue(withIdentifier: "cancelButtonSegue", sender: nil);
    }
    
    @IBAction func importButton(_ sender: Any) {
        
        if (csvStringToRealmNewGameTable() != false && csvStringToRealmTeamTable() != false && csvStringToRealmPlayerTable() != false && csvStringToRealmGoalMarkerTable() != false && csvStringToRealmShotlMarkerTable() != false){
            print("Import Success")
            self.performSegue(withIdentifier: "importButtonSegue", sender: nil);
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

    // func used to pass varables on segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check is appropriate segue is being used
        if (segue.identifier == "importButtonSegue"){
            // set var vc as destination segue
            let vc = segue.destination as! Settings_Page
            vc.successImport = true
        }
    }
}
