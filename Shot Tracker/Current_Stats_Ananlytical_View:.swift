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
    
    var homeTeam: Int!
    var awayTeam: Int!
    var teamIDArray: [String] = [String]()
    var newGameStarted: Bool!
    var goalieSelectedID: Int!
    var periodNumSelected: Int!
    var homeGoalieID: Int!
    var awayGoalieID: Int!
    
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
        homeGoalieID = goalieSelectedID
        awayGoalieID = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType == %@ AND activeState == true", String(homeTeam), "G")).value(forKeyPath: "playerID") as! [Int]).compactMap({Int($0)}))[0]
        
        popUpView.layer.cornerRadius = 10
        teamNameInitialize()
        
        // call functions for stats page dynamic function
        if (realm.objects(newGameTable.self).filter("gameID >= 0").last != nil && realm.objects(goalMarkersTable.self).filter("cordSetID >= 0").last != nil){
            scoreInitialize()
            homeAwayGoalieProcessing()
            print("Succesfully Rendered Current Goal Stats")
        }else{
            print("Current Goal Stats Defaulted to 0")
        }
        if(realm.objects(newGameTable.self).filter("gameID >= 0").last != nil && realm.objects(shotMarkerTable.self).filter("cordSetID >= 0").last != nil){
            numShotInitialize()
            goalieSavePercent()
            homeAwayGoalieProcessing()
            print("Succesfully Rendered Current Shot Stats")
        }else{
            print("Current Shot Stats Defaulted to 0")
            
            homeTeamGoalie.value = 0
            awayTeamGoalie.value = 0
            tlShotValue.value = 0
            trShotValue.value = 0
            blShotValue.value = 0
            brShotValue.value = 0
            cShotValue.value = 0
        }
        
        pieChartSettings()
        shotLocationPieChartSettings()
        labelChecker()
        
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
        // query realm for number of specified shots on said location
        let tl_homeGoalieShotLocation = Double((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND shotLocation == %i AND activeState == true", ((realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)!), 1)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
        let tr_homeGoalieShotLocation = Double((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND shotLocation == %i AND TeamID == %i AND activeState == true", ((realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)!), 2, awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
        let bl_homeGoalieShotLocation = Double((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND shotLocation == %i AND TeamID == %i AND activeState == true", ((realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)!), 3, awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
        let br_homeGoalieShotLocation = Double((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND shotLocation == %i AND TeamID == %i AND activeState == true", ((realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)!), 4, awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
        let c_homeGoalieShotLocation = Double((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND shotLocation == %i AND TeamID == %i AND activeState == true", ((realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)!), 5, awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
        //print(c_homeGoalieShotLocation)
        
        var overalShotTotal:Double = tl_homeGoalieShotLocation + tr_homeGoalieShotLocation + bl_homeGoalieShotLocation + br_homeGoalieShotLocation + c_homeGoalieShotLocation
        
        if (tl_homeGoalieShotLocation != 0.0){
            tlShotValue.value = (overalShotTotal/tl_homeGoalieShotLocation) * 1.00
        }else{
            tlShotValue.value = 0.0
        }
        if (tr_homeGoalieShotLocation != 0.0){
            trShotValue.value = (overalShotTotal/tr_homeGoalieShotLocation) * 1.00
        }else{
            trShotValue.value = 0.0
        }
        if (bl_homeGoalieShotLocation != 0.0){
            blShotValue.value = (overalShotTotal/bl_homeGoalieShotLocation) * 1.00
        }else{
            blShotValue.value = 0.0
        }
        if (br_homeGoalieShotLocation != 0.0){
            brShotValue.value = (overalShotTotal/br_homeGoalieShotLocation) * 1.00
        }else{
            brShotValue.value = 0.0
        }
        if (c_homeGoalieShotLocation != 0.0){
            cShotValue.value = (overalShotTotal/c_homeGoalieShotLocation)  * 1.00
        }else{
            cShotValue.value = 0.0
        }
    
    }
    
    func homeAwayGoalieProcessing(){
        
        let homeGoalieShots = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND goalieID == %i AND activeState == true",((realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)!), homeGoalieID)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        let homeGoalieGoals = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND goalieID == %i AND activeState == true",((realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)!), homeGoalieID)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        
        let awayGoalieShots = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND goalieID == %i AND activeState == true",((realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)!), awayGoalieID)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        let awayGoalieGoals = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND goalieID == %i AND activeState == true",((realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)!), awayGoalieID)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        
        var homeGoalieTotal:Double = (Double(homeGoalieShots) / (Double(homeGoalieGoals) + Double(homeGoalieShots)))
        var awayGoalieTotal:Double = (Double(awayGoalieShots) / (Double(awayGoalieGoals) + Double(awayGoalieShots)))
  
        if(homeGoalieTotal != 0){
            homeTeamGoalie.value = (homeGoalieTotal / (homeGoalieTotal + awayGoalieTotal)) * 100.00
        }else{
            homeTeamGoalie.value = 0
        }
        if(awayGoalieTotal != 0){
            awayTeamGoalie.value = (awayGoalieTotal / (homeGoalieTotal + awayGoalieTotal)) * 100.00
        }else{
            awayTeamGoalie.value = 0
        }
    }
    
    func teamNameInitialize(){
      
        let homeGoalieNameString = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "playerID == %i AND activeState == true", goalieSelectedID)).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)}))[0]
        let awayGoalieNameString = ((realm.objects(playerInfoTable.self).filter(NSPredicate(format: "TeamID == %@ AND positionType == %@ AND activeState == true", String(awayTeam), "G")).value(forKeyPath: "playerName") as! [String]).compactMap({String($0)}))[0]
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
    
    func scoreInitialize() -> (Double, Double){
        
        // query realm for goal count based on newest gam
        let gameID = realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)
        let homeScoreFilter = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND activeState == true", (gameID?.gameID)!, homeTeam!)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        
        let awayScoreFilter = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND activeState == true", (gameID?.gameID)!, awayTeam!)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        
        return(Double(homeScoreFilter), Double(awayScoreFilter))
    }
    
    func numShotInitialize() -> (Double, Double){
        
        let newGameFilter = realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?);
        // get homeTeam and away team ID's fom said lastest new game entry
        homeTeam = newGameFilter?.homeTeamID
        awayTeam = newGameFilter?.opposingTeamID
        //get array of team ID's and concert to regular string array from optional
        let homeShotCounter = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND activeState == true", (newGameFilter?.gameID)!, homeTeam!)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        
        let awayShotCounter = (realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND activeState == true", (newGameFilter?.gameID)!, awayTeam!)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        
        return(Double(homeShotCounter), Double(awayShotCounter))
        
    }
    // func used to pass varables on segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check is appropriate segue is being used
        if (segue.identifier == "closeAnalyticalViewSegue"){
            // set var vc as destination segue
            let currentStats = segue.destination as! Current_Stats_Page
            currentStats.newGameStarted = false
            currentStats.homeTeam = homeTeam
            currentStats.awayTeam = awayTeam
            currentStats.goalieSelectedID = goalieSelectedID
            currentStats.periodNumSelected = periodNumSelected
        }
        
    }
    
}

