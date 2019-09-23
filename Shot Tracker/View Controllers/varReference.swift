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
        print()
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

class localizedString{
    
    func localized(value: String = "") -> String {
        return NSLocalizedString(value, comment: "")
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
    
    func tableViewTopLeftRight(tableviewType: UITableView){
        
        tableviewType.clipsToBounds = true
        tableviewType.layer.cornerRadius = 10
        tableviewType.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    func labelViewTopLeftRight(labelViewType: UILabel){
        labelViewType.clipsToBounds = true
        labelViewType.layer.cornerRadius = 10
        labelViewType.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
    }
    
    func imageViewTopLeftRight(labelViewType: UIImageView){
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
    func uiViewTopLeftRight(labelViewType: UIView){
        labelViewType.clipsToBounds = true
        labelViewType.layer.cornerRadius = 10
        labelViewType.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
    }
    
}

class tutorialCircle{
    
    func createOverlay(frame: CGRect, xOffset: CGFloat, yOffset: CGFloat, radius: CGFloat) -> UIView {

        let overlayView = UIView(frame: frame)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)

        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: xOffset, y: yOffset),
                    radius: radius,
                    startAngle: 0.0,
                    endAngle: 2.0 * .pi,
                    clockwise: false)
        path.addRect(CGRect(origin: .zero, size: overlayView.frame.size))
      
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
  
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
       
        maskLayer.fillRule = .evenOdd
        
        overlayView.layer.mask = maskLayer
        overlayView.clipsToBounds = true
        // tag used to identify uiview layer
        overlayView.tag = 1000
        
        return overlayView
    }

}

/*
Check to see if icloud account logged in
*/
class icloudAccountCheck{
    
    func isICloudContainerAvailable()->Bool {
        if FileManager.default.ubiquityIdentityToken != nil {
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
    var newGameAdUnitID = /*"ca-app-pub-1292859049443143/2410528114"*/"ca-app-pub-3940256099942544/2934735716"
    
    // Help Guide PDF file name
    var helpGuidePDFName:String = "help_guide"
    
    // Help Guide gif file name
    var helpGuideGIF:String = "help_guide.gif"
    
    // legal info pdf file name refrence
    var appLegalPDF: String = "Coach_Assistant_Legal"
    
    // new ui update gif
    var uiUpdateGif: String = "ui_update.gif"
    
    // goal tutorial string
    var goalGif: String = "goal_gif.gif"
    
    // goal tutorial string
    var shotGif: String = "shot_gif.gif"
    
    // goal tutorial string
    var faceoffGif: String = "faceoff_gif.gif"
    
    // goal tutorial string
    var penaltyGif: String = "penalty_gif.gif"
    
    // goal tutorial string
    var oldStatsChangeGoalieGif: String = "old_stats_goalie_selection.gif"
    
    // goal tutorial string
    var oldStatsMarkerDetailsGif: String = "old_stats_marker_details_gif.gif"
    
    // goal tutorial string
    var oldStatsAnalyticalViewGif: String = "old_stats_analytical_view.gif"
    
    // goal tutorial string
    var newGameSettingsGif: String = "new_game_settings_gif.gif"
    
    // website url for mutipl,e team / player adding
    var websiteURLHelp: String = "https://tinysquaremail.wixsite.com/coachassistant/csv-file-importing"
    
    var legacyWebsiteURLHelp: String = "https://tinysquaremail.wixsite.com/coachassistant/legacy-importing"
    
    var helpAndSupportURL: String = "https://tinysquaremail.wixsite.com/coachassistant/user-guide"
    
    var legalSupportURL: String = "https://tinysquaremail.wixsite.com/coachassistant/privacy-legal"
    
    // In app purchase SKU ID for Coach Assistant Pro
    var coachAssistantProID: String = "com.tinysquare.coachassistant.pro"
    
    // current scheme value for realm db
    var realmSchemeValue: UInt64 = 3
    
    var dayTimeViewColour:UIColor = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 1)
    var nightTimeViewColour: UIColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    
    var dayTimeNavBarColour: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var nightTimeNavBarColour: UIColor = #colorLiteral(red: 0.344136338, green: 0.3538037693, blue: 0.3728801521, alpha: 1)
    
    var dayTimeTableViewColour: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var nightTimeTableViewColour: UIColor = #colorLiteral(red: 0.3573177315, green: 0.3868757163, blue: 0.429816126, alpha: 1)
    
    var dayTimeNavBarButtonColour: UIColor = #colorLiteral(red: 0.01488990802, green: 0.4462006688, blue: 0.6317400932, alpha: 1)
    var nightTimeNavBarButtonColour: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    
    var dayTimeTextViewColour: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var nightTimeTextViewColour: UIColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
    
    var dayTimeButtonColour: UIColor = #colorLiteral(red: 0.8936389594, green: 0.8936389594, blue: 0.8936389594, alpha: 1)
    var nightTimeButtonColour: UIColor = #colorLiteral(red: 0.6054555309, green: 0.6054555309, blue: 0.6054555309, alpha: 1)
    
}

class systemColour{
    
    func viewColor() -> UIColor{
        // return colour of view based ion system func
        if (UserDefaults.standard.bool(forKey: "darkModeBool") != true){
            return universalValue().dayTimeViewColour
        }else{
            return universalValue().nightTimeViewColour
        }
        
        
    }
    
    func navBarColor() -> UIColor{
        // return colour of nav bar based ion system func
        if (UserDefaults.standard.bool(forKey: "darkModeBool") != true){
            return universalValue().dayTimeNavBarColour
        }else{
            return universalValue().nightTimeNavBarColour
        }
        
    }
    
    func tableViewColor() -> UIColor{
        // return colour of tableview based ion system func
        if (UserDefaults.standard.bool(forKey: "darkModeBool") != true){
            return universalValue().dayTimeTableViewColour
        }else{
            return universalValue().nightTimeTableViewColour
        }
        
    }
    
    func navBarButton() -> UIColor{
        // return colour of tableview based ion system func
        if (UserDefaults.standard.bool(forKey: "darkModeBool") != true){
            return universalValue().dayTimeNavBarButtonColour
        }else{
            return universalValue().nightTimeNavBarButtonColour
        }
        
    }
    
    func uiTextField() -> UIColor{
        // return colour of tableview based ion system func
        if (UserDefaults.standard.bool(forKey: "darkModeBool") != true){
            return universalValue().dayTimeTextViewColour
        }else{
            return universalValue().nightTimeTextViewColour
        }
        
    }
    
    func uiButton() -> UIColor{
        // return colour of tableview based ion system func
        if (UserDefaults.standard.bool(forKey: "darkModeBool") != true){
            return universalValue().dayTimeButtonColour
        }else{
            return universalValue().nightTimeButtonColour
        }
        
    }
    
    
}

class playerPositionConverter{
    
    func realmInpuToString(rawInput: String) -> String {
        
        switch rawInput {
        case "LW":
            return "Left Wing"
            
        case "RW":
            return "Right Wing"
            
        case "C":
            return "Center"
            
        case "LD":
            return "Left Defense"
            
        case "RD":
            return "Right Defense"
            
        case "G":
            return "Goalie"
            
        default:
            return "Unknown"
            
        }
        
    }
    
    
}

class playerLinePositionConverter{
    
    func realmInpuToString(rawInput: Int) -> String {
        
        switch rawInput {
       
        case 1:
            return "F Line 1"
            
        case 2:
            return "F Line 2"
            
        case 3:
            return "F Line 3"
            
        case 4:
            return "D Line 1"
            
        case 5:
            return "D Line 2"
            
        case 6:
            return "D Line 3"
            
        case 0:
            return "G Line 1"
            
        default:
            return "Line N/A"
            
        }
        
    }
    
    
}

class delayClass{
    
    // delay loop
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}

class canCast{
    func clastToInt(valueToCast: String) -> Bool{
        if Int(valueToCast as String) != nil{
            return true
        }
        return false
    }
    
}

class getDate{

    func getYear() -> Int{
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        return components.year!
    }
    
    func getMonth() -> Int{
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        return components.month!
    }
    
    func getDay() -> Int{
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        return components.day!
    }
}
class checkUserDefaults{
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}

class imageResizeClass{
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }}
