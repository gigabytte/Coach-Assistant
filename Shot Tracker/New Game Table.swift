//
//  New Game Table.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-01-21.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class newGameTable: Object {
    
    @objc dynamic var gameID: Int = 0
    @objc dynamic var dateGamePlayed: Date?
    @objc dynamic var opposingTeamID: Int = 0
    @objc dynamic var homeTeamID: Int = 0
    @objc dynamic var gameType: String = ""
    @objc dynamic var activeState: Bool = true
    
    
    override class func primaryKey() -> String {
        return "gameID"
    }
    
    
}
