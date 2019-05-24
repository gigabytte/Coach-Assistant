//
//  Current Game Stats Table.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-05-24.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class currentStatsTable: Object {
    
    @objc dynamic var currentStatID: Int = 0
    @objc dynamic var teamID: Int = 0
    @objc dynamic var playerID: Int = 0
    @objc dynamic var lineNum: Int = 0
    @objc dynamic var goalCount: Int = 0
    @objc dynamic var assistCount: Int = 0
    @objc dynamic var plusMinus: Int = 0
    @objc dynamic var activeState: Bool = true
    
    //var returnID
    override class func primaryKey() -> String {
        return "currentStatID";
    }
    
    
}
