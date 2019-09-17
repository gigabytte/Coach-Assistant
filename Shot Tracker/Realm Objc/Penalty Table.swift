//  Penalty Table.swift
//  Shot Tracker
//
//  Created by Greg Brooks on 2019-04-27.
//  Copyright © 2019 Greg Brooks. All rights reserved.
//
import Foundation
//import RealmSwift
import RealmSwift

class penaltyTable: Object {
    
    @objc dynamic var penaltyID: Int = 0
    @objc dynamic var gameID: Int = 0
    @objc dynamic var teamID: Int = 0
    @objc dynamic var playerID: Int = 0
    @objc dynamic var penaltyType: String = ""
    @objc dynamic var timeOfOffense: Date?
    @objc dynamic var xCord: Int = 0
    @objc dynamic var yCord: Int = 0
    @objc dynamic var activeState: Bool = true
    
    override class func primaryKey() -> String {
        return "penaltyID"
    }
}
