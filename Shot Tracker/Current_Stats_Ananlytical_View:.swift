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
    
    var homeTeamShotsPie = PieChartDataEntry(value: 0)
    var homeTeamGoalsPie = PieChartDataEntry(value: 0)
    var awayTeamShotsPie = PieChartDataEntry(value: 0)
    var awayTeamGoalsPie = PieChartDataEntry(value: 0)
    
    var tlShotValue = PieChartDataEntry(value: 0)
    var trShotValue = PieChartDataEntry(value: 0)
    var blShotValue = PieChartDataEntry(value: 0)
    var brShotValue = PieChartDataEntry(value: 0)
    var cShotValue = PieChartDataEntry(value: 0)
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popUpView.layer.cornerRadius = 10
        teamNameInitialize()
        
        // call functions for stats page dynamic function
        if (realm.objects(newGameTable.self).filter("gameID >= 0").last != nil && realm.objects(goalMarkersTable.self).filter("cordSetID >= 0").last != nil){
            scoreInitialize()
            goal_dataInitilier()
            goalLocationProcessing()
            print("Succesfully Rendered Current Goal Stats")
        }else{
            print("Current Goal Stats Defaulted to 0")
        }
        if(realm.objects(newGameTable.self).filter("gameID >= 0").last != nil && realm.objects(shotMarkerTable.self).filter("cordSetID >= 0").last != nil){
            numShotInitialize()
            shot_dataInitilier()
            shotLocationProcessing()
            print("Succesfully Rendered Current Shot Stats")
        }else{
            print("Current Shot Stats Defaulted to 0")
            
            homeTeamShotsPie.value = 0
            awayTeamShotsPie.value = 0
            homeTeamGoalsPie.value = 0
            awayTeamGoalsPie.value = 0
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
        let numberOfShots = [homeTeamGoalsPie, awayTeamGoalsPie, homeTeamShotsPie, awayTeamShotsPie]
        let chartDataSet = PieChartDataSet(values: numberOfShots, label: nil)
        let chartData = PieChartData(dataSet: chartDataSet)
        let colours = [UIColor.green, UIColor.blue, UIColor.red, UIColor.purple]
        chartDataSet.colors = colours as! [NSUIColor]
        pieChartView.data = chartData
        pieChartView.animate(xAxisDuration: 2.0, yAxisDuration:2.0)
        
    }
    
    func shot_dataInitilier(){
        
        homeTeamShotsPie.value = numShotInitialize().0
        awayTeamShotsPie.value = numShotInitialize().1
        
    }
    
    func goal_dataInitilier(){
        
        homeTeamGoalsPie.value = scoreInitialize().0
        awayTeamGoalsPie.value = scoreInitialize().1
        
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
        if(homeTeamShotsPie.value == 0.0){
            homeTeamShotsPie.label = nil
        }
        if(homeTeamGoalsPie.value == 0.0){
            homeTeamGoalsPie.label = nil
        }
        if(awayTeamShotsPie.value == 0.0){
            awayTeamShotsPie.label = nil
        }
        if(awayTeamGoalsPie.value == 0.0){
            awayTeamGoalsPie.label = nil
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
    
    func shotLocationProcessing() {
        // query realm for number of specified shots on said location
        let tl_homeGoalieShotLocation = Double((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND shotLocation == %i AND activeState == true", ((realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)!), 1)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
        let tr_homeGoalieShotLocation = Double((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND shotLocation == %i AND TeamID == %i AND activeState == true", ((realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)!), 2, awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
        let bl_homeGoalieShotLocation = Double((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND shotLocation == %i AND TeamID == %i AND activeState == true", ((realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)!), 3, awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
        let br_homeGoalieShotLocation = Double((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND shotLocation == %i AND TeamID == %i AND activeState == true", ((realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)!), 4, awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
        let c_homeGoalieShotLocation = Double((realm.objects(shotMarkerTable.self).filter(NSPredicate(format: "gameID == %i AND shotLocation == %i AND TeamID == %i AND activeState == true", ((realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)!), 5, awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
        print(c_homeGoalieShotLocation)
        
        tlShotValue.value += tl_homeGoalieShotLocation
        trShotValue.value += tr_homeGoalieShotLocation
        blShotValue.value += bl_homeGoalieShotLocation
        brShotValue.value += br_homeGoalieShotLocation
        cShotValue.value += c_homeGoalieShotLocation
        
    }
    
    func goalLocationProcessing(){
        // query realm for number of specified shots on said location
        let tl_homeGoalieGoalLocation = Double((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND shotLocation == %i AND TeamID == %i AND activeState == true", ((realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)!), 1, awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
        let tr_homeGoalieGoalLocation = Double((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND shotLocation == %i AND TeamID == %i AND activeState == true", ((realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)!), 2, awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
        let bl_homeGoalieGoalLocation = Double((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND shotLocation == %i AND TeamID == %i AND activeState == true", ((realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)!), 3, awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
        let br_homeGoalieGoalLocation = Double((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND shotLocation == %i AND TeamID == %i AND activeState == true", ((realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)!), 4, awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
        let c_homeGoalieGoalLocation = Double((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND shotLocation == %i AND TeamID == %i AND activeState == true", ((realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)!), 5, awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
        
        tlShotValue.value += tl_homeGoalieGoalLocation
        trShotValue.value += tr_homeGoalieGoalLocation
        blShotValue.value += bl_homeGoalieGoalLocation
        brShotValue.value += br_homeGoalieGoalLocation
        cShotValue.value += c_homeGoalieGoalLocation
        
        
    }
    
    func teamNameInitialize(){
        
        // query realm for team naames based on newest game
        let homeTeamNameString = realm.object(ofType: teamInfoTable.self, forPrimaryKey: realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.homeTeamID)!
        let awayTeamNameString = realm.object(ofType: teamInfoTable.self, forPrimaryKey: realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.opposingTeamID)!
        
        homeTeamGoalsPie.label = "\(homeTeamNameString.nameOfTeam) Goals"
        homeTeamShotsPie.label = "\(homeTeamNameString.nameOfTeam) Shots"
        awayTeamGoalsPie.label = "\(awayTeamNameString.nameOfTeam) Goals"
        awayTeamShotsPie.label = "\(awayTeamNameString.nameOfTeam) Shots"
        
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
        
        homeTeamGoalsPie.value = Double(homeScoreFilter)
        awayTeamGoalsPie.value = Double(awayScoreFilter)
        
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
        
        homeTeamShotsPie.value = Double(homeShotCounter)
        awayTeamShotsPie.value = Double(awayShotCounter)
        
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

