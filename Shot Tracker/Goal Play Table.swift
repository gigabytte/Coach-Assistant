//
//  Goal Play Table.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-02-19.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import RealmSwift
import Realm

class goalPlayTable: Object {
    
    @objc dynamic var goalPlayerID: Int = 0
    @objc dynamic var gameID: Int = 0
    
    //var returnID
    override class func primaryKey() -> String {
        return "goalPlayerID";
    }
    
}

