//
//  varReference.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-29.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import Foundation

/*
 Generates New Game User Defaults to be used on gme load
 Input : None
 Output: None
 */
class newGameUserDefaultGen{
    func userDefaults() {
         
        UserDefaults.standard.set(nil, forKey: "selectedGoalieID")
        UserDefaults.standard.set(nil, forKey: "periodNumber")
        UserDefaults.standard.set(nil, forKey: "homeTeam")
        UserDefaults.standard.set(nil, forKey: "awayTeam")
        UserDefaults.standard.set(nil, forKey: "newGameStarted")
        UserDefaults.standard.set(nil, forKey: "gameID")
        UserDefaults.standard.set(nil, forKey: "oldStatsBool")
        UserDefaults.standard.set(2, forKey: "minorPenaltyLength")
        UserDefaults.standard.set(4, forKey: "majorPenaltyLength")
    }
}

/*
 Removes user defaults used on new game load
 Input: None
 Output: None
*/
class deleteNewGameUserDefaults{
    class func deleteUserDefaults() {
        
        UserDefaults.standard.removeObject(forKey: "selectedGoalieID")
        UserDefaults.standard.removeObject(forKey: "periodNumber")
        UserDefaults.standard.removeObject(forKey: "homeTeam")
        UserDefaults.standard.removeObject(forKey: "awayTeam")
        UserDefaults.standard.removeObject(forKey: "newGameStarted")
        UserDefaults.standard.removeObject(forKey: "gameID")
        UserDefaults.standard.removeObject(forKey: "oldStatsBoolß")
        
    }
}
/*
 Converts String Type to Date Type
 Input: String
 Output: Date
 */
class stringToDate{
    
    class func stringToDateFormatter(unformattedString: String) -> Date {
        let dateString = unformattedString
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss"
        let stringConverted = dateFormatter.date(from: dateString)
        
        return stringConverted!
    }
}
/*
 Converts Date Type to String Type
 Input: Date
 Output: String
 */
class dateToString{
    
    class func dateToStringFormatter(unformattedDate: Date) -> String{
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss"
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
    
    
}
/*
 Takes in View type and rounders corners baseed onn function parameters
 INPUT: View Type
 OUPUT: None
*/
class roundedCorners{
    func tableViewTopLeft(tableviewType: UITableView){
        
        tableviewType.clipsToBounds = true
        tableviewType.layer.cornerRadius = 10
        tableviewType.layer.maskedCorners = [.layerMinXMinYCorner]
    }
    func tableViewTopRight(tableviewType: UITableView){
        
        tableviewType.clipsToBounds = true
        tableviewType.layer.cornerRadius = 10
        tableviewType.layer.maskedCorners = [.layerMaxXMinYCorner]
    }
    
}

/*
 Stores Varaiables used accorss the app
 */
class universalValue{
  
    // used for markers placed on ice surface
    var markerCenterX: Int = 16
    var markerCenterY:Int = 16
    var markerWidth: Int = 32
    var markerHeight:Int = 32
    
    // used for the length of penalty minutes
    var minorPenanlty: Int =  2
    var majorPenalty: Int = 4
    
    // ads unit id used across app
    // new game ads
    var newGameAdUnitID = "ca-app-pub-3940256099942544/2934735716"
    
    // Help Guide PDF file name
    var helpGuidePDFName:String = "help_guide_iPad"
    
    // legal info pdf file name refrence
    var appLegalPDF: String = "Coach_Assistant_Legal"
    
    
}
