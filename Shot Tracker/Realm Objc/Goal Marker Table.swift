//
//  Goal Marker Table.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-01-21.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class goalMarkersTable: Object {
    
    @objc dynamic var cordSetID: Int = 0
    @objc dynamic var gameID: Int = 0
    @objc dynamic var  goalType: String = ""
    @objc dynamic var  powerPlay: Bool = false
    @objc dynamic var  powerPlayID: Int = 0
    @objc dynamic var  TeamID: Int = 0
    @objc dynamic var  goalieID: Int = 0
    @objc dynamic var  goalPlayerID: Int = 0
    @objc dynamic var  assitantPlayerID: Int = 0
    @objc dynamic var  sec_assitantPlayerID: Int = 0
    @objc dynamic var  periodNum: Int = 0
    @objc dynamic var  xCordGoal: Int = 0
    @objc dynamic var  yCordGoal: Int = 0
    @objc dynamic var  shotLocation: Int = 0
    @objc dynamic var activeState: Bool = true
    
    //var returnID
    override class func primaryKey() -> String {
        return "cordSetID";
    }

}
