//
//  Player About Popup View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-08-23.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import RealmSwift
import Charts

class Player_About_Popup_View_Controller: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var playerStatsTableView: UITableView!
    @IBOutlet weak var playerActiveSwitch: UISwitch!
    @IBOutlet weak var playerIsActiveLabel: UILabel!
    @IBOutlet weak var playerProfileImageView: UIImageView!
    @IBOutlet weak var editFieldsButton: UIButton!
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var playerNumberLabel: UILabel!
    @IBOutlet weak var playerPositionLabel: UILabel!
    @IBOutlet weak var playerLineNumberLabel: UILabel!
    @IBOutlet weak var playerEditNameTextField: UITextField!
    @IBOutlet weak var playerEditNumberTextField: UITextField!
    @IBOutlet weak var lineNumberPicker: UIPickerView!
    @IBOutlet weak var positionTypePicker: UIPickerView!
    @IBOutlet weak var playerInfoTableView: UITableView!
    @IBOutlet weak var dataWarningLabel: UILabel!
    
    @IBOutlet weak var playerInfoPieChartView: PieChartView!
    @IBOutlet weak var popUpView: UIView!
    
    var playerGoalDataEntry = PieChartDataEntry(value: 0)
    var playerAssistDataEntry = PieChartDataEntry(value: 0)
    var playerPowerPlayGoalDataEntry = PieChartDataEntry(value: 0)
    
    var tlShotValue = PieChartDataEntry(value: 0)
    var trShotValue = PieChartDataEntry(value: 0)
    var blShotValue = PieChartDataEntry(value: 0)
    var brShotValue = PieChartDataEntry(value: 0)
    var cShotValue = PieChartDataEntry(value: 0)
    
    var passedPlayerID: Int!
    var selectPosition: String!
    var selectLine: Int!
    
    var imagePickerController : UIImagePickerController!
    
    var pickerData:[String] = [String]()
    var forwardPositionData:[String] = [String]()
    var defensePositionData:[String] = [String]()
    var goaliePositionData:[String] = [String]()
    var positionCodeData:[String] = [String]()
    var homePlayerStatsArray: [String] = [String]()
    var goalieStatsArray: [String] = [String]()
    var gameIDArray: [Int] = [Int]()
    var lastGoalArray: [String] = [String]()
    var playerGoalCount: Int!
    var playerAssitCount: Int!
    
    var topLeft: Int!
    var topRight: Int!
    var bottomLeft: Int!
    var bottomRight: Int!
    var center: Int!
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(playerProfileImageTapped(tapGestureRecognizer:)))
        playerProfileImageView.isUserInteractionEnabled = true
        playerProfileImageView.addGestureRecognizer(tapGestureRecognizer)
        
        // add blur effect to view along with popUpView
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.addSubview(popUpView)
        
        self.lineNumberPicker.delegate = self
        self.lineNumberPicker.dataSource = self
        
        self.positionTypePicker.delegate = self
        self.positionTypePicker.dataSource = self
        
        playerInfoTableView.dataSource = self
        playerInfoTableView.delegate = self
        
        onLoad()
    }
    
    func onLoad(){
        
        statsProcessing()
        playerPieChartValues()
        playerPieChartSettings()
        
        // set view colour attributes
        viewColour()
    }
    
    func playerPieChartSettings(){
        
        let realm = try! Realm()
        let playerObjc = realm.object(ofType: playerInfoTable.self, forPrimaryKey: passedPlayerID)
        
        var teamRecordCriteria: [PieChartDataEntry] = [PieChartDataEntry]()
        
        if playerObjc?.positionType != "G"{
            teamRecordCriteria = [playerGoalDataEntry, playerAssistDataEntry, playerPowerPlayGoalDataEntry]
        }else{
            teamRecordCriteria = [tlShotValue, trShotValue, blShotValue, brShotValue, cShotValue]
        }
        let chartDataSet = PieChartDataSet(entries: teamRecordCriteria, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        chartDataSet.drawValuesEnabled = false
        // set visual aspect of pie chart iuncluding colours and animations
        let colours = [UIColor.green, UIColor.blue, UIColor.red, UIColor.purple, UIColor.orange, UIColor.yellow]
        chartDataSet.colors = colours
        playerInfoPieChartView.data = chartData
        playerInfoPieChartView.animate(xAxisDuration: 2.0, yAxisDuration:2.0)
        playerInfoPieChartView.drawEntryLabelsEnabled = false
        playerInfoPieChartView.holeColor = NSUIColor.init(cgColor: UIColor.clear.cgColor)
        
    }
    
    func playerPieChartValues(){
        
        let realm = try! Realm()
        let playerObjc = realm.object(ofType: playerInfoTable.self, forPrimaryKey: passedPlayerID)
        
        let powerPlayGoalCount = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "goalPlayerID == %i AND powerPlay == true AND activeState == true", passedPlayerID)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)})).count
        
        if playerObjc?.positionType != "G"{
        
            playerGoalDataEntry.label = "# of Goals"
            playerAssistDataEntry.label = "# of Shots"
            playerPowerPlayGoalDataEntry.label = "# of PowerPlay Goals"
            
            let totalPoints = playerAssitCount + playerGoalCount + powerPlayGoalCount
            if totalPoints != 0{
                playerGoalDataEntry.value = Double(playerGoalCount) / Double(totalPoints)
                playerAssistDataEntry.value = Double(playerAssitCount) / Double(totalPoints)
                playerPowerPlayGoalDataEntry.value = Double(powerPlayGoalCount) / Double(totalPoints)
                
            }else{
                // if total games will be divisable by 0 then default is even desperment error
                playerGoalDataEntry.value = 0.0
                playerAssistDataEntry.value = 0.0
                playerPowerPlayGoalDataEntry.value = 0.0
               
                // shaw data warning
                playerInfoPieChartView.isHidden = true
                //dataWarningTeamPieChart.isHidden = true
            }
        }else{
            
            tlShotValue.label = "Top Left"
            trShotValue.label = "Top Right"
            blShotValue.label = "Bottom Left"
            brShotValue.label = "Bottom Right"
            cShotValue.label = "Five Hole"
            
            let overalShotTotalArray: [Int] = [topLeft, topRight, bottomRight, bottomLeft, center]
            let overalShotTotal = Double(overalShotTotalArray.reduce(0, +))
            print("shots \(overalShotTotal)")
            // set shot location pie chart values based on % calc above;  total number of shot type / total number of shots
            if (overalShotTotal != 0){
                tlShotValue.value = (Double(topLeft)/overalShotTotal) * 1.00
            }else{
                tlShotValue.value = 0.0
            }
            if (overalShotTotal != 0){
                trShotValue.value = (Double(topRight)/overalShotTotal) * 1.00
            }else{
                trShotValue.value = 0.0
            }
            if (overalShotTotal != 0){
                blShotValue.value = (Double(bottomLeft)/overalShotTotal) * 1.00
            }else{
                blShotValue.value = 0.0
            }
            if (overalShotTotal != 0){
                brShotValue.value = (Double(bottomRight)/overalShotTotal) * 1.00
            }else{
                brShotValue.value = 0.0
            }
            if (overalShotTotal != 0){
                cShotValue.value = (Double(center)/overalShotTotal)  * 1.00
            }else{
                cShotValue.value = 0.0
            }
            dataUnavailableWarning()
        }
        
    }
    
    func dataUnavailableWarning(){
        // display place holder message if data missing for pie charts
        // ran on page load
        if (tlShotValue.value == 0.0 && trShotValue.value == 0.0 && blShotValue.value == 0.0 && brShotValue.value == 0.0 && cShotValue.value == 0.0){
            dataWarningLabel.isHidden = false
            
        }else{
            dataWarningLabel.isHidden = true
        }
        
    }
   
    
    func statsProcessing(){
        let realm = try! Realm()
        let playerObjc = realm.object(ofType: playerInfoTable.self, forPrimaryKey: passedPlayerID)
        
        // player info labels on load
        if let playerName = playerObjc?.playerName{
            if playerName != ""{
                playerNameLabel.text = playerName
                let width = playerNameLabel.intrinsicContentSize.width + 10
                playerNameLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
               
            }else{
                playerNameLabel.text = "Unknow Player Name"
                let width = playerNameLabel.intrinsicContentSize.width + 10
                playerNameLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
                
            }
        }
        
        if let playerNumber = playerObjc?.jerseyNum{
            if playerNumber != 0{
                playerNumberLabel.text? = "#\(playerNumber)"
                let width = playerNumberLabel.intrinsicContentSize.width + 10
                playerNumberLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
            }else{
                playerNumberLabel.text? = "#00"
                let width = playerNumberLabel.intrinsicContentSize.width + 10
                playerNumberLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
            }
        }
        

        if playerObjc?.lineNum != nil{
            playerLineNumberLabel.text = playerLinePositionConverter().realmInpuToString(rawInput: playerObjc!.lineNum)
        }else{
            playerLineNumberLabel.text = "Unknown"
        }
        
        if let positionType = playerObjc?.positionType{
            if positionType != "" {
                print(positionType)
                playerPositionLabel.text = playerPositionConverter().realmInpuToString(rawInput: positionType)
            }else{
                playerPositionLabel.text = "Unknown"
            }
        }

        if let URL = playerObjc?.playerLogoURL{
            if URL != ""{
                
                let readerResult = imageReader(fileName: playerObjc!.playerLogoURL)
                playerProfileImageView.image = readerResult
            }else{
                // default image goes here
                playerProfileImageView.image = UIImage(named: "temp_profile_pic_icon")
            }
            
            playerProfileImageView.heightAnchor.constraint(equalToConstant: playerProfileImageView.frame.height).isActive = true
            playerProfileImageView.setRounded()
        }
        
        pickerData = ["Forward 1", "Forward 2","Forward 3","Defense 1","Defense 2","Defense 3","Goalie"]
        forwardPositionData = ["Left Wing", "Center", "Right Wing"]
        defensePositionData = ["Left Defence", "Right Defence"]
        goaliePositionData = ["Goalie"]
        positionCodeData = ["LW", "C", "RW", "LD", "RD", "G"]
        
        selectPosition = positionCodeData[0]
        selectLine = 1
        
        
        playerActiveSwitch.isOn = playerObjc!.activeState
        switchState()
        
        if playerObjc?.positionType != "G"{
            playerStatsProcessing()
        }else{
            goalieStatsProcessing()
        }
        
    }
    
    func viewColour(){
        
        popUpView.layer.cornerRadius = 10
        
        roundedCorners().tableViewTopLeftRight(tableviewType: playerStatsTableView)
        playerStatsTableView.tableFooterView = UIView()
        
        playerStatsTableView.backgroundColor = systemColour().tableViewColor()
        self.popUpView.backgroundColor = systemColour().viewColor()
        
    }
    
    func switchState(){
        let realm = try! Realm()
        let playerObjc = realm.object(ofType: playerInfoTable.self, forPrimaryKey: passedPlayerID)
        
        
        switch playerActiveSwitch.isOn {
        case true:
            playerIsActiveLabel.text = "\((playerObjc?.playerName)!) is Enabled"
            break
        case false:
            playerIsActiveLabel.text = "\((playerObjc?.playerName)!) is Disabled"
            break
        
        }
        
    }
    
    func isEditingFields(boolType: Bool){
        
        switch boolType {
        case true:
            
            playerNameLabel.isHidden = false
            playerPositionLabel.isHidden = false
            playerLineNumberLabel.isHidden = false
            playerNumberLabel.isHidden = false
            playerInfoTableView.isHidden = false
            playerInfoPieChartView.isHidden = false
            
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                self.playerNameLabel.alpha = 1.0
                self.playerPositionLabel.alpha = 1.0
                self.playerLineNumberLabel.alpha = 1.0
                self.playerNumberLabel.alpha = 1.0
                self.playerInfoTableView.alpha = 1.0
                self.playerInfoPieChartView.alpha = 1.0
                
                self.playerEditNameTextField.alpha = 0.0
                self.playerEditNumberTextField.alpha = 0.0
                self.lineNumberPicker.alpha = 0.0
                self.positionTypePicker.alpha = 0.0
                self.playerIsActiveLabel.alpha = 0.0
                self.playerActiveSwitch.alpha = 0.0
                
                self.view.layoutIfNeeded()
            
            }, completion: { _ in
                self.playerEditNameTextField.isHidden = true
                self.playerEditNumberTextField.isHidden = true
                self.lineNumberPicker.isHidden = true
                self.positionTypePicker.isHidden = true
                self.playerIsActiveLabel.isHidden = true
                self.playerActiveSwitch.isHidden = true
            })
            
            break
        case false:
            
            playerEditNameTextField.isHidden = false
            playerEditNumberTextField.isHidden = false
            lineNumberPicker.isHidden = false
            positionTypePicker.isHidden = false
            playerIsActiveLabel.isHidden = false
            playerActiveSwitch.isHidden = false
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                
                self.playerEditNameTextField.alpha = 1.0
                self.playerEditNumberTextField.alpha = 1.0
                self.lineNumberPicker.alpha = 1.0
                self.positionTypePicker.alpha = 1.0
                self.playerIsActiveLabel.alpha = 1.0
                self.playerActiveSwitch.alpha = 1.0
                
                self.playerNameLabel.alpha = 0.0
                self.playerPositionLabel.alpha = 0.0
                self.playerLineNumberLabel.alpha = 0.0
                self.playerNumberLabel.alpha = 0.0
                self.playerInfoTableView.alpha = 0.0
                self.playerInfoPieChartView.alpha = 0.0
                
                self.view.layoutIfNeeded()
            }, completion: { _ in
                
                self.playerNameLabel.isHidden = true
                self.playerPositionLabel.isHidden = true
                self.playerLineNumberLabel.isHidden = true
                self.playerNumberLabel.isHidden = true
                self.playerInfoTableView.isHidden = true
                self.playerInfoPieChartView.isHidden = true
            })
            break
        }
    }
    
    func mediaTypeSlectionAlert(){
        
        // create the alert
        let mediaAlert = UIAlertController(title: localizedString().localized(value:"Logo Update"), message: localizedString().localized(value:"Select the location that your player porfile image should come from. Selecting Camera ill allow for you to take a brand new image. Libary will allow you to select an image from your photo libary on your device"), preferredStyle: UIAlertController.Style.alert)
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
    
    func realmLogoRefrence(fileURL: String){
        let realm = try! Realm()
        
        let playerObjc = realm.object(ofType: playerInfoTable.self, forPrimaryKey: passedPlayerID);
        
        try! realm.write {
            
            playerObjc!.playerLogoURL = fileURL
            
        }
        
    }
    
    func fatalErrorAlert(_ msg: String){
        
        let errorAlert = UIAlertController(title: localizedString().localized(value:"Whoops!"), message: localizedString().localized(value:"\(msg)"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(errorAlert, animated: true, completion: nil)
        
    }
    
    func succesfulPlayerAdd(playerName: String){
        
        let successfulQuery = UIAlertController(title: String(format: localizedString().localized(value:"Player %@ has been updated."), playerName), message: "", preferredStyle: UIAlertController.Style.alert)
        successfulQuery.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            
            self.playerEditNameTextField.text = ""
            self.playerEditNumberTextField.text = ""
    
        }))
        
        self.present(successfulQuery, animated: true, completion: nil)
    }
    
    func reNameProfileImageFile(logoURL: String, newName: String){
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let tempUrl = dir.appendingPathComponent("PlayerImages")
            let fileURL = tempUrl.appendingPathComponent(logoURL)
            
            let new_fileURL = tempUrl.appendingPathComponent(newName)
            
            do {
                try FileManager.default.moveItem(at: fileURL, to: new_fileURL)
            }catch{
                fatalErrorAlert("Unable to rename Player Profile image, please contact support.")
                print("\(error)")
            }
            
            
        }
    }
    
    func savePlayerInfo(){
        
        let realm = try! Realm()
        
        let playerLine = selectLine
        let playerPosition = selectPosition
        let playerName = playerEditNameTextField.text!
        let playerNumber = Int(playerEditNumberTextField.text!)
        let editedPlayer = realm.object(ofType: playerInfoTable.self, forPrimaryKey: passedPlayerID);
       
    // check to see if fields are filled out properly
        if(playerName != "" && playerEditNumberTextField.text! != ""){
            // rename logo file name is name is chnaged
            if let oldLogoURL = editedPlayer?.playerLogoURL{
                if oldLogoURL != ""{
                    reNameProfileImageFile(logoURL: oldLogoURL, newName: "\((editedPlayer?.playerID)!)_ID_\(playerName)_player_logo")
                }
            }
   
            try! realm.write {
                editedPlayer!.jerseyNum = playerNumber!
                editedPlayer!.playerName = playerName
                editedPlayer!.lineNum = playerLine!
                editedPlayer!.positionType = playerPosition!
                editedPlayer!.playerLogoURL = "\((editedPlayer?.playerID)!)_ID_\(playerName)_player_logo"
                editedPlayer!.activeState = playerActiveSwitch.isOn
            }
            editFieldsButton.tag = 20
        }else if(playerName != "" && playerEditNumberTextField.text! == ""){
            // rename logo file name is name is chnaged
            if let oldLogoURL = editedPlayer?.playerLogoURL{
                if oldLogoURL != ""{
                    reNameProfileImageFile(logoURL: oldLogoURL, newName: "\((editedPlayer?.playerID)!)_ID_\(playerName)_player_logo")
                }
            }
            
            try! realm.write {
                editedPlayer!.playerName = playerName
                editedPlayer!.lineNum = playerLine!
                editedPlayer!.positionType = playerPosition!
                editedPlayer!.playerLogoURL = "\((editedPlayer?.playerID)!)_ID_\(playerName)_player_logo"
                editedPlayer!.activeState = playerActiveSwitch.isOn
            }
            editFieldsButton.tag = 20
        }else if(playerName == "" && playerEditNumberTextField.text! != ""){
            
            try! realm.write {
                editedPlayer!.jerseyNum = playerNumber!
                editedPlayer!.lineNum = playerLine!
                editedPlayer!.positionType = playerPosition!
                editedPlayer!.activeState = playerActiveSwitch.isOn
            }
            editFieldsButton.tag = 20
        }else if(playerName == "" && playerEditNumberTextField.text! == ""){
           
            try! realm.write {
                editedPlayer!.lineNum = playerLine!
                editedPlayer!.positionType = playerPosition!
                editedPlayer!.activeState = playerActiveSwitch.isOn
            }
            editFieldsButton.tag = 20
        }else{
              editFieldsButton.tag = 10
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case lineNumberPicker:
            return pickerData.count
        default:
            switch selectLine{
            case  1,2,3:
                return forwardPositionData.count
            case 4,5,6:
                return defensePositionData.count
            default :
                return 1
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView == positionTypePicker){
            switch selectLine{
            case  1,2,3:
                return forwardPositionData[row]
            case 4,5,6:
                return defensePositionData[row]
            default :
                return goaliePositionData[row]
            }
        }else {
            return pickerData[row]
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView == lineNumberPicker){
            if(pickerData[row] == "Forward 1"){
                selectLine = 1
                positionTypePicker.reloadAllComponents()
                selectPosition = "LW"
                
            }else if(pickerData[row] == "Forward 2"){
                selectLine = 2
                positionTypePicker.reloadAllComponents()
                selectPosition = "LW"
            }else if(pickerData[row] == "Forward 3"){
                selectLine = 3
                positionTypePicker.reloadAllComponents()
                selectPosition = "LW"
            }else if(pickerData[row] == "Defense 1"){
                selectLine = 4
                positionTypePicker.reloadAllComponents()
                selectPosition = "LD"
            }else if(pickerData[row] == "Defense 2"){
                selectLine = 5
                positionTypePicker.reloadAllComponents()
                selectPosition = "LD"
            }else if(pickerData[row] == "Defense 3"){
                selectLine = 6
                positionTypePicker.reloadAllComponents()
                selectPosition = "LD"
            }else{
                selectLine = 0
                positionTypePicker.reloadAllComponents()
                selectPosition = "G"
            }
        }else {
            switch selectLine{
            case  1,2,3:
                selectPosition = positionCodeData[row]
            case 4,5,6:
                selectPosition = positionCodeData[row + 3]
            default :
                selectPosition = positionCodeData[positionCodeData.count - 1]
            }
        }
        
    
    }
    
    func playerStatsProcessing(){
        
        homePlayerStatsArray.removeAll()
        
        let realm = try! Realm()
        let playerObjc = realm.object(ofType: playerInfoTable.self, forPrimaryKey: passedPlayerID)
    
        // ------------------ player position -----------------------
        let playerPosition = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i", passedPlayerID)).value(forKeyPath: "positionType") as! [String]).compactMap({String($0)})
        homePlayerStatsArray.append("Position: \(playerPosition.first!)")
        // ------------------ player line -----------------------
        let playerLineNum = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i", passedPlayerID)).value(forKeyPath: "lineNum") as! [Int]).compactMap({Int($0)})
        switch playerLineNum[0]{
        case 0:
            homePlayerStatsArray.append("Line Number: G")
        case 1:
            homePlayerStatsArray.append("Line Number: F1")
        case 2:
            homePlayerStatsArray.append("Line Number: F2")
        case 3:
            homePlayerStatsArray.append("Line Number: F3")
        case 4:
            homePlayerStatsArray.append("Line Number: D1")
        case 5:
            homePlayerStatsArray.append("Line Number: D2")
        case 6:
            homePlayerStatsArray.append("Line Number: D3")
        default:
            homePlayerStatsArray.append("Line Number: N/A")
        }
        
        //-------------------- goal count -----------------------
        // get number fos goals from player based oin looping player id
        playerGoalCount = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i", passedPlayerID)).value(forKeyPath: "goalCount") as! [Int]).compactMap({Int($0)})).first
        // if number of goals is not 0 aka the player scorerd atleast once
        // ass goals to player stats if not set as zero
        homePlayerStatsArray.append("Goals: \(playerGoalCount!)")
        // ------------------ assits count -----------------------------
        // get number of assist from player based on looping player id
        playerAssitCount = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i", passedPlayerID)).value(forKeyPath: "assitsCount") as! [Int]).compactMap({Int($0)})).first
        // if number of assits is not 0 aka the player did not get assist atleast once
        //  set assist num to 0
        if (playerAssitCount != 0){
            homePlayerStatsArray.append("Assits: \(String(playerAssitCount!))")
        }else{
            homePlayerStatsArray.append("Assits: 0")
        }
        // ------------------ plus minus count -----------------------------
        // get current looping player's plus minus
        let nextPlayerPlusMinus = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID = %i", passedPlayerID)).value(forKeyPath: "plusMinus") as! [Int]).compactMap({Int($0)}).first
        
        homePlayerStatsArray.append("Overall Plus/Minus: \(String(nextPlayerPlusMinus!))")
        // ------------------ player's line minus count -----------------------------
        // add all plus/minus from all member of the current player ids line for the overall line plus minus
        let nextPlayerLineNum = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID = %i", passedPlayerID)).value(forKeyPath: "lineNum") as! [Int]).compactMap({Int($0)}).first
        
        let allPlayersOnLine = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "lineNum = %i AND TeamID == %@", nextPlayerLineNum!, String(playerObjc!.TeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        var totalPlusMinus: Int = 0
        for i in 0..<allPlayersOnLine.count{
            
            totalPlusMinus = totalPlusMinus + ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID = %i", allPlayersOnLine[i])).value(forKeyPath: "plusMinus") as! [Int]).compactMap({Int($0)})).first!
            
        }
        homePlayerStatsArray.append("Overall Line Plus/Minus: \(String(totalPlusMinus))")
        
        // -------------------- PIM (Penalty in minutes for season against player -----------------------------
        let penaltyMinutesAgainstMinor = ((realm.objects(penaltyTable.self).filter(NSPredicate(format: "playerID == %i AND penaltyType == %@ AND activeState == true", passedPlayerID, "Minor")).value(forKeyPath: "penaltyID") as! [Int]).compactMap({Int($0)})).count
        let penaltyMinutesAgainstMajor = ((realm.objects(penaltyTable.self).filter(NSPredicate(format: "playerID == %i AND penaltyType == %@ AND activeState == true", passedPlayerID, "Major")).value(forKeyPath: "penaltyID") as! [Int]).compactMap({Int($0)})).count
        
        let totalMinutes = (penaltyMinutesAgainstMinor * UserDefaults.standard.integer(forKey: "minorPenaltyLength")) + (penaltyMinutesAgainstMajor * UserDefaults.standard.integer(forKey: "majorPenaltyLength"))
        homePlayerStatsArray.append("PIM: \(String(totalMinutes))")
        // -------------------------------- Faceoff Win % -------------------------------
        let numberOfFaceoffTaken = ((realm.objects(faceOffInfoTable.self).filter(NSPredicate(format: "winingPlayerID == %i OR losingPlayerID == %i AND activeState == true", passedPlayerID,passedPlayerID)).value(forKeyPath: "faceoffID") as! [Int]).compactMap({Int($0)})).count
        let numberOfFaceoffWon = ((realm.objects(faceOffInfoTable.self).filter(NSPredicate(format: "winingPlayerID == %i AND activeState == true", passedPlayerID)).value(forKeyPath: "faceoffID") as! [Int]).compactMap({Int($0)})).count
        
        if (numberOfFaceoffTaken != 0){
            let faceoffWinPerCalc = numberOfFaceoffWon / numberOfFaceoffTaken
            homePlayerStatsArray.append("Faceoff Win Percentage: \(String(faceoffWinPerCalc))%")
        }else{
            homePlayerStatsArray.append("Faceoff Win Percentage: 0%")
        }
        // -------------------------------------------------------------------------------
        
        // -------------------------- GMG Game Wining Goals for the Season ----------------
        for ID in gameIDArray{
            let lastGoalID = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND activeState == true", ID)).value(forKeyPath: "goalPlayerID") as! [Int]).compactMap({String($0)}))
            if (!lastGoalID.isEmpty && lastGoalID.last! != ""){
                lastGoalArray.append(lastGoalID.last!)
            }
        }
        let count = lastGoalArray.filter({ $0.contains(String(passedPlayerID))}).count
        if (count != 0){
            homePlayerStatsArray.append("GMG: " + String(Int(count) / lastGoalArray.count) + "%")
        }else{
            homePlayerStatsArray.append("GMG: 0%")
        }
            

    }
    
    func goalieStatsProcessing(){
        
        goalieStatsArray.removeAll()
        
         let realm = try! Realm()
            let playerObjc = realm.object(ofType: playerInfoTable.self, forPrimaryKey: passedPlayerID)
            
        //----------- goals against avg -------------------------
        let numberOfHomeGames = ((realm.objects(newGameTable.self).filter(NSPredicate(format: "homeTeamID == %i AND activeState == true", playerObjc!.TeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)})).count
        let numberOfAwayGames = ((realm.objects(newGameTable.self).filter(NSPredicate(format: "opposingTeamID == %i AND activeState == true", playerObjc!.TeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)})).count
        let numberOfGoalsAgainst = ((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "goalieID == %i AND activeState == true", passedPlayerID, playerObjc!.TeamID)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)})).count
        
        let dividend: Double = Double(numberOfHomeGames + numberOfAwayGames)
        if dividend != 0.0{
            let GAA:Double = Double(numberOfGoalsAgainst) / dividend
            goalieStatsArray.append("Goals Against Average: \(String(format: "%.2f", GAA))")
        }else{
            goalieStatsArray.append("Goals Against Average: N/A")
        }
        
        
        //-------------- save % overall ------------------
        let homeGoalieShots = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "goalieID == %i AND activeState == true", passedPlayerID)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count
        let homeGoalieGoals = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "goalieID == %i AND activeState == true", passedPlayerID)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count
        print(homeGoalieShots, homeGoalieGoals)
        if (homeGoalieShots != 0 && homeGoalieGoals != 0){
            let homeGoalieTotal:Double = (Double(homeGoalieShots) / Double(homeGoalieGoals + homeGoalieShots))
            goalieStatsArray.append("Overall Save %: \(String(format: "%.2f", homeGoalieTotal))")
        }else{
            goalieStatsArray.append("Overall Save %: N/A")
        }
        // ----------- save % by shot location --------------------
        topLeft = ((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "goalieID == %i AND shotLocation == %i AND activeState == true", passedPlayerID, 1)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)})).count
        topRight = ((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "goalieID == %i AND shotLocation == %i AND activeState == true", passedPlayerID, 2)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)})).count
        bottomLeft = ((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "goalieID == %i AND shotLocation == %i AND activeState == true", passedPlayerID, 3)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)})).count
        bottomRight = ((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "goalieID == %i AND shotLocation == %i AND activeState == true", passedPlayerID, 4)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)})).count
        center = ((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "goalieID == %i AND shotLocation == %i AND activeState == true", passedPlayerID, 5)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)})).count
        
        let totalShot = Double([topLeft, topRight, bottomLeft, bottomRight, center].reduce(0, +))
        
        if (totalShot != 0.0){
            goalieStatsArray.append("Top Left Save %: \(String(format: "%.2f",(Double(topLeft)/totalShot)))")
            goalieStatsArray.append("Top Right Save %: \(String(format: "%.2f",(Double(topRight)/totalShot)))")
            goalieStatsArray.append("Bottom Left Save %: \(String(format: "%.2f", (Double(bottomLeft)/totalShot)))")
            goalieStatsArray.append("Bottom Right Save %: \(String(format: "%.2f",(Double(bottomRight)/totalShot)))")
            goalieStatsArray.append("Five Hole Save %: \(String(format: "%.2f",(Double(center)/totalShot)))")
        }else{
            goalieStatsArray.append("Top Left Save %: N/A")
            goalieStatsArray.append("Top Right Save %: N/A")
            goalieStatsArray.append("Bottom Left Save %: N/A")
            goalieStatsArray.append("Bottom Right Save %: N/A")
            goalieStatsArray.append("Five Hole Save %: N/A")
        }
        
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "homePageRefresh"), object: nil, userInfo: ["key":"value"])
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editFieldsButton(_ sender: UIButton) {
        let realm = try! Realm()
        let editedPlayer = realm.object(ofType: playerInfoTable.self, forPrimaryKey: passedPlayerID);
        // is player label is already hidden reverse the process
        if playerNameLabel.isHidden == true{
            // write new player inffo to realm
            // update UI
            savePlayerInfo()
            succesfulPlayerAdd(playerName: editedPlayer!.playerName)
            isEditingFields(boolType: true)
            onLoad()
            playerInfoTableView.reloadData()
            playerInfoPieChartView.reloadInputViews()
        }else{
    
            isEditingFields(boolType: false)
            if let lineType = (editedPlayer?.lineNum) {
                if String(lineType) != ""{
                    selectLine = lineType
                    if lineType == 0 {
                        lineNumberPicker.selectRow(6, inComponent: 0, animated: true)
                    }else{
                        lineNumberPicker.selectRow(lineType - 1, inComponent: 0, animated: true)
                    }
                }
                positionTypePicker.reloadAllComponents()
            }
            if let positionCode = editedPlayer?.positionType{
                if positionCode != ""{
                    let positionCodeIndex = positionCodeData.firstIndex(of: positionCode)
                    if positionCodeIndex != nil{
                        if positionCodeIndex! >= 0 && positionCodeIndex! <= 2{
                            // forward
                            selectPosition = positionCodeData[positionCodeIndex!]
                            
                            positionTypePicker.selectRow(positionCodeIndex!, inComponent: 0, animated: true)
                        }else if positionCodeIndex! == 3 || positionCodeIndex! == 4{
                            // defense
                             positionTypePicker.selectRow((positionCodeIndex! - 3), inComponent: 0, animated: true)
                        }else{
                            // goalie
                            positionTypePicker.selectRow(0, inComponent: 0, animated: true)
                        }
                    }
                }
            }
        }
        dataWarningLabel.isHidden = true
    }
    
    @objc func playerProfileImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        print("Opening Photo Selection Method")
        mediaTypeSlectionAlert()
        
    }
    
    @IBAction func playerToggleSwitch(_ sender: UISwitch) {
        switchState()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        
        return("Team Stats")
        
    }
    // Returns count of items in tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let realm = try! Realm()
        let playerObjc = realm.object(ofType: playerInfoTable.self, forPrimaryKey: passedPlayerID)
        
        if playerObjc?.positionType == "G"{
            return goalieStatsArray.count
        }else{
            return homePlayerStatsArray.count
        }

        
    }
    //Assign values for tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell:customTeamStatsCell = self.playerInfoTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! customTeamStatsCell
        let realm = try! Realm()
        let playerObjc = realm.object(ofType: playerInfoTable.self, forPrimaryKey: passedPlayerID)
        
        if playerObjc?.positionType == "G"{
                
            switch indexPath.row {
            case 2:
                if UserDefaults.standard.bool(forKey: "userPurchaseConf") == false{
                    cell.player_proStateLogoIMageView.isHidden = false
                    cell.playerStatsLabel!.text = "Save % Top Left:"
                }else{
                    cell.playerStatsLabel!.text = goalieStatsArray[indexPath.row]
                }
                
            case 3:
                if UserDefaults.standard.bool(forKey: "userPurchaseConf") == false{
                    cell.player_proStateLogoIMageView.isHidden = false
                    cell.playerStatsLabel!.text = "Save % Top Right:"
                }else{
                    cell.playerStatsLabel!.text = goalieStatsArray[indexPath.row]
                }
                
            case 4:
                if UserDefaults.standard.bool(forKey: "userPurchaseConf") == false{
                    cell.player_proStateLogoIMageView.isHidden = false
                    cell.playerStatsLabel!.text = "Save % Bottom Left:"
                }else{
                    cell.playerStatsLabel!.text = goalieStatsArray[indexPath.row]
                }
                
            case 5:
                if UserDefaults.standard.bool(forKey: "userPurchaseConf") == false{
                    cell.player_proStateLogoIMageView.isHidden = false
                    cell.playerStatsLabel!.text = "Save % Bottom Right:"
                }else{
                    cell.playerStatsLabel!.text = goalieStatsArray[indexPath.row]
                }
                
            case 6:
                if UserDefaults.standard.bool(forKey: "userPurchaseConf") == false{
                    cell.player_proStateLogoIMageView.isHidden = false
                    cell.playerStatsLabel!.text = "Save % Five Hole:"
                }else{
                    cell.playerStatsLabel!.text = goalieStatsArray[indexPath.row]
                }
                
            default:
                cell.player_proStateLogoIMageView.isHidden = true
                cell.playerStatsLabel!.text = goalieStatsArray[indexPath.row]
            }
       
        }else{
            switch indexPath.row {
            case 4:
                if UserDefaults.standard.bool(forKey: "userPurchaseConf") == false{
                    cell.player_proStateLogoIMageView.isHidden = false
                    cell.playerStatsLabel!.text = "Line Plus / Minus:"
                }else{
                    cell.playerStatsLabel!.text = homePlayerStatsArray[indexPath.row]
                }
            case 6:
                if UserDefaults.standard.bool(forKey: "userPurchaseConf") == false{
                    cell.player_proStateLogoIMageView.isHidden = false
                    cell.playerStatsLabel!.text = "PIM:"
                }else{
                    cell.playerStatsLabel!.text = homePlayerStatsArray[indexPath.row]
                }
                
            case 8:
                if UserDefaults.standard.bool(forKey: "userPurchaseConf") == false{
                    cell.player_proStateLogoIMageView.isHidden = false
                    cell.playerStatsLabel!.text = "GMG:"
                }else{
                    cell.playerStatsLabel!.text = homePlayerStatsArray[indexPath.row]
                }
                
            default:
                cell.player_proStateLogoIMageView.isHidden = true
                cell.playerStatsLabel!.text = homePlayerStatsArray[indexPath.row]
            }
        }
        return cell
    }
    

}

extension Player_About_Popup_View_Controller:  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let realm = try! Realm()
        let playerObjc = realm.object(ofType: playerInfoTable.self, forPrimaryKey: passedPlayerID)
        
        guard let selectedImage = info[.editedImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        imageWriter(fileName: "\((playerObjc?.playerID)!)_ID_\((playerObjc?.playerName)!)_player_logo", imageName: selectedImage)
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
        let playerObjc = realm.object(ofType: playerInfoTable.self, forPrimaryKey: passedPlayerID)
        
        let imageData = imageName.jpegData(compressionQuality: 0.10)
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let tempUrl = dir.appendingPathComponent("PlayerImages")
            let fileURL = tempUrl.appendingPathComponent(fileName)
            
            if let oldLogoURL = playerObjc?.playerLogoURL{
                if oldLogoURL != ""{
                    do{
                        try FileManager.default.removeItem(atPath: (tempUrl.appendingPathComponent(oldLogoURL)).path)
                        do {
                            try imageData!.write(to: fileURL, options: .atomicWrite)
                            // send realm the location of the logo in DD
                            realmLogoRefrence(fileURL: fileName)
                            
                        } catch {
                            print("Player logo write error")
                            fatalErrorAlert("An error has occured while attempting to save your player profile image. Please contact support!")
                        }
                    }catch{
                        print("\(error)")
                        fatalErrorAlert("Unable to remove old profile image, please try again.")
                    }
                }else{
                    do {
                        try imageData!.write(to: fileURL, options: .atomicWrite)
                        // send realm the location of the logo in DD
                        realmLogoRefrence(fileURL: fileName)
                        
                    } catch {
                        print("Player logo write error")
                        fatalErrorAlert("An error has occured while attempting to save your player profile image. Please contact support!")
                    }
                }
            }
            
            
        }
    }
    
    func imageReader(fileName: String) -> UIImage{
        
        var retreivedImage: UIImage!
        
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let URLs = dir.appendingPathComponent("PlayerImages")
            let newURL = URLs.appendingPathComponent(fileName)
            
            do {
                let readData = try Data(contentsOf: newURL)
                retreivedImage = UIImage(data: readData)
                
            } catch {
                print("Player logo read error")
                fatalErrorAlert("An error has occured while attempting to retrieve your player profile image. Please contact support!")
                
            }
        }
        if retreivedImage != nil{
            return(retreivedImage)
        }else{
            return(UIImage(named: "temp_profile_pic_icon")!)
        }
        
    }
}

