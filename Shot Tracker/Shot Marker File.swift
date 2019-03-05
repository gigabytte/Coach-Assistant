//
//  Shot Marker File.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-01-29.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class shotMarkerTable: Object {
    
    @objc dynamic var cordSetID: Int = 0
    @objc dynamic var gameID: Int = 0
    
    @objc dynamic var  TeamID: Int = 0
    @objc dynamic var  goalieID: Int = 0
    @objc dynamic var  periodNum: Int = 0
    @objc dynamic var  xCordShot: Int = 0
    @objc dynamic var  yCordShot: Int = 0
    @objc dynamic var  shotLocation: Int = 0
    @objc dynamic var activeState: Bool = true
    
    //var returnID
    override class func primaryKey() -> String {
        return "cordSetID";
    }
    
    
}
