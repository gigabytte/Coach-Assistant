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

class Team_About_Popup_View_Controller: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var dataWarningTeamPieChart: UILabel!
    @IBOutlet weak var teamToggleSwitch: UISwitch!
    @IBOutlet weak var teamIsActiveLabel: UILabel!
    @IBOutlet weak var seasonEditTextField: UITextField!
    @IBOutlet weak var teamNameEditTextField: UITextField!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var teamLogoImageView: UIImageView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var seasonNumberLabel: UILabel!
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
   // @IBOutlet weak var teamBarChartView: BarChartView!
    @IBOutlet weak var teamPieChartView: PieChartView!
    
    @IBOutlet weak var teamStatsTableView: UITableView!
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
    var imagePickerController : UIImagePickerController!
    
    var selectedTeamID: Int!
    
    var gameIDArray: [Int] = [Int]()
    var teamStatsAvgArray: [[Int]] = [[], [], [], [], [],[]]
    var teamStatsCalc: [String] = [String]()
    
    var teamWinsDataEntry = PieChartDataEntry(value: 0)
    var teamLosesDataEntry = PieChartDataEntry(value: 0)
    var teamTiesDataEntry = PieChartDataEntry(value: 0)
    
    var homeTeamWinCount: Int!
    var homeTeamTieCount: Int!
    var homeTeamLooseCount: Int!
    
    var pieChartBlurView: UIVisualEffectView!
    
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
        
        teamStatsTableView.dataSource = self
        teamStatsTableView.delegate = self
        
        onLoad()
        // Do any additional setup after loading the view.
    }
    
    func onLoad(){
        
        let realm = try! Realm()
        let teamObjc = realm.object(ofType: teamInfoTable.self, forPrimaryKey: selectedTeamID)
        
        viewColour()
        
        if let teamName = teamObjc?.nameOfTeam{
            if teamName != ""{
                teamNameLabel.text = teamName
                let width = teamNameLabel.intrinsicContentSize.width + 10
                teamNameLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
            }else{
                teamNameLabel.text = "Unknow Team Name"
                let width = teamNameLabel.intrinsicContentSize.width + 10
                teamNameLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
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
                teamLogoImageView.image = readerResult
            }else{
                // default image goes here
                teamLogoImageView.image = UIImage(named: "temp_profile_pic_icon")
            }
        }
        
        teamToggleSwitch.isOn = teamObjc!.activeState
  
        switchState()
        recordLabelProcessing()
        teamStatsProcessing()
        chartsBlur()
        teamPieChartValues()
        
    }
    
    func viewColour(){
        
        popUpView.layer.cornerRadius = 10
        
        teamLogoImageView.heightAnchor.constraint(equalToConstant: teamLogoImageView.frame.height).isActive = true
        teamLogoImageView.setRounded()
        
        roundedCorners().tableViewTopLeftRight(tableviewType: teamStatsTableView)
        teamStatsTableView.tableFooterView = UIView()
        
        teamStatsTableView.backgroundColor = systemColour().tableViewColor()
        self.popUpView.backgroundColor = systemColour().viewColor()
    }
    
    func chartsBlur(){
        // give background blur effect
        // add blur effect to chart views
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        
        pieChartBlurView = UIVisualEffectView(effect: blurEffect)
        pieChartBlurView.frame = teamPieChartView.bounds
        pieChartBlurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        teamPieChartView.addSubview(pieChartBlurView)
        pieChartBlurView.isHidden = true

        
    }
    
    func teamPieChartSettings(){
        
        let teamRecordCriteria = [teamWinsDataEntry, teamLosesDataEntry, teamTiesDataEntry]
        let chartDataSet = PieChartDataSet(entries: teamRecordCriteria, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        chartDataSet.drawValuesEnabled = false
        // set visual aspect of pie chart iuncluding colours and animations
        let colours = [UIColor.green, UIColor.red, UIColor.blue]
        chartDataSet.colors = colours
        teamPieChartView.data = chartData
        teamPieChartView.animate(xAxisDuration: 2.0, yAxisDuration:2.0)
        teamPieChartView.drawEntryLabelsEnabled = false
        teamPieChartView.holeColor = NSUIColor.init(cgColor: UIColor.clear.cgColor)
        
    }
    
    func teamPieChartValues(){
        
        teamPieChartSettings()
        
        teamWinsDataEntry.label = "# of Wins"
        teamLosesDataEntry.label = "# of Loses"
        teamTiesDataEntry.label = "# of Ties"
        
        let totalGames = homeTeamWinCount + homeTeamLooseCount + homeTeamTieCount
        if totalGames != 0{
            teamWinsDataEntry.value = Double(homeTeamWinCount) / Double(totalGames)
            teamLosesDataEntry.value = Double(homeTeamLooseCount) / Double(totalGames)
            teamTiesDataEntry.value = Double(homeTeamTieCount) / Double(totalGames)
            
            
        }else{
            // if total games will be divisable by 0 then default is even desperment error
            teamWinsDataEntry.value = 33.3
            teamLosesDataEntry.value = 33.3
            teamTiesDataEntry.value = 33.3
            // shaw data warning
            dataWarningTeamPieChart.isHidden = false
            pieChartBlurView.isHidden = false
        }
    }
    
    func switchState(){
        let realm = try! Realm()
        let teamObjc = realm.object(ofType: teamInfoTable.self, forPrimaryKey: selectedTeamID)
        
        switch teamToggleSwitch.isOn {
        case true:
            teamIsActiveLabel.text = "\((teamObjc?.nameOfTeam)!) is Enabled"
            break
        case false:
            teamIsActiveLabel.text = "\((teamObjc?.nameOfTeam)!) is Disabled"
            break
        default:
            teamIsActiveLabel.text = "\((teamObjc?.nameOfTeam)!) is Enabled"
            break
        }
        
    }
    
    func recordLabelProcessing(){
        
        let realm = try! Realm()
        
        homeTeamWinCount = (realm.objects(newGameTable.self).filter(NSPredicate(format: "tieGameBool == false AND winingTeamID == %i AND activeState == true AND activeGameStatus == false", selectedTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)}).count
        homeTeamTieCount =  (realm.objects(newGameTable.self).filter(NSPredicate(format: "tieGameBool == true AND homeTeamID == %i AND activeState == true AND activeGameStatus == false", selectedTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)}).count
        homeTeamLooseCount =  (realm.objects(newGameTable.self).filter(NSPredicate(format: "tieGameBool == false AND losingTeamID == %i AND activeState == true AND activeGameStatus == false", selectedTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)}).count
        
        recordLabel.text = "W:\(String(homeTeamWinCount))-L:\(String(homeTeamLooseCount))-T:\(String(homeTeamTieCount))"
    }
    
    func teamStatsProcessing(){
        
        let realm = try! Realm()
        
        gameIDArray = ((realm.objects(newGameTable.self).filter(NSPredicate(format: "homeTeamID == %i OR opposingTeamID == %i AND activeState == true", selectedTeamID, selectedTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)}))
        
        for x in 0..<gameIDArray.count{
            
            // --------------------- GFA (Goals FOr home team) -----------------------------------
            let goalsFor = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND activeState == true", gameIDArray[x], selectedTeamID)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)})).count
            teamStatsAvgArray[0].append(goalsFor)
            
            // -------------------- SFA (Shots for home team) ------------------------------------
            let shotsFor =  ((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND activeState == true", gameIDArray[x], selectedTeamID)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)})).count
            teamStatsAvgArray[1].append(shotsFor)
            // --------------------  GAA (Goals against for home team) -------------------------------
            let goalsAgainst = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID != %i AND activeState == true", gameIDArray[x], selectedTeamID)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)})).count
            teamStatsAvgArray[2].append(goalsAgainst)
            // --------------------  SAA (Shots against for home team) -------------------------------
            let shotsAgainst = ((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID != %i AND activeState == true", gameIDArray[x], selectedTeamID)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)})).count
            teamStatsAvgArray[3].append(shotsAgainst)
            // ------------------- PPGA (Power Power Play Goals for home team) ------------------------
            let powerPlayGoals = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND powerPlay == true AND activeState == true", gameIDArray[x], selectedTeamID)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)})).count
            teamStatsAvgArray[4].append(powerPlayGoals)
            
            // ------------------- PPP (Power Power Play Goals for home team) ------------------------
            let numPowerPlays = ((realm.objects(penaltyTable.self).filter(NSPredicate(format: "gameID == %i AND teamID != %i AND activeState == true", gameIDArray[x], selectedTeamID)).value(forKeyPath: "penaltyID") as! [Int]).compactMap({Int($0)})).count
            
            let powerPlayPer = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND powerPlay == true AND activeState == true", gameIDArray[x], selectedTeamID)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)})).count
            if (powerPlayPer != 0){
                let powerPlayAVG = numPowerPlays / powerPlayPer
                teamStatsAvgArray[5].append(powerPlayAVG)
            }else{
                teamStatsAvgArray[5].append(0)
            }
            
            
        }
        // computer avg based on data set in 2d teamStatsAvgArray arrary
        // PPP STATS GEN
        let pppAVG = teamStatsAvgArray[5].reduce(.zero, +)
        if pppAVG != 0 {
            teamStatsCalc.append("PPP: " + String(pppAVG / teamStatsAvgArray[5].count) + "%")
        }else{
            teamStatsCalc.append("PPP: 0%")
        }
        // PPGA STATS GEN
        let ppgaAVG = teamStatsAvgArray[4].reduce(.zero, +)
        if ppgaAVG != 0{
            teamStatsCalc.append("PPGA: " + String(ppgaAVG / teamStatsAvgArray[4].count) + "%")
        }else{
            teamStatsCalc.append("PPGA: 0%")
        }
        // GFA STATS GEN
        let gfaAVG = teamStatsAvgArray[0].reduce(.zero, +)
        if gfaAVG != 0{
            teamStatsCalc.append("GFA: " + String(gfaAVG / teamStatsAvgArray[0].count) + "%")
        }else{
            teamStatsCalc.append("GFA: 0%")
        }
        // SFA STATS GEN
        let sfaAVG = teamStatsAvgArray[1].reduce(.zero, +)
        if sfaAVG != 0{
            teamStatsCalc.append("SFA: " + String(sfaAVG / teamStatsAvgArray[1].count) + "%")
        }else{
            teamStatsCalc.append("SFA: 0%")
        }
        // GAA STATS GEN
        let gaaAVG = teamStatsAvgArray[2].reduce(.zero, +)
        if gaaAVG != 0{
            teamStatsCalc.append("GAA: " + String(gaaAVG / teamStatsAvgArray[2].count) + "%")
        }else{
            teamStatsCalc.append("GAA: 0%")
        }
        // SAA STATS GEN
        let saaAVG = teamStatsAvgArray[3].reduce(.zero, +)
        if saaAVG != 0{
            teamStatsCalc.append("SAA: " + String(saaAVG / teamStatsAvgArray[3].count) + "%")
        }else{
            teamStatsCalc.append("SAA: 0%")
        }
        
        
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
                self.imagePickerController.delegate = self
                self.imagePickerController.sourceType = .camera
                self.imagePickerController.allowsEditing = true
                self.present(self.imagePickerController, animated: true, completion: nil)
            }
            
        }))
        // add an action (button)
        mediaAlert.addAction(UIAlertAction(title: "Photo Library", style: UIAlertAction.Style.default, handler: { action in
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
    
    func succesfulTeamEdit(teamName: String){
        
        let successfulQuery = UIAlertController(title: String(format: localizedString().localized(value:"Team %@ has been updated."), teamName), message: "", preferredStyle: UIAlertController.Style.alert)
        successfulQuery.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            
            self.teamNameEditTextField.text = ""
            self.seasonEditTextField.text = ""
            
        }))
        
        self.present(successfulQuery, animated: true, completion: nil)
    }
    
    func reNameProfileImageFile(logoURL: String, newName: String){
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let tempUrl = dir.appendingPathComponent("TeamLogo")
            let fileURL = tempUrl.appendingPathComponent(logoURL)
            
            let new_fileURL = tempUrl.appendingPathComponent(newName)
            
            do {
                try FileManager.default.moveItem(at: fileURL, to: new_fileURL)
            }catch{
                fatalErrorAlert("Unable to rename Team logo image, please contact support.")
                print("\(error)")
            }
            
            
        }
    }
    
    func saveTeamInfo(){
        
        let realm = try! Realm()
        
        let newName = teamNameEditTextField.text!
        let seasonNumber = seasonEditTextField.text!
        let teamObjc = realm.object(ofType: teamInfoTable.self, forPrimaryKey: selectedTeamID);
        
        if (newName != "" && seasonNumber != ""){
            // rename logo file name is name is chnaged
            if let oldLogoURL = teamObjc?.teamLogoURL{
                if oldLogoURL != ""{
                    reNameProfileImageFile(logoURL: oldLogoURL, newName: "\((teamObjc?.teamID)!)_ID_\(newName)_team_logo")
                }
            }
            
            try! realm.write{
                teamObjc!.activeState = teamToggleSwitch.isOn
                teamObjc!.nameOfTeam = newName
                teamObjc?.seasonYear = Int(seasonNumber)!
                teamObjc?.teamLogoURL = "\((teamObjc?.teamID)!)_ID_\(newName)_team_logo"
                
            }
            succesfulTeamEdit(teamName: teamObjc!.nameOfTeam)
        }else if (newName == "" && seasonNumber != ""){
    
            try! realm.write{
                teamObjc!.activeState = teamToggleSwitch.isOn
                teamObjc?.seasonYear = Int(seasonNumber)!
                
            }
            succesfulTeamEdit(teamName: newName)
            
        }else if (newName == "" && seasonNumber == ""){
          
            try! realm.write{
                teamObjc!.activeState = teamToggleSwitch.isOn
            }
            succesfulTeamEdit(teamName: teamObjc!.nameOfTeam)
        }else if (newName != "" && seasonNumber == ""){
            // rename logo file name is name is chnaged
            if let oldLogoURL = teamObjc?.teamLogoURL{
                if oldLogoURL != ""{
                    reNameProfileImageFile(logoURL: oldLogoURL, newName: "\((teamObjc?.teamID)!)_ID_\(newName)_team_logo")
                }
            }
            
            try! realm.write{
                teamObjc!.activeState = teamToggleSwitch.isOn
                teamObjc!.nameOfTeam = newName
                teamObjc?.teamLogoURL = "\((teamObjc?.teamID)!)_ID_\(newName)_team_logo"
            }
            succesfulTeamEdit(teamName: teamObjc!.nameOfTeam)
        }else{
            try! realm.write{
                teamObjc!.activeState = teamToggleSwitch.isOn
                teamObjc!.nameOfTeam = newName
                teamObjc?.seasonYear = Int(seasonNumber)!
                
            }
            succesfulTeamEdit(teamName: teamObjc!.nameOfTeam)
        }
        

    }
    
    func isEditingFields(boolType: Bool){
        
        switch boolType {
        case true:
            
            teamNameLabel.isHidden = false
            seasonNumberLabel.isHidden = false
            recordLabel.isHidden = false
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                self.teamNameLabel.alpha = 1.0
                self.seasonNumberLabel.alpha = 1.0
                self.recordLabel.alpha = 1.0
                
                self.teamNameEditTextField.alpha = 0.0
                self.seasonEditTextField.alpha = 0.0
                self.teamToggleSwitch.alpha = 0.0
                self.teamIsActiveLabel.alpha = 0.0
                
                self.view.layoutIfNeeded()
                
            }, completion: { _ in
                self.teamNameEditTextField.isHidden = true
                self.seasonEditTextField.isHidden = true
                self.teamToggleSwitch.isHidden = true
                self.teamIsActiveLabel.isHidden = true
            })
            
            break
        case false:
            
            self.teamNameEditTextField.isHidden = false
            self.seasonEditTextField.isHidden = false
            self.teamToggleSwitch.isHidden = false
            self.teamIsActiveLabel.isHidden = false
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                
                self.teamNameLabel.alpha = 0.0
                self.seasonNumberLabel.alpha = 0.0
                self.recordLabel.alpha = 0.0
                
                self.teamNameEditTextField.alpha = 1.0
                self.seasonEditTextField.alpha = 1.0
                self.teamToggleSwitch.alpha = 1.0
                self.teamIsActiveLabel.alpha = 1.0
                
                self.view.layoutIfNeeded()
            }, completion: { _ in
                
                self.teamNameLabel.isHidden = true
                self.seasonNumberLabel.isHidden = true
                self.recordLabel.isHidden = true
            })
            break
        default:
            
            self.teamNameEditTextField.isHidden = false
            self.seasonEditTextField.isHidden = false
            self.teamToggleSwitch.isHidden = false
            self.teamIsActiveLabel.isHidden = false
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                
                self.teamNameLabel.alpha = 0.0
                self.seasonNumberLabel.alpha = 0.0
                self.recordLabel.alpha = 0.0
                
                self.teamNameEditTextField.alpha = 1.0
                self.seasonEditTextField.alpha = 1.0
                self.teamToggleSwitch.alpha = 1.0
                self.teamIsActiveLabel.alpha = 1.0
                
                self.view.layoutIfNeeded()
            }, completion: { _ in
                
                self.teamNameLabel.isHidden = true
                self.seasonNumberLabel.isHidden = true
                self.recordLabel.isHidden = true
            })
            break
        }
    }
    
    @IBAction func editTeamInfoButton(_ sender: UIButton) {
        
        let realm = try! Realm()
        let editedTeam = realm.object(ofType: teamInfoTable.self, forPrimaryKey: selectedTeamID);
        // is player label is already hidden reverse the process
        if teamNameLabel.isHidden == true{
            // write new player inffo to realm
            // update UI
            saveTeamInfo()
            isEditingFields(boolType: true)
            onLoad()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "homePageRefresh"), object: nil, userInfo: ["key":"value"])
        }else{
            
            isEditingFields(boolType: false)
        }
    }
    
    @IBAction func closeButton(_ sender: Any) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "homePageRefresh"), object: nil, userInfo: ["key":"value"])
        self.dismiss(animated: true, completion: nil)
       
    }
    
    @objc func teamLogoTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        print("Opening Photo Selection Method")
        mediaTypeSlectionAlert()
        
    }
    @IBAction func teamToggleSwitch(_ sender: UISwitch) {
        switchState()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
      
        return("Team Stats")
   
    }
    // Returns count of items in tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        

        return(6)
    
    }
    //Assign values for tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell:customTeamStatsCell = self.teamStatsTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! customTeamStatsCell
        
        if (tableView == teamStatsTableView){
            print("pro user\(UserDefaults.standard.bool(forKey: "userPurchaseConf"))")
            switch indexPath.row {
                case 0:
                    if UserDefaults.standard.bool(forKey: "userPurchaseConf") == false{
                        cell.proStateLogoImageView.isHidden = false
                        cell.statsLabel!.text = "PPP:"
                    }else{
                         cell.statsLabel!.text = teamStatsCalc[indexPath.row]
                    }
                break
                case 1:
                    if UserDefaults.standard.bool(forKey: "userPurchaseConf") == false{
                        cell.proStateLogoImageView.isHidden = false
                        cell.statsLabel!.text = "PPGA:"
                    }else{
                        cell.statsLabel!.text = teamStatsCalc[indexPath.row]
                    }
                break
                default:
                    
                    cell.proStateLogoImageView.isHidden = true
                    cell.statsLabel!.text = teamStatsCalc[indexPath.row]
                break
            }
            
            
        }
        return cell
    }
  

}

extension Team_About_Popup_View_Controller:  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
  
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let realm = try! Realm()
        let teamObjc = realm.object(ofType: teamInfoTable.self, forPrimaryKey: selectedTeamID)
        
        guard let selectedImage = info[.editedImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        imageWriter(fileName: "\((teamObjc?.teamID)!)_ID_\((teamObjc?.nameOfTeam)!)_team_logo", imageName: selectedImage)
        onLoad()
        
        
        //Dismiss the UIImagePicker after selection
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        self.dismiss(animated: true, completion: nil)
    }
    
    func imageWriter(fileName: String, imageName: UIImage){
        
        let realm = try! Realm()
        let teamObjc = realm.object(ofType: teamInfoTable.self, forPrimaryKey: selectedTeamID)
        
        let imageData = imageName.jpegData(compressionQuality: 0.10)
        
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let tempUrl = dir.appendingPathComponent("TeamLogo")
            let fileURL = tempUrl.appendingPathComponent(fileName)
            
            if let oldLogoURL = teamObjc?.teamLogoURL{
                if oldLogoURL != ""{
                    do{
                        try FileManager.default.removeItem(atPath: (tempUrl.appendingPathComponent(oldLogoURL)).path)
                        do {
                            try imageData!.write(to: fileURL, options: .atomicWrite)
                            // send realm the location of the logo in DD
                            realmLogoRefrence(fileURL: fileName)
                            
                        } catch {
                            print("Player logo write error")
                            fatalErrorAlert("An error has occured while attempting to save your team logo image. Please contact support!")
                        }
                    }catch{
                        print("\(error)")
                        fatalErrorAlert("Unable to remove old team logo image, please try again.")
                    }
                }else{
                    do {
                        try imageData!.write(to: fileURL, options: .atomicWrite)
                        // send realm the location of the logo in DD
                        realmLogoRefrence(fileURL: fileName)
                        
                    } catch {
                        print("Player logo write error")
                        fatalErrorAlert("An error has occured while attempting to save your team logo image. Please contact support!")
                    }
                }
            }
            
        }
    }
    
    func imageReader(fileName: String) -> UIImage{
        
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
               
            }
        }
        if retreivedImage != nil{
            return(retreivedImage)
        }else{
            return(UIImage(named: "temp_profile_pic_icon")!)
        }
    }
}
