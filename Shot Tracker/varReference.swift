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
