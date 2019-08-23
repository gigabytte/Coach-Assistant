//
//  Player Info Table.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-01-21.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//
import Foundation
import RealmSwift


class playerInfoTable: Object {
    
    @objc dynamic var playerID: Int = 0
    @objc dynamic var playerName: String = ""
    @objc dynamic var jerseyNum: Int = 0
    @objc dynamic var positionType: String = ""
    @objc dynamic var TeamID: String = ""
    @objc dynamic var lineNum: Int = 0
    @objc dynamic var goalCount: Int = 0
    @objc dynamic var assitsCount: Int = 0
    @objc dynamic var shotCount: Int = 0
    @objc dynamic var plusMinus: Int = 0
    @objc dynamic var playerLogoURL: String = ""
    @objc dynamic var activeState: Bool = true
    
    override class func primaryKey() -> String {
        return "playerID"
    }
    
}
