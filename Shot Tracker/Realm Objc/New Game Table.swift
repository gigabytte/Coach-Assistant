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
    @objc dynamic var gameLocation: String = ""
    @objc dynamic var winingTeamID: Int = 0
    @objc dynamic var losingTeamID: Int = 0
    @objc dynamic var seasonYear: Int = 0
    @objc dynamic var tieGameBool: Bool = false
    @objc dynamic var activeGameStatus: Bool = true
    @objc dynamic var activeState: Bool = true
    
    let drawboardURL = List<String>()
    
    override class func primaryKey() -> String {
        return "gameID"
    }
    
    
}
