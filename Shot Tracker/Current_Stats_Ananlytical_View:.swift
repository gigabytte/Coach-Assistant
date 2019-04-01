//
//  Current Stats Ananlytical View.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-03-11.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import Charts


class Current_Stats_Ananlytical_View: UIViewController {
    
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var shotLocationPieChartView: PieChartView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var savePerDataMissingLabel: UILabel!
    @IBOutlet weak var savePerShotDataMissingLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var oneHundredPerNote: UILabel!
    
    var homeTeam: Int!
    var awayTeam: Int!
    var teamIDArray: [String] = [String]()
    var newGameStarted: Bool!
    var fixedGoalieID: Int!
    var periodNumSelected: Int!
    var homeGoalieID: Int!
    var awayGoalieID: Int!
    var oldStatsPopUpBool: Bool!
    var SeletedGame: Int!
    var gameID: Int!
    
    var homeTeamGoalie = PieChartDataEntry(value: 0)
    var awayTeamGoalie = PieChartDataEntry(value: 0)
    
    var tlShotValue = PieChartDataEntry(value: 0)
    var trShotValue = PieChartDataEntry(value: 0)
    var blShotValue = PieChartDataEntry(value: 0)
    var brShotValue = PieChartDataEntry(value: 0)
    var cShotValue = PieChartDataEntry(value: 0)
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // if accesss from current game setting
        if(oldStatsPopUpBool != true){
            homeGoalieID = fixedGoalieID
            awayGoalieID = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType == %@ AND activeState == true", String(awayTeam), "G")).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)}))[0]
            gameID = (realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)
        }else{
            // if accesse from old stats
            gameID = SeletedGame
            homeTeam = (realm.objects(newGameTable.self).filter(NSPredicate(format: "gameID == %i AND activeState == true", gameID)).value(forKeyPath: "homeTeamID") as! [Int]).compactMap({Int($0)})[0]
            awayTeam = (realm.objects(newGameTable.self).filter(NSPredicate(format: "gameID == %i AND activeState == true", gameID)).value(forKeyPath: "opposingTeamID") as! [Int]).compactMap({Int($0)})[0]
            homeGoalieID = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND positionType == %@ AND activeState == true", fixedGoalieID, "G")).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)}))[0]
            awayGoalieID = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType == %@ AND activeState == true", String(awayTeam), "G")).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)}))[0]
            
            
        }
        oneHundredPerNote.isHidden = true
        savePerDataMissingLabel.isHidden = false
        popUpView.layer.cornerRadius = 10
        bottomRoundedCorners()
        teamNameInitialize()
        
        // call functions for stats page dynamic function
        if (realm.objects(newGameTable.self).filter("gameID >= 0").last != nil && realm.objects(goalMarkersTable.self).filter("cordSetID >= 0").last != nil){
            
            homeAwayGoalieProcessing()
            
            print("Succesfully Rendered Current Goal Stats")
        }else{
            print("Current Goal Stats Defaulted to 0")
        }
        if(realm.objects(newGameTable.self).filter("gameID >= 0").last != nil && realm.objects(shotMarkerTable.self).filter("cordSetID >= 0").last != nil){
           
            homeAwayGoalieProcessing()
            print("Succesfully Rendered Current Shot Stats")
        }else{
            print("Current Shot Stats Defaulted to 0")
            
        }
        goalieSavePercent()
        pieChartSettings()
        shotLocationPieChartSettings()
        labelChecker()
        dataUnavailableWarning()
    }
    
    func dataUnavailableWarning(){
        // display place holder message if data missing for pie charts
        // ran on page load
        if (tlShotValue.value == 0.0 && trShotValue.value == 0.0 && blShotValue.value == 0.0 && brShotValue.value == 0.0 && cShotValue.value == 0.0){
            savePerShotDataMissingLabel.isHidden = false
            
        }else{
            savePerShotDataMissingLabel.isHidden = true
        }
        
    }
    
    func bottomRoundedCorners(){
        
        // round bottom corners of button
        let path = UIBezierPath(roundedRect:closeButton.bounds, byRoundingCorners:[.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 10, height: 10))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        closeButton.layer.mask = maskLayer
    }
    
    func pieChartSettings(){
        let numberOfShots = [homeTeamGoalie, awayTeamGoalie]
        let chartDataSet = PieChartDataSet(values: numberOfShots, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        let colours = [UIColor.green, UIColor.blue, UIColor.red, UIColor.purple]
        chartDataSet.colors = colours as! [NSUIColor]
        pieChartView.data = chartData
        pieChartView.animate(xAxisDuration: 2.0, yAxisDuration:2.0)
        
    }

    func labelChecker(){
        
        if (tlShotValue.value == 0.0){
            tlShotValue.label = nil
        }
        if (trShotValue.value == 0.0){
            trShotValue.label = nil
        }
        if (blShotValue.value == 0.0){
            blShotValue.label = nil
        }
        if (brShotValue.value == 0.0){
            brShotValue.label = nil
        }
        if (cShotValue.value == 0.0){
            cShotValue.label = nil
        }
    }
    
    func shotLocationPieChartSettings(){
        let numberOfShots = [tlShotValue, trShotValue, blShotValue, brShotValue, cShotValue]
        let chartDataSet = PieChartDataSet(values: numberOfShots, label: nil)
        
        let chartData = PieChartData(dataSet: chartDataSet)
        let colours = [UIColor.green, UIColor.blue, UIColor.red, UIColor.purple, UIColor.orange, UIColor.yellow]
        chartDataSet.colors = colours as! [NSUIColor]
        shotLocationPieChartView.data = chartData
        shotLocationPieChartView.animate(xAxisDuration: 2.0, yAxisDuration:2.0)
        
    }
    
    func goalieSavePercent() {
        // ----------- save % by shot location --------------------
        // query realm for number of specified shots on said location
        let tl_homeGoalieShotLocation = Double((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND shotLocation == %i AND activeState == true", gameID, 1)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
        let tr_homeGoalieShotLocation = Double((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND shotLocation == %i AND TeamID == %i AND activeState == true", gameID, 2, awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
        let bl_homeGoalieShotLocation = Double((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND shotLocation == %i AND TeamID == %i AND activeState == true", gameID, 3, awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
        let br_homeGoalieShotLocation = Double((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND shotLocation == %i AND TeamID == %i AND activeState == true", gameID, 4, awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
        let c_homeGoalieShotLocation = Double((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND shotLocation == %i AND TeamID == %i AND activeState == true", gameID, 5, awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
        //print(c_homeGoalieShotLocation)
        
        var overalShotTotal:Double = tl_homeGoalieShotLocation + tr_homeGoalieShotLocation + bl_homeGoalieShotLocation + br_homeGoalieShotLocation + c_homeGoalieShotLocation
        
        if (tl_homeGoalieShotLocation != 0.0){
            tlShotValue.value = (tl_homeGoalieShotLocation/overalShotTotal) * 1.00
        }else{
            tlShotValue.value = 0.0
        }
        if (tr_homeGoalieShotLocation != 0.0){
            trShotValue.value = (tr_homeGoalieShotLocation/overalShotTotal) * 1.00
        }else{
            trShotValue.value = 0.0
        }
        if (bl_homeGoalieShotLocation != 0.0){
            blShotValue.value = (bl_homeGoalieShotLocation/overalShotTotal) * 1.00
        }else{
            blShotValue.value = 0.0
        }
        if (br_homeGoalieShotLocation != 0.0){
            brShotValue.value = (br_homeGoalieShotLocation/overalShotTotal) * 1.00
        }else{
            brShotValue.value = 0.0
        }
        if (c_homeGoalieShotLocation != 0.0){
            cShotValue.value = (c_homeGoalieShotLocation/overalShotTotal)  * 1.00
        }else{
            cShotValue.value = 0.0
        }
    
    }
    
    func homeAwayGoalieProcessing(){
        // ---------------- save % overall ------------------
        let homeGoalieShots = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND goalieID == %i AND activeState == true",gameID, homeGoalieID)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        let homeGoalieGoals = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND goalieID == %i AND activeState == true",gameID, homeGoalieID)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        
        let awayGoalieShots = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND goalieID == %i AND activeState == true",gameID, awayGoalieID)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        let awayGoalieGoals = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND goalieID == %i AND activeState == true",gameID, awayGoalieID)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        
        var homeGoalieTotal:Double = (Double(homeGoalieShots) / (Double(homeGoalieGoals) + Double(homeGoalieShots)))
        var awayGoalieTotal:Double = (Double(awayGoalieShots) / (Double(awayGoalieGoals) + Double(awayGoalieShots)))
       
        if(homeGoalieTotal > 0.0 && awayGoalieTotal > 0.0){
            let homeGoalieValue = (awayGoalieTotal / (homeGoalieTotal + awayGoalieTotal)) * 100.00
            let awayGoalieValue = (homeGoalieTotal / (homeGoalieTotal + awayGoalieTotal)) * 100.00
            print(homeGoalieValue, awayGoalieValue)
            if (homeGoalieValue == 50.0 && awayGoalieValue == 50.0){
                awayTeamGoalie.value = homeGoalieValue
                homeTeamGoalie.value = awayGoalieValue
                savePerDataMissingLabel.isHidden = true
                oneHundredPerNote.isHidden = false
            }else{
                self.awayTeamGoalie.value = awayGoalieValue
                self.homeTeamGoalie.value = homeGoalieValue
                self.savePerDataMissingLabel.isHidden = true
                oneHundredPerNote.isHidden = true
            }
            
        }else{
            homeTeamGoalie.value = 0.0
            savePerDataMissingLabel.isHidden = false
            oneHundredPerNote.isHidden = true
        }
       
    }
    
    func teamNameInitialize(){
      
        let homeGoalieNameString = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", homeGoalieID)).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)}))[0]
        let awayGoalieNameString = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", awayGoalieID)).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)}))[0]
        let homeGoalieNum = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", homeGoalieID)).value(forKeyPath: "jerseyNum") as! [Int]).compactMap({String($0)}))[0]
        let awayGoalieNum = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", awayGoalieID)).value(forKeyPath: "jerseyNum") as! [Int]).compactMap({String($0)}))[0]
        homeTeamGoalie.label = "\(homeGoalieNameString) #\(homeGoalieNum)"
        awayTeamGoalie.label = "\(awayGoalieNameString) #\(awayGoalieNum)"
        
        tlShotValue.label = "Top Left"
        trShotValue.label = "Top Right"
        blShotValue.label = "Bottom Left"
        brShotValue.label = "Bottom Right"
        cShotValue.label = "Five Hole"
    }
    
    
    @IBAction func closeButton(_ sender: UIButton) {
        
        if (oldStatsPopUpBool != true){
            
            self.performSegue(withIdentifier: "cancelCurrentSats", sender: nil);
        }else{
            
            self.performSegue(withIdentifier: "cancelOldStats", sender: nil);
        }
        
    }
    // func used to pass varables on segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check is appropriate segue is being used
        if (segue.identifier == "cancelCurrentSats"){
            // set var vc as destination segue
            let currentStats = segue.destination as! Current_Stats_Page
            currentStats.newGameStarted = false
            currentStats.homeTeam = homeTeam
            currentStats.awayTeam = awayTeam
            currentStats.fixedGoalieID = homeGoalieID
            currentStats.periodNumSelected = periodNumSelected
        }
        if (segue.identifier == "cancelOldStats"){
            // set var vc as destination segue
            let currentStats = segue.destination as! Old_Game_Ice_View
            currentStats.SeletedGame = SeletedGame
            currentStats.goalieSelectedID = fixedGoalieID
            
        }
        
    }
    
}

