//
//  Current_Stats_Page.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-02-05.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import Charts

class Current_Stats_Page: UIViewController {

    @IBOutlet weak var homeTeamNameTextField: UILabel!
    @IBOutlet weak var awayTeamNameTextField: UILabel!
    @IBOutlet weak var homeTeamScoreTextField: UILabel!
    @IBOutlet weak var awayTeamScoreTextField: UILabel!
    @IBOutlet weak var homeNumShotTextField: UILabel!
    @IBOutlet weak var awayNumShotTextField: UILabel!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var radarChartView: RadarChartView!
    
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
    
    var tlShotValue = RadarChartDataEntry(value: 0)
    var trShotValue = RadarChartDataEntry(value: 0)
    var blShotValue = RadarChartDataEntry(value: 0)
    var brShotValue = RadarChartDataEntry(value: 0)
    var cShotValue = RadarChartDataEntry(value: 0)
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Away team ID", awayTeam)
        teamNameInitialize()
    
        // call functions for stats page dynamic function
        if (realm.objects(newGameTable.self).filter("gameID >= 0").last != nil && realm.objects(goalMarkersTable.self).filter("cordSetID >= 0").last != nil){
            scoreInitialize()
            //goalLocationProcessing()
            goal_dataInitilier()
            //radarDataGoal()
            print("Succesfully Rendered Current Goal Stats")
        }else{
            // align text in text field as well assign text value to text field to team name
            homeTeamScoreTextField.text = String(0)
            homeTeamScoreTextField.textAlignment = .center
            awayTeamScoreTextField.text = String(0)
            awayTeamScoreTextField.textAlignment = .center
            print("Current Goal Stats Defaulted to 0")
        }
        if(realm.objects(newGameTable.self).filter("gameID >= 0").last != nil && realm.objects(shotMarkerTable.self).filter("cordSetID >= 0").last != nil){
            numShotInitialize()
            shotLocationProcessing()
            shot_dataInitilier()
            //radarDataShot()
            print("Succesfully Rendered Current Shot Stats")
        }else{
            // align text to center and assigned text field the value of homeScoreFilter query
            homeNumShotTextField.text = "Number of Shots: " + String(0)
            homeNumShotTextField.textAlignment = .center
            awayNumShotTextField.text = "Number of Shots: " + String(0)
            awayNumShotTextField.textAlignment = .center
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
        tlShotValue.value = 2
        trShotValue.value = 1
        blShotValue.value = 0
        brShotValue.value = 4
        cShotValue.value = 0
        pieChartSettings()
        radarChartSettings()
        // Do any additional setup after loading the view.
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
    
    /*func radarDataShot(){
        tlShotValue.value += shotLocationProcessing().0
        print(tlShotValue.value += shotLocationProcessing().0)
        trShotValue.value += shotLocationProcessing().1
        blShotValue.value += shotLocationProcessing().2
        brShotValue.value += shotLocationProcessing().3
        cShotValue.value += shotLocationProcessing().4
    }*/
    
    func radarDataGoal(){
        
        tlShotValue.value += goalLocationProcessing().0
        trShotValue.value += goalLocationProcessing().1
        blShotValue.value += goalLocationProcessing().2
        brShotValue.value += goalLocationProcessing().3
        cShotValue.value +=  goalLocationProcessing().4
    }
    
    func radarChartSettings(){
        let numberOfShots = [tlShotValue, trShotValue, blShotValue, brShotValue, cShotValue]
        let values = [1, 2, 3]
        let chartDataSet = RadarChartDataSet(: values)
        
        let chartData = RadarChartData(xVals: values, dataSet: chartDataSet)
        let colours = [UIColor.green, UIColor.blue, UIColor.red, UIColor.purple]
        chartDataSet.colors = colours as! [NSUIColor]
        radarChartView.data = chartData
        radarChartView.animate(xAxisDuration: 2.0, yAxisDuration:2.0)
        
    }
    
    func shotLocationProcessing()/* -> (Double, Double, Double, Double, Double)*/{
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
        
        //return(tl_homeGoalieShotLocation, tr_homeGoalieShotLocation, bl_homeGoalieShotLocation,br_homeGoalieShotLocation,c_homeGoalieShotLocation)
    }
    
    func goalLocationProcessing() -> (Double, Double, Double, Double, Double){
        // query realm for number of specified shots on said location
        let tl_homeGoalieGoalLocation = Double((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND shotLocation == %i AND TeamID == %i AND activeState == true", ((realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)!), 1, awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
        let tr_homeGoalieGoalLocation = Double((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND shotLocation == %i AND TeamID == %i AND activeState == true", ((realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)!), 2, awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
        let bl_homeGoalieGoalLocation = Double((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND shotLocation == %i AND TeamID == %i AND activeState == true", ((realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)!), 3, awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
        let br_homeGoalieGoalLocation = Double((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND shotLocation == %i AND TeamID == %i AND activeState == true", ((realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)!), 4, awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
        let c_homeGoalieGoalLocation = Double((realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND shotLocation == %i AND TeamID == %i AND activeState == true", ((realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)!), 5, awayTeam)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({Int($0)}).count)
        
        return(tl_homeGoalieGoalLocation, tr_homeGoalieGoalLocation, bl_homeGoalieGoalLocation,br_homeGoalieGoalLocation,c_homeGoalieGoalLocation)
    }
    
    func teamNameInitialize(){
        
        // query realm for team naames based on newest game
        let homeTeamNameString = realm.object(ofType: teamInfoTable.self, forPrimaryKey: realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.homeTeamID)!
        let awayTeamNameString = realm.object(ofType: teamInfoTable.self, forPrimaryKey: realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)?.opposingTeamID)!
        
        homeTeamGoalsPie.label = "\(homeTeamNameString.nameOfTeam) Goals"
        homeTeamShotsPie.label = "\(homeTeamNameString.nameOfTeam) Shots"
        awayTeamGoalsPie.label = "\(awayTeamNameString.nameOfTeam) Goals"
        awayTeamShotsPie.label = "\(awayTeamNameString.nameOfTeam) Shots"
        
        // align text in text field as well assign text value to text field to team name
        homeTeamNameTextField.text = homeTeamNameString.nameOfTeam
        homeTeamNameTextField.textAlignment = .center
        awayTeamNameTextField.text = awayTeamNameString.nameOfTeam
        awayTeamNameTextField.textAlignment = .center
    }
    
    func scoreInitialize() -> (Double, Double){
        
        // query realm for goal count based on newest gam
        let gameID = realm.object(ofType: newGameTable.self, forPrimaryKey: realm.objects(newGameTable.self).max(ofProperty: "gameID") as Int?)
        let homeScoreFilter = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND activeState == true", (gameID?.gameID)!, homeTeam!)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        
        let awayScoreFilter = (realm.objects(goalMarkersTable.self).filter(NSPredicate(format: "gameID == %i AND TeamID == %i AND activeState == true", (gameID?.gameID)!, awayTeam!)).value(forKeyPath: "cordSetID") as! [Int]).compactMap({String($0)}).count
        
        homeTeamGoalsPie.value = Double(homeScoreFilter)
        awayTeamGoalsPie.value = Double(awayScoreFilter)
        
        // align text to center and assigned text field the value of homeScoreFilter query
        homeTeamScoreTextField.text = String(homeScoreFilter)
        homeTeamScoreTextField.textAlignment = .center
        awayTeamScoreTextField.text = String(awayScoreFilter)
        awayTeamScoreTextField.textAlignment = .center
        
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
        
        // align text to center and assigned text field the value of homeScoreFilter query
        homeNumShotTextField.text = "Number of Shots: " + String(homeShotCounter)
        homeNumShotTextField.textAlignment = .center
        awayNumShotTextField.text = "Number of Shots: " + String(awayShotCounter)
        awayNumShotTextField.textAlignment = .center
        
        return(Double(homeShotCounter), Double(awayShotCounter))
        
    }
    // func used to pass varables on segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // check is appropriate segue is being used
        if (segue.identifier == "backFromCurrentGameStatsSegue"){
            // set var vc as destination segue
            let currentStats = segue.destination as! New_Game_Page
            currentStats.newGameStarted = false
            currentStats.homeTeam = homeTeam
            currentStats.awayTeam = awayTeam
            currentStats.goalieSelectedID = goalieSelectedID
            currentStats.periodNumSelected = periodNumSelected            
        }
        
    }

}
