//
//  Player Stats View Controller.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-08-19.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

class Locker_Room_Player_Stats_View_Controller: UIViewController, UIPopoverPresentationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var teamActiveStateLabel: UILabel!
    @IBOutlet weak var needProWarningImage: UIImageView!
    @IBOutlet weak var dataWarningTeamLineChart: UILabel!
    @IBOutlet weak var dataWarningTeamPieChart: UILabel!
    @IBOutlet weak var graphsView: UIView!
    @IBOutlet weak var teamStatsLineChart: LineChartView!
    @IBOutlet weak var teamStatsPieChart: PieChartView!
    @IBOutlet weak var playerInfoTableView: UITableView!
    @IBOutlet weak var teamLogoImageView: UIImageView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var seasonNumberLabel: UILabel!
    @IBOutlet weak var teamSeasonRecordLabel: UILabel!
    @IBOutlet weak var teamInfoAreaView: UIView!
    
    var selectedTeamID: Int!
    var gameIDArray: [Int] = [Int]()
    var teamStatsArray: [String] = [String]()
    var homePlayerIDs: [Int] = [Int]()
    var homePlayerNames: [String] = [String]()
    var homePlayerNumber: [Int] = [Int]()
    var homePlayerPosition: [String] = [String]()
    var homePlayerBool: [Bool] = [Bool]()
    
    var homeTeamWinCount: Int!
    var homeTeamTieCount: Int!
    var homeTeamLooseCount: Int!
    
    var teamWinsDataEntry = PieChartDataEntry(value: 0)
    var teamLosesDataEntry = PieChartDataEntry(value: 0)
    var teamTiesDataEntry = PieChartDataEntry(value: 0)
    
    var teamGoalsDataEntry: [ChartDataEntry] = []
    var teamShotsDataEntry: [ChartDataEntry] = []
    
    var pieChartBlurView: UIVisualEffectView!
    var lineChartBlurView: UIVisualEffectView!
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       NotificationCenter.default.addObserver(self, selector: #selector(myMethod(notification:)), name: NSNotification.Name(rawValue: "homePageRefresh"), object: nil)
        
        playerInfoTableView.dataSource = self
        playerInfoTableView.delegate = self
        
        onLoad()
        // Do any additional setup after loading the view.
    }
    
    
    
    func onLoad(){
        
        playerInfoTableView.rowHeight = 125
        
        selectedTeamID =  UserDefaults.standard.integer(forKey: "defaultHomeTeamID")
        
        // add tap gesture to team logo
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(teamLogoTapped(tapGestureRecognizer:)))
        teamInfoAreaView.isUserInteractionEnabled = true
        teamInfoAreaView.addGestureRecognizer(tapGestureRecognizer)
        
        recordLabelProcessing()
        playerNameInfo()
        viewColour()
        teamInfoGrabber()
        
        // charts info functions
        teamPieChartSettings()
        teamPieChartValues()
        teamLineChartValues()
      
    }
    
    func viewColour(){
        
        playerInfoTableView.tableFooterView = UIView()
        
        // set border around team logo and make imag
        roundedCorners().tableViewTopLeftRight(tableviewType: playerInfoTableView)
        teamLogoImageView.heightAnchor.constraint(equalToConstant: teamLogoImageView.frame.height).isActive = true
        teamLogoImageView.setRounded()
        
        playerInfoTableView.backgroundColor = systemColour().tableViewColor()
        
        roundedCorners().uiViewTopLeftRight(labelViewType: graphsView)
        graphsView.backgroundColor = systemColour().tableViewColor()
        
        chartsBlur()
        
    }
    
    func chartsBlur(){
        // give background blur effect
        // add blur effect to chart views
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        
        pieChartBlurView = UIVisualEffectView(effect: blurEffect)
        pieChartBlurView.frame = teamStatsPieChart.bounds
        pieChartBlurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        teamStatsPieChart.addSubview(pieChartBlurView)
        pieChartBlurView.isHidden = true
        
        lineChartBlurView = UIVisualEffectView(effect: blurEffect)
        lineChartBlurView.frame = teamStatsLineChart.bounds
        lineChartBlurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        teamStatsLineChart.addSubview(lineChartBlurView)
        lineChartBlurView.isHidden = true

    }
    
    func teamPieChartSettings(){
     
        let teamRecordCriteria = [teamWinsDataEntry, teamLosesDataEntry, teamTiesDataEntry]
        let chartDataSet = PieChartDataSet(entries: teamRecordCriteria, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        chartDataSet.drawValuesEnabled = false
        // set visual aspect of pie chart iuncluding colours and animations
        let colours = [UIColor.green, UIColor.red, UIColor.blue]
        chartDataSet.colors = colours
        teamStatsPieChart.data = chartData
        teamStatsPieChart.animate(xAxisDuration: 2.0, yAxisDuration:2.0)
        teamStatsPieChart.drawEntryLabelsEnabled = false
        teamStatsPieChart.holeColor = NSUIColor.init(cgColor: UIColor.clear.cgColor)
      
    }
    
    func teamPieChartValues(){
        
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
    
    func teamLineChartValues(){
        
        let realm = try! Realm()
    
        var goal_dataSets: [ChartDataEntry] = [ChartDataEntry]()
        var shot_dataSets: [ChartDataEntry] = [ChartDataEntry]()
        
        var total_dataSets: [LineChartDataSet] = [LineChartDataSet]()
        
        let gameIDs = (realm.objects(newGameTable.self).filter(NSPredicate(format: "activeState == true AND activeGameStatus == false", selectedTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)})
        if UserDefaults.standard.bool(forKey: "userPurchaseConf") == true{
            dataWarningTeamLineChart.isHidden = true
            needProWarningImage.isHidden = true
            if gameIDs.count != 0 {
                for x in 0..<gameIDs.count{
                    
                    let numberOfGoals = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", gameIDs[x], selectedTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)}).count
                    let numberOfShots = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i", gameIDs[x], selectedTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)}).count
                    
                    let goal_dataEntry = ChartDataEntry(x: Double(gameIDs[x]), y: Double(numberOfGoals))
                    let shot_dataEntry = ChartDataEntry(x: Double(gameIDs[x]), y: Double(numberOfShots))
                    
                    teamGoalsDataEntry.append(goal_dataEntry)
                    teamShotsDataEntry.append(shot_dataEntry)
                    
                    let goal_dataSet = ChartDataEntry(x: Double(gameIDs[x]), y: Double(numberOfGoals), data: Double.self)
                    goal_dataSets.append(goal_dataSet)
                    
                    let shot_dataSet = ChartDataEntry(x: Double(gameIDs[x]), y: Double(numberOfShots), data: Double.self)
                    shot_dataSets.append(shot_dataSet)
                    
                }
            }else{
                // run fake data to simualte
                let fakeDataResult = lineChartFakeData()
                goal_dataSets = fakeDataResult.0
                shot_dataSets = fakeDataResult.1
                lineChartBlurView.isHidden = false
                needProWarningImage.isHidden = true
                dataWarningTeamLineChart.isHidden = false
                dataWarningTeamLineChart.text = "InSufficent Data"
            }
        }else{
            print("fake data")
            lineChartBlurView.isHidden = false
            teamStatsLineChart.isHidden = false
            let fakeDataResult = lineChartFakeData()
            goal_dataSets = fakeDataResult.0
            shot_dataSets = fakeDataResult.1
        }
        
        let set1 = LineChartDataSet(entries: goal_dataSets, label: "# of Goals per Game")
        set1.colors = [UIColor.blue]
        let set2 = LineChartDataSet(entries: shot_dataSets, label: "# of Shots per Game")
        set2.colors = [UIColor.green]
        
        total_dataSets.append(set1)
        total_dataSets.append(set2)
        
        let chartData = LineChartData(dataSets: total_dataSets)
        
        teamStatsLineChart.data = chartData
       
        teamStatsLineChart.xAxis.drawGridLinesEnabled = false
        teamStatsLineChart.rightAxis.drawGridLinesEnabled = false
        teamStatsLineChart.animate(xAxisDuration: 2.0, yAxisDuration:2.0)
        teamStatsLineChart.borderColor = UIColor.clear
        teamStatsLineChart.gridBackgroundColor = NSUIColor.clear
    }
    
    func lineChartFakeData() -> ([ChartDataEntry], [ChartDataEntry]){
        
        var goal_dataSets: [ChartDataEntry] = [ChartDataEntry]()
        var shot_dataSets: [ChartDataEntry] = [ChartDataEntry]()
        
        let tempGameIDs = Array(0...7)
        print(tempGameIDs)
        for x in 0..<tempGameIDs.count{
            let numberOfGoals = Int.random(in: 0..<6)
            print(numberOfGoals)
            let numberOfShots = Int.random(in: 0..<15)
            
            let goal_dataEntry = ChartDataEntry(x: Double(tempGameIDs[x]), y: Double(numberOfGoals))
            let shot_dataEntry = ChartDataEntry(x: Double(tempGameIDs[x]), y: Double(numberOfShots))
            
            teamGoalsDataEntry.append(goal_dataEntry)
            teamShotsDataEntry.append(shot_dataEntry)
            
            let goal_dataSet = ChartDataEntry(x: Double(tempGameIDs[x]), y: Double(numberOfGoals), data: Double.self)
            goal_dataSets.append(goal_dataSet)
            
            let shot_dataSet = ChartDataEntry(x: Double(tempGameIDs[x]), y: Double(numberOfShots), data: Double.self)
            shot_dataSets.append(shot_dataSet)
        }
        return (goal_dataSets, shot_dataSets)
    }
    
    func teamInfoGrabber(){
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
                teamLogoImageView.image = readerResult
            }else{
                teamLogoImageView.image = UIImage(named: "temp_profile_pic_icon")
            }
        }
        
        if let teamActiveState = teamObjc?.activeState{
            if teamActiveState != true{
                teamActiveStateLabel.isHidden = false
            }else{
                teamActiveStateLabel.isHidden = true
            }
        }
        
    }
    
    func recordLabelProcessing(){
        
        let realm = try! Realm()
    
        homeTeamWinCount = (realm.objects(newGameTable.self).filter(NSPredicate(format: "tieGameBool == false AND winingTeamID == %i AND activeState == true AND activeGameStatus == false", selectedTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)}).count
        homeTeamTieCount =  (realm.objects(newGameTable.self).filter(NSPredicate(format: "tieGameBool == true AND homeTeamID == %i AND activeState == true AND activeGameStatus == false", selectedTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)}).count
        homeTeamLooseCount =  (realm.objects(newGameTable.self).filter(NSPredicate(format: "tieGameBool == false AND losingTeamID == %i AND activeState == true AND activeGameStatus == false", selectedTeamID)).value(forKeyPath: "gameID") as! [Int]).compactMap({Int($0)}).count
        
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
    
    func openPlayerAbout(playerID: Int){
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let popupVC = storyboard.instantiateViewController(withIdentifier: "Player_About_Popup_View_Controller") as! Player_About_Popup_View_Controller
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = .crossDissolve
        let pVC = popupVC.popoverPresentationController
        pVC?.permittedArrowDirections = .any
        pVC?.delegate = self
        
        
        popupVC.passedPlayerID = playerID
        
        present(popupVC, animated: true, completion: nil)
        print("Team About Presented!")
    }
    
    func imageReader(fileName: String) -> UIImage{
        
        var retreivedImage: UIImage!
        
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let URLs = dir.appendingPathComponent("TeamLogo")
            let newURL = URLs.appendingPathComponent(fileName)
            
            do {
                let readData = try Data(contentsOf: newURL)
                retreivedImage = UIImage(data: readData)
                print("imag")
            } catch {
                print("Team logo read error")
               
            }
        }
        if retreivedImage != nil{
            return(retreivedImage)
        }else{
            print("hi")
            return(UIImage(named: "temp_profile_pic_icon")!)
        }
    }
    
    func playerImageReader(fileName: String) -> UIImage{
        
        var retreivedImage: UIImage!
        
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let URLs = dir.appendingPathComponent("PlayerImages")
            let newURL = URLs.appendingPathComponent(fileName)
            
            do {
                let readData = try Data(contentsOf: newURL)
                retreivedImage = UIImage(data: readData)
                
            } catch {
                print("Player logo read error")
            }
        }
        if retreivedImage != nil{
            return(retreivedImage)
        }else{
            
            return(UIImage(named: "temp_profile_pic_icon")!)
        }
    }
    
    func fatalErrorAlert(_ msg: String){
        
        let errorAlert = UIAlertController(title: localizedString().localized(value:"Whoops!"), message: localizedString().localized(value:"\(msg)"), preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(errorAlert, animated: true, completion: nil)
        
    }
    
    func playerNameInfo(){
        
        let realm = try! Realm()
        
        homePlayerIDs = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@", String(selectedTeamID))).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)})
        homePlayerBool = (realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@", String(selectedTeamID))).value(forKeyPath: "activeState") as! [Bool]).compactMap({Bool($0)})
        
        if (homePlayerIDs.isEmpty != true){
            for x in 0..<homePlayerIDs.count{
                
                let queryPlayerName = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %ie", homePlayerIDs[x])).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)})).first
                let queryPlayerNumber = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i", homePlayerIDs[x])).value(forKeyPath: "jerseyNum") as! [Int]).compactMap({Int($0)})).first
                let queryPlayerPosition = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i", homePlayerIDs[x])).value(forKeyPath: "positionType") as! [String]).compactMap({String($0)})).first
                
                homePlayerNames.append(queryPlayerName!)
                homePlayerNumber.append(queryPlayerNumber!)
                homePlayerPosition.append(playerPositionConverter().realmInpuToString(rawInput: queryPlayerPosition!))
            }
        }else{
           // homePlayerNames[0] = "No Players Found"
            
        }
        
    }
    

    
    
    @objc func myMethod(notification: NSNotification){
        homePlayerNames.removeAll()
        homePlayerIDs.removeAll()
        homePlayerNumber.removeAll()
        homePlayerPosition.removeAll()
        homePlayerBool.removeAll()
        
        selectedTeamID =  UserDefaults.standard.integer(forKey: "defaultHomeTeamID")
        
        playerNameInfo()
        teamInfoGrabber()
        teamPieChartSettings()
        teamPieChartValues()
        teamLineChartValues()
       
        DispatchQueue.main.async {
            self.playerInfoTableView.reloadData()
            self.teamStatsPieChart.reloadInputViews()
            self.teamStatsLineChart.reloadInputViews()
        }
        
    }
    
    
    @objc func teamLogoTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        print("Opening Home Team About")
        openTeamAbout()
        
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        if (tableView == playerInfoTableView){
            
            return("Player Profiles")
        }
         return("Player Profiles")
    }
    // Returns count of items in tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableView == playerInfoTableView){
            return(homePlayerIDs.count)
        }
         return(homePlayerIDs.count)
    }
    //Assign values for tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell:customLockerRoomStatsCell = self.playerInfoTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! customLockerRoomStatsCell
        
       if (tableView == playerInfoTableView){
        
            let realm = try! Realm()
        
            let playerObjc = realm.object(ofType: playerInfoTable.self, forPrimaryKey: homePlayerIDs[indexPath.row])
        
            cell.playerNameLabel!.text = homePlayerNames[indexPath.row]
            cell.playerPositionLabel?.text = homePlayerPosition[indexPath.row]
            cell.playerNumberLabel?.text = " #\(homePlayerNumber[indexPath.row])"
            
            if homePlayerBool[indexPath.row] == false{
                cell.deletedPlayerIcon.isHidden = false
            }else{
                cell.deletedPlayerIcon.isHidden = true
            }
           //cell.playerProfileImage.layer.masksToBounds = true
            let readerResult = playerImageReader(fileName: (playerObjc?.playerLogoURL)!)
            if readerResult.images?.first != UIImage(named: "temp_profile_pic_icon"){
                cell.playerProfileImage.image = readerResult
               
            }else{
                cell.playerProfileImage.image = UIImage(named: "temp_profile_pic_icon")
            }
        
        
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        openPlayerAbout(playerID: homePlayerIDs[indexPath.row])
    }
    

}

extension UIImageView {
    
    func setRounded() {
       
        self.layer.borderWidth = 3
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = CGFloat(roundf(Float(self.frame.size.width / 2.0)))
    }
}
