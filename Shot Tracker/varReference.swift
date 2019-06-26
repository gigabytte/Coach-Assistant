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
 Set / delete user defaults for in game settings
 Input: None
 Output: None
 */
class inGmaeUserDefaultGen{
    
    func enable_userDefaults(){
        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "minorPenaltyLength"), forKey: "temp_minorPenaltyLength")
        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "majorPenaltyLength"), forKey: "temp_majorPenaltyLength")
        UserDefaults.standard.set(true, forKey: "displayGoalBool")
        UserDefaults.standard.set(true, forKey: "displayShotBool")
        UserDefaults.standard.set(true, forKey: "displayPenaltyBool")
        
    }
    
    func delete_userDefaults(){
        
        UserDefaults.standard.removeObject(forKey: "temp_minorPenaltyLength")
        UserDefaults.standard.removeObject(forKey: "temp_majorPenaltyLength")
        UserDefaults.standard.removeObject(forKey: "displayGoalBool")
        UserDefaults.standard.removeObject(forKey: "displayShotBool")
        UserDefaults.standard.removeObject(forKey: "displayPenaltyBool")
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
    func labelViewTopLeftRight(labelViewType: UILabel){
        labelViewType.clipsToBounds = true
        labelViewType.layer.cornerRadius = 10
        labelViewType.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
    }

    func buttonBottomLeft(bottonViewType: UIButton){
        bottonViewType.clipsToBounds = true
        bottonViewType.layer.cornerRadius = 10
        bottonViewType.layer.maskedCorners = [.layerMinXMaxYCorner]
        
    }
    func buttonBottomRight(bottonViewType: UIButton){
        bottonViewType.clipsToBounds = true
        bottonViewType.layer.cornerRadius = 10
        bottonViewType.layer.maskedCorners = [.layerMaxXMaxYCorner]
        
    }
    
    func buttonBottomDouble(bottonViewType: UIButton){
        bottonViewType.clipsToBounds = true
        bottonViewType.layer.cornerRadius = 10
        bottonViewType.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
    }

    
}

/*
Check to see if icloud account logged in
*/
class icloudAccountCheck{
    
    func isICloudContainerAvailable()->Bool {
        if let currentToken = FileManager.default.ubiquityIdentityToken {
            return true
        }
        else {
            return false
        }
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
    var newGameAdUnitID = "ca-app-pub-1292859049443143/2410528114"//"ca-app-pub-3940256099942544/2934735716"
    
    // Help Guide PDF file name
    var helpGuidePDFName:String = "help_guide_iPad"
    
    // legal info pdf file name refrence
    var appLegalPDF: String = "Coach_Assistant_Legal"
    
    // website url for mutipl,e team / player adding
    var websiteURLHelp: String = "https://tinysquaremail.wixsite.com/coachassistant/csv-file-importing"
    
    
}
